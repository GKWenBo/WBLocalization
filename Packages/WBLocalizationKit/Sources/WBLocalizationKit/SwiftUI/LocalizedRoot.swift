#if canImport(SwiftUI)
import SwiftUI

public extension View {
    /// 用于根视图（或每个 `UIHostingController` 的 rootView）：注入当前语言的 `\.locale` 与 `\.layoutDirection`。
    ///
    /// - `\.locale`：`Text("key")`、`Text(date, style:)`、`formatted()` 都依赖它选择语言与格式。
    /// - `\.layoutDirection`：决定 HStack、padding(.leading) 等的方向。
    /// - Parameter rebuildsOnChange: 语言变化时是否以 `.id` 重建整个视图树。
    ///   重建能保证所有缓存的文本刷新，但会丢失视图内的 `@State`（包括导航栈）；
    ///   若页面状态需要保留，可传 `false`，并确保文案都在 `body` 中实时计算。
    func localizedRoot(_ manager: LocalizationManager = .shared, rebuildsOnChange: Bool = true) -> some View {
        modifier(LocalizedRootModifier(manager: manager, rebuildsOnChange: rebuildsOnChange))
    }
}

private struct LocalizedRootModifier: ViewModifier {
    @ObservedObject var manager: LocalizationManager
    let rebuildsOnChange: Bool

    func body(content: Content) -> some View {
        let localized = content
            .environment(\.locale, manager.locale)
            .environment(\.layoutDirection, manager.isRightToLeft ? .rightToLeft : .leftToRight)
        if rebuildsOnChange {
            localized.id(manager.resolvedCode)
        } else {
            localized
        }
    }
}
#endif
