import Testing
@testable import WBLocalizationKit

struct LanguageResolverTests {
    let resolver = LanguageResolver(supported: ["zh-Hans", "en", "ar", "de", "ja", "ru"], fallback: "en")

    @Test(arguments: [
        (["zh-Hans-CN"], "zh-Hans"),
        (["en-GB"], "en"),
        (["de-AT"], "de"),
        (["ar-SA"], "ar"),
        (["ja-JP"], "ja"),
        // 系统 API 不会把繁体回退到简体，这里按同语言回退
        (["zh-Hant-HK"], "zh-Hans"),
        (["zh-TW"], "zh-Hans"),
        // 首选不支持时使用第二偏好，而不是直接兜底
        (["fr-FR", "de-DE"], "de"),
        (["pt-BR", "ja-JP"], "ja"),
        (["ko"], "en"),
        ([], "en"),
    ])
    func resolve(preferences: [String], expected: String) {
        #expect(resolver.resolve(preferences: preferences) == expected)
    }

    @Test func scriptFallbackCanBeDisabled() {
        let strict = LanguageResolver(supported: ["zh-Hans", "en"], fallback: "en", allowsScriptFallback: false)
        #expect(strict.resolve(preferences: ["zh-Hant-TW"]) == "en")
        #expect(strict.resolve(preferences: ["zh-Hans"]) == "zh-Hans")
    }

    @Test func unsupportedFallbackUsesFirstSupported() {
        let resolver = LanguageResolver(supported: ["zh-Hans", "en"], fallback: "fr")
        #expect(resolver.fallback == "zh-Hans")
    }

    @Test func readsBundle() throws {
        let resolver = LanguageResolver(bundle: try Fixture.makeBundle())
        #expect(Set(resolver.supported) == ["zh-Hans", "en", "ar", "ru"])
        #expect(resolver.fallback == "zh-Hans")
    }
}
