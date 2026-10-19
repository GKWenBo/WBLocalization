import Foundation

/// 双向文本（Bidi）工具。
///
/// 在 RTL 文本中插入英文、数字、手机号、URL 等内容时，Unicode 双向算法会按字符方向重新排序，
/// 常见现象是标点、符号「跑到另一边」，如 `+86 138` 显示成 `138 86+`。
/// 解决方案是用 Unicode 隔离符把插入内容包起来，使其方向独立于周围文本。
public extension String {
    /// 方向由内容首个强字符自动判断（FSI … PDI）。用于插值用户昵称、商品名等未知方向的内容。
    var bidiIsolated: String { "\u{2068}\(self)\u{2069}" }

    /// 强制从左到右（LRI … PDI）。用于手机号、验证码、邮箱、URL、代码、版本号。
    var forcedLeftToRight: String { "\u{2066}\(self)\u{2069}" }

    /// 强制从右到左（RLI … PDI）。
    var forcedRightToLeft: String { "\u{2067}\(self)\u{2069}" }

    /// 去掉所有方向控制字符。复制到剪贴板、提交服务端、做字符串比较前应先清理。
    var removingBidiControls: String {
        let controls: Set<Unicode.Scalar> = [
            "\u{200E}", "\u{200F}", "\u{061C}",                         // LRM RLM ALM
            "\u{202A}", "\u{202B}", "\u{202C}", "\u{202D}", "\u{202E}", // LRE RLE PDF LRO RLO
            "\u{2066}", "\u{2067}", "\u{2068}", "\u{2069}",             // LRI RLI FSI PDI
        ]
        return String(String.UnicodeScalarView(unicodeScalars.filter { !controls.contains($0) }))
    }
}
