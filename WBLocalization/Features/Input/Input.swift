import Foundation

enum InputDemo {
    static let phone = "+86 138-0000-0000"
    static let code = Array("123456").map(String.init)
    /// 阿拉伯语用户输入的「123.5」（阿拉伯-印度数字 + 阿拉伯小数点）。
    static let arabicInput = "١٢٣٫٥"

    /// 解析结果对比：Double(_:) 只认 ASCII 数字；NumberFormatter 按 locale 解析。
    static var parsingRows: [(verdict: DemoVerdict, code: String, result: String)] {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ar")
        formatter.numberStyle = .decimal
        return [
            (.wrong, "Double(text)", Double(arabicInput).map { "\($0)" } ?? "nil"),
            (.right, #"NumberFormatter(locale: "ar").number(from:)"#, formatter.number(from: arabicInput)?.stringValue ?? "nil"),
        ]
    }
}
