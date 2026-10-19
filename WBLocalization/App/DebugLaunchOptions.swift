import Foundation

#if DEBUG
/// 调试与截图自动化用的启动参数（仅 DEBUG 生效），配合 `-AppleLanguages (ar)` 可无交互地截取任意语言的任意页面：
///
///     xcrun simctl launch <device> com.wenbo.WBLocalization \
///         -AppleLanguages "(ar)" -WBDemoTab uikit -WBDemoFeature plurals
enum DebugLaunchOptions {
    /// `swiftui` / `uikit` / `settings`
    static var tab: RootTabBarController.Tab? {
        switch UserDefaults.standard.string(forKey: "WBDemoTab") {
        case "swiftui": .swiftUI
        case "uikit": .uiKit
        case "settings": .settings
        default: nil
        }
    }

    /// `Feature` 的 rawValue，如 `plurals`、`rtlLayout`。
    static var feature: Feature? {
        UserDefaults.standard.string(forKey: "WBDemoFeature").flatMap(Feature.init(rawValue:))
    }
}
#endif
