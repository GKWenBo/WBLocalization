import Foundation
import Testing
@testable import WBLocalizationKit

struct LocalizedBundleTests {
    @Test func overrideAndRestore() throws {
        let bundle = try Fixture.makeBundle()
        let original = bundle.localizedString(forKey: "greeting", value: nil, table: nil)

        #expect(LocalizedBundle.setLanguage("ar", for: bundle))
        #expect(bundle.localizedString(forKey: "greeting", value: nil, table: nil) == "مرحبا")
        #expect(NSLocalizedString("greeting", bundle: bundle, comment: "") == "مرحبا")
        #expect(bundle.preferredLocalizations == ["ar"])
        #expect(LocalizedBundle.language(for: bundle) == "ar")

        #expect(LocalizedBundle.setLanguage("ru", for: bundle))
        #expect(bundle.localizedString(forKey: "greeting", value: nil, table: nil) == "Привет")

        LocalizedBundle.setLanguage(nil, for: bundle)
        #expect(bundle.localizedString(forKey: "greeting", value: nil, table: nil) == original)
        #expect(LocalizedBundle.language(for: bundle) == nil)
    }

    /// iOS 上 String(localized:bundle:) 不经过重写，需传入 lproj bundle
    @Test func stringLocalizedAPIWithLprojBundle() throws {
        let bundle = try Fixture.makeBundle()
        LocalizedBundle.setLanguage("en", for: bundle)
        let lproj = try #require(LocalizedBundle.lprojBundle(for: bundle))
        #expect(String(localized: "greeting", bundle: lproj) == "Hello")

        LocalizedBundle.setLanguage(nil, for: bundle)
        #expect(LocalizedBundle.lprojBundle(for: bundle) == nil)
    }

    @Test func missingLanguageIsRejected() throws {
        let bundle = try Fixture.makeBundle()
        #expect(!LocalizedBundle.setLanguage("fr", for: bundle))
        #expect(LocalizedBundle.language(for: bundle) == nil)
    }

    @Test func missingKeyReturnsKey() throws {
        let bundle = try Fixture.makeBundle()
        LocalizedBundle.setLanguage("ar", for: bundle)
        #expect(bundle.localizedString(forKey: "not.exist", value: nil, table: nil) == "not.exist")
    }
}
