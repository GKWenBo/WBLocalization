import Foundation

/// 格式化占位符签名：参数位置 → 类型类别。用于比较不同语言的占位符是否一致。
///
/// 例如 `"%1$@，欢迎来到%2$@！"` 与 `"Welcome to %2$@, %1$@!"` 的签名相同：`[1: "@", 2: "@"]`。
typealias FormatSignature = [Int: String]

enum FormatSpecifiers {
    // %[n$][flags][width][.precision][length]type，以及 %#@var@
    private static let regex = try! NSRegularExpression(
        pattern: #"%(?:(\d+)\$)?(?:#@(\w+)@|[-+ #0']*\d*(?:\.\d+)?(?:hh|h|ll|l|q|z|t|j)?([@dDiuUxXoOfFeEgGcCsSpaA]))"#
    )

    /// 解析签名。`substitutions` 用于把 `%#@var@` 展开为对应参数；`%arg` 视为 `argNum`。
    static func signature(_ text: String, substitutions: [String: StringCatalog.Substitution] = [:], argNum: Int? = nil) -> FormatSignature {
        var result: FormatSignature = [:]
        // %% 是字面量百分号；%arg 是替换变体中对当前参数的引用
        var text = text.replacingOccurrences(of: "%%", with: "")
        if let argNum, let spec = substitutions.first(where: { $0.value.argNum == argNum })?.value.formatSpecifier {
            if text.contains("%arg") { result[argNum] = category(spec) }
            text = text.replacingOccurrences(of: "%arg", with: "")
        }
        var nextIndex = 1
        let range = NSRange(text.startIndex..., in: text)
        for match in regex.matches(in: text, range: range) {
            let position = Range(match.range(at: 1), in: text).flatMap { Int(text[$0]) }
            if let variable = Range(match.range(at: 2), in: text).map({ String(text[$0]) }) {
                guard let sub = substitutions[variable] else { continue }
                result[sub.argNum] = category(sub.formatSpecifier)
                continue
            }
            let type = Range(match.range(at: 3), in: text).map { String(text[$0]) } ?? ""
            let index = position ?? nextIndex
            nextIndex = index + 1
            result[index] = category(type)
        }
        return result
    }

    /// 把具体类型归类：整数、浮点、对象、字符串……长度修饰（ld / lld）不影响类别。
    static func category(_ spec: String) -> String {
        switch spec.last {
        case "@": "object"
        case "d", "D", "i", "u", "U", "x", "X", "o", "O": "integer"
        case "f", "F", "e", "E", "g", "G", "a", "A": "float"
        case "s", "S": "cstring"
        case "c", "C": "char"
        case "p": "pointer"
        default: "unknown"
        }
    }
}

/// 各语言 CLDR 必需的复数类别（Apple 额外支持任意语言的 zero，属于可选）。
enum PluralRules {
    static let required: [String: Set<String>] = [
        "zh-Hans": ["other"],
        "ja": ["other"],
        "en": ["one", "other"],
        "de": ["one", "other"],
        "ru": ["one", "few", "many", "other"],
        "ar": ["zero", "one", "two", "few", "many", "other"],
    ]
}
