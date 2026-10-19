import Foundation

/// 基础文本示例的共享数据。
enum BasicTextDemo {
    /// 用户昵称来自业务数据，不翻译。
    static let userName = "Lina"
    /// 拼接反例使用 1：最容易暴露英语 “1 new messages” 这类单复数错误。
    static let messageCount = 1

    /// ❌ 拼接：语序固定、无法处理复数。
    static var concatenated: String {
        "\(L10n.BasicText.concatPrefix) \(messageCount) \(L10n.BasicText.concatSuffix)"
    }

    /// ✅ 完整句子 + 复数规则。
    static var pluralized: String {
        L10n.BasicText.messages(messageCount)
    }

    static var welcome: String {
        L10n.BasicText.welcome(name: userName, city: L10n.BasicText.city)
    }
}
