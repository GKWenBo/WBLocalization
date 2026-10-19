import Foundation
import Testing
@testable import WBLocalization

/// 代码与 String Catalog 对照：代码引用的 key 必须存在，Catalog 中不能残留没人用的 key。
struct KeyUsageTests {
    /// 代码中引用文案 key 的写法。key 必须以字母开头，排除示例代码字符串里的 "…" 等内容。
    private static let patterns = [
        #"String\(localized:\s*"([A-Za-z][\w.]*)""#,
        #"NSLocalizedString\("([A-Za-z][\w.]*)""#,
        #"L10n\.(?:format|string)\("([A-Za-z][\w.]*)""#,
        // SwiftUI 字面量 key，如 Text("basic.greeting")：只匹配 模块.语义 形式，避免误伤普通文本
        #"Text\("([a-z]+(?:\.[A-Za-z]+)+)"\)"#,
    ].map { try! NSRegularExpression(pattern: $0) }

    /// 由数据动态拼接的 key（Xcode 无法自动提取，需手动维护）。
    @MainActor
    private static var dynamicKeys: Set<String> {
        Set(Feature.allCases.flatMap { ["feature.\($0.rawValue).title", "feature.\($0.rawValue).subtitle"] })
    }

    private static func referencedKeys() throws -> Set<String> {
        let sources = StringCatalog.projectRoot.appendingPathComponent("WBLocalization")
        let files = FileManager.default.enumerator(at: sources, includingPropertiesForKeys: nil)!
            .compactMap { $0 as? URL }
            .filter { $0.pathExtension == "swift" }
        var keys = Set<String>()
        for file in files {
            let text = try String(contentsOf: file, encoding: .utf8)
            let range = NSRange(text.startIndex..., in: text)
            for regex in patterns {
                for match in regex.matches(in: text, range: range) {
                    if let key = Range(match.range(at: 1), in: text) { keys.insert(String(text[key])) }
                }
            }
        }
        return keys
    }

    @Test @MainActor
    func everyReferencedKeyExists() throws {
        let catalog = try StringCatalog.load("Localizable")
        let missing = try Self.referencedKeys().union(Self.dynamicKeys).subtracting(catalog.entries.keys)
        #expect(missing.isEmpty, "代码引用了 Catalog 中不存在的 key：\(missing.sorted())")
    }

    @Test @MainActor
    func catalogHasNoStaleKeys() throws {
        let catalog = try StringCatalog.load("Localizable")
        let stale = Set(catalog.entries.keys).subtracting(try Self.referencedKeys()).subtracting(Self.dynamicKeys)
        #expect(stale.isEmpty, "Catalog 中存在未被引用的 key：\(stale.sorted())")
    }

    /// InfoPlist.xcstrings 的 key 必须是 Info.plist 中真实存在的键，否则翻译不会生效。
    @Test
    func infoPlistKeysExist() throws {
        let catalog = try StringCatalog.load("InfoPlist")
        let info = Bundle.main.infoDictionary ?? [:]
        let missing = catalog.entries.keys.filter { info[$0] == nil }
        #expect(missing.isEmpty, "Info.plist 中缺少这些键的基础值：\(missing.sorted())")
    }
}
