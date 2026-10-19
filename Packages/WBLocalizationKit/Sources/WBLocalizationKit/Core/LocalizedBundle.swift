import Foundation
import ObjectiveC

/// 运行时替换宿主 bundle（通常是 `Bundle.main`）的类，使其本地化查询转发到指定语言的 `.lproj`。
///
/// 覆盖范围：`NSLocalizedString`、`Bundle.localizedString(forKey:value:table:)`、storyboard/xib 文案，
/// 以及读取 `Bundle.main.preferredLocalizations` 的三方库。
///
/// ⚠️ iOS 上 `String(localized:bundle:)` 走的是 Foundation 内部查找路径，不经过本类重写，
/// 需改用 `String(localized: "key", bundle: .localized)`，见 `Bundle.localized`。
final class LocalizedBundle: Bundle, @unchecked Sendable {

    /// 宿主 bundle → 当前覆盖语言的 `.lproj` bundle。
    private static let overrides = Locked<[ObjectIdentifier: Override]>([:])

    private struct Override {
        let code: String
        let bundle: Bundle
    }

    /// 为宿主 bundle 设置覆盖语言；`code == nil` 表示取消覆盖、恢复系统行为。
    /// - Returns: 对应 `.lproj` 不存在时返回 `false`，不做任何修改。
    @discardableResult
    static func setLanguage(_ code: String?, for host: Bundle) -> Bool {
        guard let code else {
            overrides.withLock { $0[ObjectIdentifier(host)] = nil }
            return true
        }
        guard let path = host.path(forResource: code, ofType: "lproj"),
              let lproj = Bundle(path: path) else { return false }

        install(on: host)
        overrides.withLock { $0[ObjectIdentifier(host)] = Override(code: code, bundle: lproj) }
        return true
    }

    /// 当前覆盖语言，无覆盖时为 `nil`。
    static func language(for host: Bundle) -> String? {
        overrides.withLock { $0[ObjectIdentifier(host)]?.code }
    }

    /// 当前覆盖语言的 `.lproj` bundle，无覆盖时为 `nil`。
    static func lprojBundle(for host: Bundle) -> Bundle? {
        overrides.withLock { $0[ObjectIdentifier(host)]?.bundle }
    }

    /// 替换 isa，只执行一次（重复调用无副作用）。
    private static func install(on host: Bundle) {
        guard !(host is LocalizedBundle) else { return }
        object_setClass(host, LocalizedBundle.self)
    }

    private var override: Override? {
        Self.overrides.withLock { $0[ObjectIdentifier(self)] }
    }

    // MARK: - Overrides

    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let override else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return override.bundle.localizedString(forKey: key, value: value, table: tableName)
    }

    override var preferredLocalizations: [String] {
        guard let override else { return super.preferredLocalizations }
        return [override.code]
    }
}

public extension Bundle {
    /// 当前 App 内语言对应的 `.lproj` bundle，**仅用于字符串查找**（图片等资源仍从 `Bundle.main` 读取）。
    ///
    /// ```swift
    /// String(localized: "home.title", bundle: .localized)
    /// ```
    /// 未调用 `LocalizationManager.bootstrap()` 或跟随系统且无覆盖时返回 `Bundle.main`。
    static var localized: Bundle {
        LocalizedBundle.lprojBundle(for: .main) ?? .main
    }
}

/// 极简的锁封装，保证静态状态在多线程下读写安全（兼容 iOS 15，无需 OSAllocatedUnfairLock）。
final class Locked<Value>: @unchecked Sendable {
    private var value: Value
    private let lock = NSLock()

    init(_ value: Value) { self.value = value }

    func withLock<T>(_ body: (inout Value) throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try body(&value)
    }
}
