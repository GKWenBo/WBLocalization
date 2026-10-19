import Foundation

/// App 可选择的语言。
///
/// - `system`：跟随系统，包括「设置 > App > 语言」中为本 App 单独设置的语言。
/// - `specific`：App 内指定的语言，值为 `.lproj` 名称，如 `"ar"`、`"zh-Hans"`。
public enum AppLanguage: Hashable, Sendable {
    case system
    case specific(String)

    /// 语言代码，`.system` 为 `nil`。
    public var code: String? {
        switch self {
        case .system: return nil
        case .specific(let code): return code
        }
    }

    /// 用该语言自身书写的名称，如 `العربية`、`Deutsch`；`.system` 为 `nil`，由 App 自行提供文案。
    public var nativeName: String? {
        guard let code else { return nil }
        return Self.displayName(of: code, in: Locale(identifier: code))
    }

    /// 在指定 locale 下的语言名称，如在中文环境下 `ar` 显示为「阿拉伯语」。
    public func displayName(in locale: Locale) -> String? {
        guard let code else { return nil }
        return Self.displayName(of: code, in: locale)
    }

    /// 是否为从右到左书写的语言；`.system` 需结合解析结果判断，此处返回 `false`。
    public var isRightToLeft: Bool {
        guard let code else { return false }
        return Self.isRightToLeft(code)
    }

    /// 由 bundle 中实际存在的 `.lproj` 生成可选语言列表（过滤 `Base`），避免在代码里写死。
    /// 列表首项为 `.system`，其余按开发语言优先、再按代码字母排序。
    public static func available(in bundle: Bundle = .main) -> [AppLanguage] {
        let development = bundle.developmentLocalization
        let codes = supportedLocalizations(in: bundle)
            .sorted { lhs, rhs in
                if lhs == development { return true }
                if rhs == development { return false }
                return lhs < rhs
            }
        return [.system] + codes.map { .specific($0) }
    }
}

// MARK: - 语言代码工具

extension AppLanguage {
    /// bundle 支持的本地化（去掉 Base、去重）。
    ///
    /// 实测：Info.plist 含 `CFBundleLocalizations` 时（如使用了 InfoPlist.xcstrings），
    /// `Bundle.localizations` 会把它与 `.lproj` 目录合并，返回重复项。
    static func supportedLocalizations(in bundle: Bundle) -> [String] {
        var seen = Set<String>()
        return bundle.localizations.filter { $0 != "Base" && seen.insert($0).inserted }
    }

    static func displayName(of code: String, in locale: Locale) -> String? {
        // 先尝试完整标识（可区分 zh-Hans / zh-Hant），失败再退回语言码
        let name = locale.localizedString(forIdentifier: code)
            ?? locale.localizedString(forLanguageCode: code)
        // 首字母大写：部分语言（如俄语 `русский`）的名称默认小写，放在列表中不美观
        return name.map { $0.capitalized(with: locale) }
    }

    static func isRightToLeft(_ code: String) -> Bool {
        if #available(iOS 16, macOS 13, *) {
            return Locale.Language(identifier: code).characterDirection == .rightToLeft
        }
        return Locale.characterDirection(forLanguage: code) == .rightToLeft
    }

    /// 提取基础语言码：`zh-Hant-HK` → `zh`，`en_GB` → `en`。
    static func baseLanguage(of code: String) -> String {
        if #available(iOS 16, macOS 13, *) {
            return Locale.Language(identifier: code).languageCode?.identifier ?? code
        }
        return Locale(identifier: code).languageCode ?? code
    }
}
