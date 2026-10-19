import Foundation
import Testing
@testable import WBLocalizationKit

struct AppLanguageTests {
    @Test func nativeName() {
        #expect(AppLanguage.specific("ar").nativeName == "العربية")
        #expect(AppLanguage.specific("de").nativeName == "Deutsch")
        #expect(AppLanguage.specific("ru").nativeName == "Русский")
        #expect(AppLanguage.system.nativeName == nil)
    }

    @Test func displayNameInOtherLocale() {
        #expect(AppLanguage.specific("ar").displayName(in: Locale(identifier: "zh-Hans")) == "阿拉伯语")
        #expect(AppLanguage.specific("zh-Hans").displayName(in: Locale(identifier: "en")) == "Chinese, Simplified")
    }

    @Test func direction() {
        #expect(AppLanguage.specific("ar").isRightToLeft)
        #expect(AppLanguage.specific("he").isRightToLeft)
        #expect(!AppLanguage.specific("en").isRightToLeft)
        #expect(!AppLanguage.system.isRightToLeft)
    }

    @Test func availableInBundle() throws {
        let languages = AppLanguage.available(in: try Fixture.makeBundle())
        // 跟随系统在首位，开发语言其次，其余按代码排序
        #expect(languages == [.system, .specific("zh-Hans"), .specific("ar"), .specific("en"), .specific("ru")])
    }
}
