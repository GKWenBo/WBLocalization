import Foundation

/// 语言选择的持久化。
///
/// 除了保存 App 内选择，还会同步写入 `AppleLanguages`：启动屏、App 名称、权限弹窗、系统控件
/// 都由系统按该值决定，写入后下次冷启动即与 App 内语言一致。
///
/// 注意：iOS「设置 > App > 语言」修改的也是本 App 域的 `AppleLanguages`。
/// 因此启动时若发现它不等于我们上次写入的值，说明用户在系统设置里改过语言，应以系统为准。
struct LocalizationStorage {
    static let selectedKey = "wb.localization.language"
    static let writtenKey = "wb.localization.writtenAppleLanguages"
    static let appleLanguagesKey = "AppleLanguages"

    let defaults: UserDefaults

    /// App 内选择的语言代码，`nil` 表示跟随系统。
    var selectedCode: String? {
        defaults.string(forKey: Self.selectedKey)
    }

    /// 保存选择并同步 `AppleLanguages`。
    func save(_ code: String?) {
        if let code {
            defaults.set(code, forKey: Self.selectedKey)
            defaults.set([code], forKey: Self.appleLanguagesKey)
            defaults.set([code], forKey: Self.writtenKey)
        } else {
            defaults.removeObject(forKey: Self.selectedKey)
            defaults.removeObject(forKey: Self.appleLanguagesKey)
            defaults.removeObject(forKey: Self.writtenKey)
        }
    }

    /// 只清除 App 内选择，保留系统写入的 `AppleLanguages`（用于用户已在系统设置中改过语言的场景）。
    func clearSelection() {
        defaults.removeObject(forKey: Self.selectedKey)
        defaults.removeObject(forKey: Self.writtenKey)
    }

    /// 是否通过启动参数（如 Scheme 中的 `-AppleLanguages (ar)`）临时指定了语言，常用于调试和截图。
    var hasLaunchArgumentOverride: Bool {
        defaults.volatileDomain(forName: UserDefaults.argumentDomain)[Self.appleLanguagesKey] != nil
    }

    /// 用户是否在系统设置中修改过本 App 语言。
    var appleLanguagesChangedExternally: Bool {
        guard let written = defaults.stringArray(forKey: Self.writtenKey) else { return false }
        return defaults.stringArray(forKey: Self.appleLanguagesKey) != written
    }

    /// 当前生效的系统偏好语言。
    ///
    /// 不直接用 `Locale.preferredLanguages`：它在进程内有缓存，App 内从「指定语言」切回「跟随系统」后
    /// 仍可能返回旧值；而 `UserDefaults` 在移除 App 域的值后会立即回落到全局域。
    var systemPreferredLanguages: [String] {
        defaults.stringArray(forKey: Self.appleLanguagesKey) ?? Locale.preferredLanguages
    }
}
