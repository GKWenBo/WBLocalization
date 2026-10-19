import Foundation
import Testing
@testable import WBLocalizationKit

struct LocalizationStorageTests {
    @Test func saveWritesAppleLanguages() {
        let storage = LocalizationStorage(defaults: Fixture.makeDefaults())
        storage.save("ar")
        #expect(storage.selectedCode == "ar")
        #expect(storage.defaults.stringArray(forKey: "AppleLanguages") == ["ar"])
        #expect(!storage.appleLanguagesChangedExternally)
    }

    @Test func saveNilRestoresSystem() {
        let storage = LocalizationStorage(defaults: Fixture.makeDefaults())
        storage.save("ar")
        storage.save(nil)
        #expect(storage.selectedCode == nil)
        // 移除 App 域后回落到全局域（真实系统偏好）
        #expect(storage.systemPreferredLanguages != ["ar"])
    }

    @Test func detectsSystemSettingsChange() {
        let storage = LocalizationStorage(defaults: Fixture.makeDefaults())
        storage.save("ar")
        // 模拟用户在「设置 > App > 语言」改成德语
        storage.defaults.set(["de"], forKey: "AppleLanguages")
        #expect(storage.appleLanguagesChangedExternally)

        storage.clearSelection()
        #expect(storage.selectedCode == nil)
        #expect(storage.defaults.stringArray(forKey: "AppleLanguages") == ["de"])
        #expect(!storage.appleLanguagesChangedExternally)
    }
}
