import UIKit
import WBLocalizationKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    private var languageObserver: NSObjectProtocol?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // 必须在创建任何界面之前调用：恢复语言、替换 Bundle、设置全局布局方向。
        // 开发语言是中文，但对不支持的语言（如法语用户）兜底显示英文更合理。
        LocalizationManager.shared.bootstrap(fallbackLanguage: "en")
        observeLanguageChange()
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }

    /// 语言切换后重建所有窗口的根控制器（多窗口 iPad 也只需在这里统一处理一次），并保持当前所在 Tab。
    private func observeLanguageChange() {
        languageObserver = NotificationCenter.default.addObserver(
            forName: .wbLanguageDidChange, object: nil, queue: .main
        ) { _ in
            MainActor.assumeIsolated {
                UIApplication.shared.relocalize { window in
                    guard let old = window.rootViewController as? RootTabBarController else { return nil }
                    return RootTabBarController(selectedIndex: old.selectedIndex)
                }
            }
        }
    }
}
