import Foundation
import Testing
@testable import WBLocalizationKit

@MainActor
struct LocalizationManagerTests {
    @Test func bootstrapRestoresSelection() throws {
        let bundle = try Fixture.makeBundle()
        let defaults = Fixture.makeDefaults()
        LocalizationStorage(defaults: defaults).save("ru")

        let manager = LocalizationManager(bundle: bundle, defaults: defaults)
        manager.bootstrap()
        #expect(manager.language == .specific("ru"))
        #expect(manager.resolvedCode == "ru")
        #expect(manager.string("greeting") == "Привет")
    }

    @Test func bootstrapPrefersSystemSettingsChange() throws {
        let bundle = try Fixture.makeBundle()
        let defaults = Fixture.makeDefaults()
        LocalizationStorage(defaults: defaults).save("ru")
        defaults.set(["ar"], forKey: "AppleLanguages")

        let manager = LocalizationManager(bundle: bundle, defaults: defaults)
        manager.bootstrap()
        #expect(manager.language == .system)
        #expect(manager.resolvedCode == "ar")
        #expect(manager.isRightToLeft)
    }

    @Test func bootstrapDropsRemovedLanguage() throws {
        let defaults = Fixture.makeDefaults()
        LocalizationStorage(defaults: defaults).save("fr")

        let manager = LocalizationManager(bundle: try Fixture.makeBundle(), defaults: defaults)
        manager.bootstrap()
        #expect(manager.language == .system)
        #expect(defaults.string(forKey: LocalizationStorage.selectedKey) == nil)
    }

    @Test func fallbackLanguage() throws {
        let defaults = Fixture.makeDefaults()
        defaults.set(["ko"], forKey: "AppleLanguages")
        let manager = LocalizationManager(bundle: try Fixture.makeBundle(), defaults: defaults)

        manager.bootstrap()
        #expect(manager.resolvedCode == "zh-Hans")
        manager.bootstrap(fallbackLanguage: "en")
        #expect(manager.resolvedCode == "en")
    }

    @Test func setLanguageSwitchesAndNotifies() throws {
        let defaults = Fixture.makeDefaults()
        let manager = LocalizationManager(bundle: try Fixture.makeBundle(), defaults: defaults)
        manager.bootstrap()

        let counter = Locked(0)
        var notified: Int { counter.withLock { $0 } }
        let token = NotificationCenter.default.addObserver(
            forName: .wbLanguageDidChange, object: manager, queue: nil) { _ in counter.withLock { $0 += 1 } }
        defer { NotificationCenter.default.removeObserver(token) }

        manager.setLanguage(.specific("ar"))
        #expect(notified == 1)
        #expect(manager.string("greeting") == "مرحبا")
        #expect(manager.isRightToLeft)
        #expect(manager.locale.identifier.hasPrefix("ar"))
        #expect(defaults.stringArray(forKey: "AppleLanguages") == ["ar"])

        // 相同语言不重复通知
        manager.setLanguage(.specific("ar"))
        #expect(notified == 1)

        manager.setLanguage(.system)
        #expect(notified == 2)
        #expect(manager.language == .system)
        #expect(defaults.object(forKey: LocalizationStorage.selectedKey) == nil)
    }

    @Test func localeKeepsRegion() {
        #expect(LocalizationManager.makeLocale(code: "de", region: "CH").identifier == "de_CH")
        #expect(LocalizationManager.makeLocale(code: "zh-Hans", region: "US").identifier == "zh-Hans_US")
        #expect(LocalizationManager.makeLocale(code: "en", region: nil).identifier == "en")
    }

    @Test func formattedAndPluralStrings() throws {
        let bundle = try Fixture.makeBundle()
        let manager = LocalizationManager(bundle: bundle, defaults: Fixture.makeDefaults())
        manager.bootstrap()

        manager.setLanguage(.specific("ru"))
        #expect("files.count".localized(1, bundle: bundle) == "1 файл")
        #expect("files.count".localized(3, bundle: bundle) == "3 файла")
        #expect("files.count".localized(5, bundle: bundle) == "5 файлов")

        // 位置参数：不同语言参数顺序不同
        manager.setLanguage(.specific("en"))
        #expect("welcome.format".localized("Tom", "Paris", bundle: bundle) == "Welcome to Paris, Tom")
        #expect("files.count".localized(1, bundle: bundle) == "1 file")
    }
}
