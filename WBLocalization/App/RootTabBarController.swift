import SwiftUI
import UIKit
import WBLocalizationKit

/// 根 Tab：SwiftUI 示例 / UIKit 示例 / 设置。
/// 语言切换时整体重建（见 AppDelegate），因此这里的文案只需在初始化时读取一次。
final class RootTabBarController: UITabBarController {
    enum Tab: Int {
        case swiftUI, uiKit, settings
    }

    init(selectedIndex: Int = Tab.swiftUI.rawValue) {
        super.init(nibName: nil, bundle: nil)
        viewControllers = [makeSwiftUITab(), makeUIKitTab(), makeSettingsTab()]
        self.selectedIndex = selectedIndex
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeSwiftUITab() -> UIViewController {
        let root = NavigationView { CatalogView() }
            .navigationViewStyle(.stack)
            .localizedRoot() // 注入 locale 与 layoutDirection
        let controller = UIHostingController(rootView: root)
        controller.tabBarItem = UITabBarItem(title: L10n.Tab.swiftUI, image: UIImage(systemName: "swift"), tag: Tab.swiftUI.rawValue)
        return controller
    }

    private func makeUIKitTab() -> UIViewController {
        let navigation = UINavigationController(rootViewController: CatalogViewController())
        navigation.navigationBar.prefersLargeTitles = true
        navigation.tabBarItem = UITabBarItem(title: L10n.Tab.uiKit, image: UIImage(systemName: "square.stack.3d.up"), tag: Tab.uiKit.rawValue)
        return navigation
    }

    private func makeSettingsTab() -> UIViewController {
        let navigation = UINavigationController(rootViewController: LanguageSettingsViewController())
        navigation.navigationBar.prefersLargeTitles = true
        navigation.tabBarItem = UITabBarItem(title: L10n.Tab.settings, image: UIImage(systemName: "globe"), tag: Tab.settings.rawValue)
        return navigation
    }
}
