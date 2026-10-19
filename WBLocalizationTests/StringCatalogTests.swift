import Foundation
import Testing

/// 源文件级校验：直接解析仓库中的 .xcstrings，作为 CI 的翻译质量门禁。
struct StringCatalogTests {
    static let languages = ["zh-Hans", "en", "ar", "de", "ja", "ru"]
    static let catalogNames = ["Localizable", "InfoPlist"]

    @Test(arguments: catalogNames)
    func sourceLanguageIsDevelopmentLanguage(_ name: String) throws {
        let catalog = try StringCatalog.load(name)
        #expect(catalog.sourceLanguage == "zh-Hans")
        #expect(!catalog.entries.isEmpty)
    }

    /// 每个 key 在 6 种语言下都存在，且所有 stringUnit 都是 translated 状态。
    @Test(arguments: catalogNames)
    func everyKeyIsTranslated(_ name: String) throws {
        let catalog = try StringCatalog.load(name)
        for (key, localizations) in catalog.entries.sorted(by: { $0.key < $1.key }) {
            let missing = Self.languages.filter { localizations[$0] == nil }
            #expect(missing.isEmpty, "\(name) \(key) 缺少翻译：\(missing)")
            for (language, localization) in localizations {
                #expect(localization.isTranslated, "\(name) \(key) [\(language)] 未标记为 translated")
                let hasContent = !(localization.value ?? "").isEmpty || !(localization.plural ?? [:]).isEmpty
                #expect(hasContent, "\(name) \(key) [\(language)] 内容为空")
            }
        }
    }

    /// 各语言的占位符（位置 + 类型）必须与源语言一致，否则运行时可能崩溃或显示错误参数。
    @Test(arguments: catalogNames)
    func formatSpecifiersMatchSourceLanguage(_ name: String) throws {
        let catalog = try StringCatalog.load(name)
        for (key, localizations) in catalog.entries.sorted(by: { $0.key < $1.key }) {
            guard let source = localizations[catalog.sourceLanguage] else { continue }
            let expected = Self.signature(of: source)
            for (language, localization) in localizations {
                #expect(Self.signature(of: localization) == expected,
                        "\(key) [\(language)] 占位符 \(Self.signature(of: localization)) 与源语言 \(expected) 不一致")
                // 复数变体：每个类别使用的参数必须是 other 的子集（zero/one 可以省略数字）
                for (category, text) in localization.plural ?? [:] {
                    let variant = FormatSpecifiers.signature(text)
                    #expect(variant.allSatisfy { expected[$0.key] == $0.value },
                            "\(key) [\(language)] 复数类别 \(category) 的占位符不合法：\(text)")
                }
            }
        }
    }

    /// 复数文案覆盖各语言 CLDR 要求的全部类别，例如俄语缺 few/many 会显示错误的词形。
    @Test(arguments: catalogNames)
    func pluralCategoriesAreComplete(_ name: String) throws {
        let catalog = try StringCatalog.load(name)
        for (key, localizations) in catalog.entries.sorted(by: { $0.key < $1.key }) where localizations.values.contains(where: \.isPlural) {
            for (language, localization) in localizations {
                let required = PluralRules.required[language] ?? ["other"]
                if let plural = localization.plural {
                    let missing = required.subtracting(plural.keys)
                    #expect(missing.isEmpty, "\(key) [\(language)] 缺少复数类别 \(missing.sorted())")
                }
                for (variable, sub) in localization.substitutions {
                    let missing = required.subtracting(sub.plural.keys)
                    #expect(missing.isEmpty, "\(key) [\(language)] 变量 \(variable) 缺少复数类别 \(missing.sorted())")
                }
                if !localization.isPlural {
                    // 不区分复数的语言（中文、日语）可以只写一条普通文案
                    #expect(required == ["other"], "\(key) [\(language)] 需要复数规则但只提供了普通文案")
                }
            }
        }
    }

    /// 计算一条翻译的整体签名：复数取 other；多变量替换展开为各自的参数。
    static func signature(of localization: StringCatalog.Localization) -> FormatSignature {
        if let plural = localization.plural {
            return FormatSpecifiers.signature(plural["other"] ?? "")
        }
        return FormatSpecifiers.signature(localization.value ?? "", substitutions: localization.substitutions)
    }
}
