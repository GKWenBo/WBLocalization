import Foundation
import Testing
@testable import WBLocalizationKit

struct AcceptLanguageTests {
    @Test func primaryFirstAndDeduplicated() {
        let value = AcceptLanguage.headerValue(primary: "ar", preferences: ["zh-Hans-CN", "AR", "en_US"])
        #expect(value == "ar, zh-Hans-CN;q=0.9, en-US;q=0.8")
    }

    @Test func limitsCount() {
        let value = AcceptLanguage.headerValue(primary: nil, preferences: ["a", "b", "c", "d"], maxCount: 2)
        #expect(value == "a, b;q=0.9")
    }

    @Test func setsRequestHeader() {
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request.setAcceptLanguage("de")
        #expect(request.value(forHTTPHeaderField: "Accept-Language") == "de")
    }
}
