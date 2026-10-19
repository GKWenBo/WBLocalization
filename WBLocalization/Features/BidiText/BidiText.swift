import Foundation
import WBLocalizationKit

/// 双向文本示例。阿拉伯语句子是固定的样例数据（非界面文案），便于在任何界面语言下观察问题。
enum BidiTextDemo {
    static let phone = "+86 138-0000-0000"
    /// 以中性字符开头/结尾的昵称（@、!、+、%、# 等）在 RTL 段落中会被重新排序。
    static let userName = "@lina_99!"
    static let hashtag = "#WWDC26"
    static let version = "iOS 27+"

    /// 「请拨打 … 联系我们。」
    static let phoneWrong = "اتصل بنا على \(phone)."
    static let phoneRight = "اتصل بنا على \(phone.forcedLeftToRight)."

    /// 「来自 … 的新评论」：显示为「lina_99@ … !」。
    static let nameWrong = "تعليق جديد من \(userName)"
    static let nameRight = "تعليق جديد من \(userName.bidiIsolated)"

    /// 「关注我们 … 和 …」：「#」「+」跑到另一侧。
    static let tagWrong = "تابعونا على \(hashtag) و \(version)"
    static let tagRight = "تابعونا على \(hashtag.forcedLeftToRight) و \(version.forcedLeftToRight)"

    /// 当前界面语言下的插值：昵称同样需要隔离。
    static var currentLanguageSample: String {
        L10n.BidiText.liked(userName.bidiIsolated)
    }

    static var copyRows: [(String, String)] {
        let numbers = LocalizedFormatters.current
        return [
            (L10n.BidiText.copyRaw, numbers.number(Double(phoneRight.count))),
            (L10n.BidiText.copyClean, numbers.number(Double(phoneRight.removingBidiControls.count))),
        ]
    }
}
