import Foundation
import Testing
@testable import WBLocalization
import WBLocalizationKit

/// 运行时校验：针对编译产物（各 .lproj）和实际格式化结果。
/// 会切换 Bundle.main 的覆盖语言，因此串行执行，结束后恢复 App 原状态。
@MainActor
@Suite(.serialized)
struct RuntimeLocalizationTests {
    static let languages = StringCatalogTests.languages
    private static let missing = "⚠️MISSING"

    @Test func appSupportsExpectedLanguages() {
        let codes = LocalizationManager.shared.availableLanguages.compactMap(\.code)
        #expect(Set(codes) == Set(Self.languages))
        #expect(codes.count == Self.languages.count, "可选语言出现重复：\(codes)")
    }

    /// 每个 key 在每种语言的编译产物中都能取到值（防止 xcstrings 编译遗漏或语言未打包）。
    @Test(arguments: ["Localizable", "InfoPlist"])
    func compiledTablesContainEveryKey(_ table: String) throws {
        let catalog = try StringCatalog.load(table)
        for language in Self.languages {
            let path = try #require(Bundle.main.path(forResource: language, ofType: "lproj"), "缺少 \(language).lproj")
            let bundle = try #require(Bundle(path: path))
            for key in catalog.entries.keys.sorted() {
                let value = bundle.localizedString(forKey: key, value: Self.missing, table: table)
                #expect(value != Self.missing, "\(language).lproj/\(table) 缺少 \(key)")
            }
        }
    }

    @Test func pluralsFollowEachLanguagesRules() {
        let cases: [(String, Int, String)] = [
            ("zh-Hans", 0, "没有文件"), ("zh-Hans", 5, "5 个文件"),
            ("en", 0, "No files"), ("en", 1, "1 file"), ("en", 2, "2 files"),
            ("de", 1, "1 Datei"), ("de", 3, "3 Dateien"),
            ("ja", 3, "3 個のファイル"),
            ("ru", 1, "1 файл"), ("ru", 3, "3 файла"), ("ru", 5, "5 файлов"), ("ru", 21, "21 файл"), ("ru", 22, "22 файла"),
            // 阿语数字字形取决于地区，这里只断言不含数字的类别
            ("ar", 0, "لا توجد ملفات"), ("ar", 1, "ملف واحد"), ("ar", 2, "ملفان"),
        ]
        withEachLanguage { language in
            for (code, count, expected) in cases where code == language {
                #expect(L10n.Plurals.files(count) == expected, "[\(code)] \(count)")
            }
        }
    }

    @Test func multiVariablePluralsAndArgumentOrder() {
        withEachLanguage { language in
            let summary = L10n.Plurals.summary(files: 5, folders: 1)
            let welcome = L10n.BasicText.welcome(name: "Lina", city: L10n.BasicText.city)
            switch language {
            case "en":
                #expect(summary == "5 files in 1 folder")
                #expect(welcome == "Welcome to Tokyo, Lina!")
            case "ru":
                #expect(summary == "5 файлов в 1 папке")
            case "ja":
                // 日语参数顺序与英语相反
                #expect(summary == "1 個のフォルダに 5 個のファイル")
                #expect(welcome == "東京へようこそ、Linaさん！")
            case "de":
                #expect(summary == "5 Dateien in 1 Ordner")
            default:
                #expect(!summary.contains("%"), "[\(language)] 存在未替换的占位符：\(summary)")
            }
        }
    }

    /// 依次切换到每种语言执行 `body`，最后恢复 App 的语言状态。
    private func withEachLanguage(_ body: (String) -> Void) {
        let defaults = UserDefaults(suiteName: "WBLocalizationTests.runtime")!
        defer {
            defaults.removePersistentDomain(forName: "WBLocalizationTests.runtime")
            LocalizationManager.shared.bootstrap(fallbackLanguage: "en")
        }
        let manager = LocalizationManager(bundle: .main, defaults: defaults)
        for language in Self.languages {
            manager.setLanguage(.specific(language))
            body(language)
        }
    }
}
