import Foundation
import WBLocalizationKit

/// 类型安全的文案入口，key 与 `Localizable.xcstrings` 一一对应。
///
/// 约定：
/// - 一律使用**计算属性/函数**。`static let` 只在首次访问时求值，切换语言后仍是旧文案。
/// - 统一传入 `bundle: .localized`：iOS 上 `String(localized:)` 不经过 Bundle 重写，必须显式指定当前语言的 bundle。
/// - key 采用 `模块.页面.语义` 命名，保持字面量形式，便于 Xcode 自动提取与搜索。
enum L10n {
    enum Tab {
        static var swiftUI: String { String(localized: "tab.swiftui", bundle: .localized) }
        static var uiKit: String { String(localized: "tab.uikit", bundle: .localized) }
        static var settings: String { String(localized: "tab.settings", bundle: .localized) }
    }

    enum Catalog {
        static var swiftUITitle: String { String(localized: "catalog.title.swiftui", bundle: .localized) }
        static var uiKitTitle: String { String(localized: "catalog.title.uikit", bundle: .localized) }
        static var sectionText: String { String(localized: "catalog.section.text", bundle: .localized) }
        static var sectionLayout: String { String(localized: "catalog.section.layout", bundle: .localized) }
        static var sectionSystem: String { String(localized: "catalog.section.system", bundle: .localized) }
    }

    enum Common {
        static var comingSoon: String { String(localized: "common.comingSoon", bundle: .localized) }
    }

    enum Settings {
        static var sectionLanguage: String { String(localized: "settings.section.language", bundle: .localized) }
        static var followSystem: String { String(localized: "settings.language.system", bundle: .localized) }
        static var sectionStatus: String { String(localized: "settings.section.status", bundle: .localized) }
        static var statusLanguage: String { String(localized: "settings.status.language", bundle: .localized) }
        static var statusLocale: String { String(localized: "settings.status.locale", bundle: .localized) }
        static var statusDirection: String { String(localized: "settings.status.direction", bundle: .localized) }
        static var directionLTR: String { String(localized: "settings.direction.ltr", bundle: .localized) }
        static var directionRTL: String { String(localized: "settings.direction.rtl", bundle: .localized) }
        static var sectionSystem: String { String(localized: "settings.section.system", bundle: .localized) }
        static var openSystemSettings: String { String(localized: "settings.system.open", bundle: .localized) }
        static var systemFooter: String { String(localized: "settings.system.footer", bundle: .localized) }
    }
}
