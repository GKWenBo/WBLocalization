import Foundation
import WBLocalizationKit

enum RTLLayoutDemo {
    /// 应随布局方向镜像的图标：SF Symbols 中带 forward/backward 语义的符号会自动镜像。
    static let mirroredSymbols = ["chevron.forward", "arrow.forward", "arrow.uturn.backward", "text.alignleft"]
    /// 不应镜像的图标：播放键、对勾、时钟表示的不是阅读方向；arrow.right 是固定方向。
    static let fixedSymbols = ["play.fill", "checkmark", "clock", "arrow.right"]
    /// 自定义图片，Asset 中设置了 Direction = Left to Right。
    static let customArrow = "ForwardArrow"

    static let cardCount = 8
    static let animationDistance: CGFloat = 120

    static func cardTitle(_ index: Int) -> String {
        LocalizedFormatters.current.number(Double(index + 1))
    }
}
