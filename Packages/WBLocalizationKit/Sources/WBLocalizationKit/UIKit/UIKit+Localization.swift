#if canImport(UIKit)
import UIKit

// MARK: - 全局布局方向

@MainActor
extension LocalizationManager {
    /// 根据当前语言设置全局布局方向。由 `bootstrap()` / `setLanguage(_:)` 自动调用。
    ///
    /// appearance 只对**之后创建**的视图生效，因此切换语言后还需要重建界面，见 `UIApplication.relocalize`。
    /// 导航栏、TabBar 需要单独设置：导航栏方向决定返回按钮位置和侧滑返回手势的方向。
    func applyLayoutDirection() {
        let attribute: UISemanticContentAttribute = isRightToLeft ? .forceRightToLeft : .forceLeftToRight
        UIView.appearance().semanticContentAttribute = attribute
        UINavigationBar.appearance().semanticContentAttribute = attribute
        UITabBar.appearance().semanticContentAttribute = attribute
        UISearchBar.appearance().semanticContentAttribute = attribute
        UIToolbar.appearance().semanticContentAttribute = attribute
    }
}

// MARK: - 重建界面

@MainActor
public extension UIApplication {
    /// 语言切换后重建所有窗口的根控制器，使新语言与布局方向立即生效。
    ///
    /// ```swift
    /// NotificationCenter.default.addObserver(forName: .wbLanguageDidChange, ...) { _ in
    ///     UIApplication.shared.relocalize { _ in RootTabBarController() }
    /// }
    /// ```
    /// - Parameters:
    ///   - animated: 是否使用交叉淡入过渡，避免界面瞬间跳变。
    ///   - rootBuilder: 为每个窗口创建新的根控制器；返回 `nil` 则跳过该窗口（如系统键盘、浮窗）。
    func relocalize(animated: Bool = true, rootBuilder: (UIWindow) -> UIViewController?) {
        let windows = connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
        for window in windows {
            guard let root = rootBuilder(window) else { continue }
            // 已有的视图不会响应 appearance 变化，显式更新窗口自身方向
            window.semanticContentAttribute = UIView.appearance().semanticContentAttribute
            window.rootViewController = root
            if animated {
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
            }
        }
    }
}

// MARK: - RTL 便捷方法

public extension UIView {
    /// 视图实际生效的布局方向是否为 RTL。
    /// 应使用它而不是 `LocalizationManager.isRightToLeft`：局部可能通过 `semanticContentAttribute` 强制了方向。
    var isRightToLeft: Bool {
        effectiveUserInterfaceLayoutDirection == .rightToLeft
    }
}

public extension UIScrollView {
    /// 滚动到内容的起始边：LTR 为最左侧，RTL 为最右侧。
    ///
    /// 实测 UIScrollView / UICollectionView 在 RTL 下内容会镜像，但初始 contentOffset 仍为 0（最左侧），
    /// 横向列表需要在内容尺寸确定后调用一次（SwiftUI 的 ScrollView 会自动处理）。
    func scrollToLeadingEdge(animated: Bool = false) {
        let inset = adjustedContentInset
        let x = isRightToLeft
            ? max(contentSize.width + inset.right - bounds.width, -inset.left)
            : -inset.left
        setContentOffset(CGPoint(x: x, y: contentOffset.y), animated: animated)
    }
}

public extension UIImage {
    /// 方向性图片（箭头、返回、前进、列表缩进等）：在 RTL 布局的 UIImageView/UIButton 中自动水平翻转。
    /// 不要用于播放键、Logo、对勾、时钟、带文字的图片等「与阅读方向无关」的图片。
    var directional: UIImage {
        imageFlippedForRightToLeftLayoutDirection()
    }
}
#endif
