import Foundation

/// 极简的 String Catalog（.xcstrings）解析器，只覆盖测试需要的部分：
/// 普通文案、复数变体（plural）、多变量替换（substitutions）。
struct StringCatalog {
    struct Substitution {
        let argNum: Int
        let formatSpecifier: String
        let plural: [String: String]
    }

    /// 某个 key 在某种语言下的内容。
    struct Localization {
        /// 普通文案或替换模板。
        let value: String?
        /// 复数变体：类别 → 文案。
        let plural: [String: String]?
        let substitutions: [String: Substitution]
        /// 所有 stringUnit 的 state 是否都是 translated。
        let isTranslated: Bool

        var isPlural: Bool { plural != nil || !substitutions.isEmpty }
    }

    let name: String
    let sourceLanguage: String
    /// key → 语言 → 内容
    let entries: [String: [String: Localization]]

    /// 项目根目录（通过本文件路径推算），测试直接读取源文件，确保校验的是提交到仓库的内容。
    static let projectRoot = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent() // Support
        .deletingLastPathComponent() // WBLocalizationTests
        .deletingLastPathComponent()

    static func load(_ name: String) throws -> StringCatalog {
        let url = projectRoot.appendingPathComponent("WBLocalization/Resources/\(name).xcstrings")
        let json = try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as! [String: Any]
        let strings = json["strings"] as? [String: [String: Any]] ?? [:]
        var entries: [String: [String: Localization]] = [:]
        for (key, entry) in strings {
            let localizations = entry["localizations"] as? [String: [String: Any]] ?? [:]
            entries[key] = localizations.mapValues(parseLocalization)
        }
        return StringCatalog(name: name, sourceLanguage: json["sourceLanguage"] as? String ?? "", entries: entries)
    }

    private static func parseLocalization(_ node: [String: Any]) -> Localization {
        var translated = true
        func unit(_ node: [String: Any]?) -> String? {
            guard let unit = node?["stringUnit"] as? [String: Any] else { return nil }
            if unit["state"] as? String != "translated" { translated = false }
            return unit["value"] as? String
        }
        func pluralForms(_ node: [String: Any]?) -> [String: String]? {
            guard let plural = (node?["variations"] as? [String: Any])?["plural"] as? [String: [String: Any]] else { return nil }
            return plural.compactMapValues { unit($0) }
        }

        var substitutions: [String: Substitution] = [:]
        for (name, sub) in node["substitutions"] as? [String: [String: Any]] ?? [:] {
            substitutions[name] = Substitution(
                argNum: sub["argNum"] as? Int ?? 0,
                formatSpecifier: sub["formatSpecifier"] as? String ?? "",
                plural: pluralForms(sub) ?? [:]
            )
        }
        let value = unit(node)
        let plural = pluralForms(node)
        return Localization(value: value, plural: plural, substitutions: substitutions, isTranslated: translated)
    }
}
