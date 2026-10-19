import Combine
import Foundation
#if canImport(UIKit)
import UIKit
#endif

public extension Notification.Name {
    /// 语言切换完成后在主线程发送，`object` 为 `LocalizationManager`。
    static let wbLanguageDidChange = Notification.Name("WBLocalizationKit.languageDidChange")
}

/// 本地化入口：管理当前语言、App 内切换、持久化与通知。
///
/// 用法：
/// ```swift
/// // AppDelegate.didFinishLaunching 最早处
/// LocalizationManager.shared.bootstrap(fallbackLanguage: "en")
/// // 切换
/// LocalizationManager.shared.setLanguage(.specific("ar"))
/// ```
@MainActor
public final class LocalizationManager: ObservableObject {
    public static let shared = LocalizationManager()

    /// 用户的选择，可能是 `.system`。
    @Published public private(set) var language: AppLanguage = .system
    /// 实际生效的语言代码（`.lproj` 名称）。
    @Published public private(set) var resolvedCode: String
    /// 当前语言 + 用户所在地区组成的 Locale，用于格式化和 SwiftUI 环境。
    public private(set) var locale: Locale

    public var isRightToLeft: Bool { AppLanguage.isRightToLeft(resolvedCode) }

    /// 可选语言列表，首项为 `.system`。
    public let availableLanguages: [AppLanguage]

    public let bundle: Bundle
    private let storage: LocalizationStorage
    private var resolver: LanguageResolver

    /// - Parameters:
    ///   - bundle: 宿主 bundle，生产环境为 `.main`，测试时可注入。
    ///   - defaults: 持久化位置，必须是该 App 实际使用的 `UserDefaults`（`AppleLanguages` 需写在 App 域）。
    public init(bundle: Bundle = .main, defaults: UserDefaults = .standard) {
        self.bundle = bundle
        self.storage = LocalizationStorage(defaults: defaults)
        self.resolver = LanguageResolver(bundle: bundle)
        self.availableLanguages = AppLanguage.available(in: bundle)

        let code = resolver.resolve(preferences: storage.systemPreferredLanguages)
        self.resolvedCode = code
        self.locale = Self.makeLocale(code: code)
    }

    /// 恢复上次的语言选择并生效。应在创建任何 UI 之前调用。
    /// - Parameter fallbackLanguage: 所有偏好语言都不支持时使用的语言；默认使用开发语言。
    ///   开发语言是中文但面向海外的 App，通常应传 `"en"`。
    public func bootstrap(fallbackLanguage: String? = nil) {
        resolver = LanguageResolver(bundle: bundle, fallback: fallbackLanguage)

        if storage.hasLaunchArgumentOverride {
            // 启动参数仅本次运行有效，不改动持久化的选择
            apply(.system)
            return
        }
        if storage.appleLanguagesChangedExternally {
            // 用户在系统设置里改了 App 语言：以系统为准
            storage.clearSelection()
        }
        if let code = storage.selectedCode, !resolver.supported.contains(code) {
            // 新版本移除了该语言
            storage.save(nil)
        }
        apply(storage.selectedCode.map(AppLanguage.specific) ?? .system)
    }

    /// 切换语言，立即生效并发送 `.wbLanguageDidChange`。UI 刷新由调用方根据通知/`@Published` 处理。
    public func setLanguage(_ newLanguage: AppLanguage) {
        if let code = newLanguage.code, !resolver.supported.contains(code) {
            assertionFailure("不支持的语言：\(code)，请先在工程中添加该本地化")
            return
        }
        guard newLanguage != language else { return }

        storage.save(newLanguage.code)
        apply(newLanguage)
        NotificationCenter.default.post(name: .wbLanguageDidChange, object: self)
    }

    /// 取当前语言的文案；与 `NSLocalizedString` 等价，便于在非 `Bundle.main` 的场景显式调用。
    public func string(_ key: String, table: String? = nil) -> String {
        bundle.localizedString(forKey: key, value: nil, table: table)
    }

    #if canImport(UIKit)
    /// 打开系统设置中本 App 的页面，用户可在其中修改「语言」（iOS 13+，需至少两种本地化才会显示该选项）。
    public func openSystemLanguageSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    #endif

    // MARK: - Private

    private func apply(_ newLanguage: AppLanguage) {
        // 跟随系统时同样设置覆盖：Bundle.main 在进程内会缓存首次解析的语言，
        // 且我们的回退规则（如 zh-Hant → zh-Hans）与系统不同，统一覆盖才能保证文案、格式、方向一致。
        let code = newLanguage.code ?? resolver.resolve(preferences: storage.systemPreferredLanguages)
        LocalizedBundle.setLanguage(code, for: bundle)

        language = newLanguage
        resolvedCode = code
        locale = Self.makeLocale(code: code)
        LocalizationContext.update(code: code, locale: locale)
    }

    /// 语言来自 App 选择，地区沿用系统设置（影响货币、度量单位、首日等）。
    static func makeLocale(code: String, region: String? = currentRegion) -> Locale {
        var components = Locale.components(fromIdentifier: code)
        if let region, components[NSLocale.Key.countryCode.rawValue] == nil {
            components[NSLocale.Key.countryCode.rawValue] = region
        }
        return Locale(identifier: Locale.identifier(fromComponents: components))
    }

    private static var currentRegion: String? {
        if #available(iOS 16, macOS 13, *) {
            return Locale.current.region?.identifier
        }
        return Locale.current.regionCode
    }
}

/// 可在任意线程读取的当前语言快照（`LocalizationManager` 是主线程隔离的）。
public enum LocalizationContext {
    private static let state = Locked<(code: String?, locale: Locale)>((nil, .current))

    /// 当前生效的语言代码；`bootstrap` 之前为 `nil`。
    public static var code: String? { state.withLock { $0.code } }
    public static var locale: Locale { state.withLock { $0.locale } }

    static func update(code: String, locale: Locale) {
        state.withLock { $0 = (code, locale) }
    }
}

public extension String {
    /// 以自身为 key 取 `Bundle.main` 中当前语言的文案，并按当前 locale 格式化参数。
    /// ```swift
    /// "plurals.files".localized(3)
    /// ```
    func localized(_ arguments: CVarArg..., table: String? = nil, bundle: Bundle = .main) -> String {
        let format = bundle.localizedString(forKey: self, value: nil, table: table)
        guard !arguments.isEmpty else { return format }
        return String(format: format, locale: LocalizationContext.locale, arguments: arguments)
    }
}
