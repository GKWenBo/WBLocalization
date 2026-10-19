import Foundation
import WBLocalizationKit

/// 类型安全的文案入口，key 与 `Localizable.xcstrings` 一一对应。
///
/// 约定：
/// - 一律使用**计算属性/函数**。`static let` 只在首次访问时求值，切换语言后仍是旧文案。
/// - 统一传入 `bundle: .localized`：iOS 上 `String(localized:)` 不经过 Bundle 重写，必须显式指定当前语言的 bundle。
/// - key 采用 `模块.页面.语义` 命名，保持字面量形式，便于 Xcode 自动提取与搜索。
enum L10n {
    /// 取格式化文案（含复数），按当前语言的 locale 格式化参数。
    ///
    /// 不用 `String(localized: "key \(count)")` 插值写法：其参数格式化与复数规则使用 `Locale.current`，
    /// 而 `Locale.current` 不随 App 内语言切换变化，会出现「俄语文案配英文复数规则」的问题。
    static func format(_ key: String, _ arguments: CVarArg...) -> String {
        let format = Bundle.localized.localizedString(forKey: key, value: nil, table: nil)
        return String(format: format, locale: LocalizationContext.locale, arguments: arguments)
    }

    /// 动态拼接的 key（无法被 Xcode 自动提取，需在 String Catalog 中手动维护）。
    static func string(_ key: String) -> String {
        Bundle.localized.localizedString(forKey: key, value: nil, table: nil)
    }

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
        static var wrong: String { String(localized: "common.wrong", bundle: .localized) }
        static var right: String { String(localized: "common.right", bundle: .localized) }
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

    enum BasicText {
        static var sectionStatic: String { String(localized: "basic.section.static", bundle: .localized) }
        static var greeting: String { String(localized: "basic.greeting", bundle: .localized) }
        static var sectionPositional: String { String(localized: "basic.section.positional", bundle: .localized) }
        static var city: String { String(localized: "basic.city", bundle: .localized) }
        static var positionalFooter: String { String(localized: "basic.positional.footer", bundle: .localized) }
        static var sectionConcat: String { String(localized: "basic.section.concat", bundle: .localized) }
        static var concatPrefix: String { String(localized: "basic.concat.prefix", bundle: .localized) }
        static var concatSuffix: String { String(localized: "basic.concat.suffix", bundle: .localized) }
        static var concatFooter: String { String(localized: "basic.concat.footer", bundle: .localized) }
        static var sectionAPI: String { String(localized: "basic.section.api", bundle: .localized) }
        static var apiFooterSwiftUI: String { String(localized: "basic.api.footer.swiftui", bundle: .localized) }
        static var apiFooterUIKit: String { String(localized: "basic.api.footer.uikit", bundle: .localized) }

        static func welcome(name: String, city: String) -> String { L10n.format("basic.welcome", name, city) }
        static func messages(_ count: Int) -> String { L10n.format("basic.messages", count) }
    }

    enum Plurals {
        static var sectionSingle: String { String(localized: "plurals.section.single", bundle: .localized) }
        static var countLabel: String { String(localized: "plurals.count.label", bundle: .localized) }
        static var singleFooter: String { String(localized: "plurals.single.footer", bundle: .localized) }
        static var sectionTable: String { String(localized: "plurals.section.table", bundle: .localized) }
        static var tableFooter: String { String(localized: "plurals.table.footer", bundle: .localized) }
        static var sectionMulti: String { String(localized: "plurals.section.multi", bundle: .localized) }
        static var filesLabel: String { String(localized: "plurals.files.label", bundle: .localized) }
        static var foldersLabel: String { String(localized: "plurals.folders.label", bundle: .localized) }
        static var multiFooter: String { String(localized: "plurals.multi.footer", bundle: .localized) }

        static func files(_ count: Int) -> String { L10n.format("plurals.files", count) }
        static func summary(files: Int, folders: Int) -> String { L10n.format("plurals.summary", files, folders) }
    }

    enum Formatting {
        static var sectionDate: String { String(localized: "fmt.section.date", bundle: .localized) }
        static var dateFull: String { String(localized: "fmt.date.full", bundle: .localized) }
        static var dateTemplate: String { String(localized: "fmt.date.template", bundle: .localized) }
        static var dateTime: String { String(localized: "fmt.date.time", bundle: .localized) }
        static var dateRelative: String { String(localized: "fmt.date.relative", bundle: .localized) }
        static var dateCalendar: String { String(localized: "fmt.date.calendar", bundle: .localized) }
        static var dateFooter: String { String(localized: "fmt.date.footer", bundle: .localized) }
        static var sectionNumber: String { String(localized: "fmt.section.number", bundle: .localized) }
        static var numberDecimal: String { String(localized: "fmt.number.decimal", bundle: .localized) }
        static var numberPercent: String { String(localized: "fmt.number.percent", bundle: .localized) }
        static var numberUSD: String { String(localized: "fmt.number.usd", bundle: .localized) }
        static var numberJPY: String { String(localized: "fmt.number.jpy", bundle: .localized) }
        static var numberEUR: String { String(localized: "fmt.number.eur", bundle: .localized) }
        static var numberFooter: String { String(localized: "fmt.number.footer", bundle: .localized) }
        static var sectionUnits: String { String(localized: "fmt.section.units", bundle: .localized) }
        static var unitsDistance: String { String(localized: "fmt.units.distance", bundle: .localized) }
        static var unitsTemperature: String { String(localized: "fmt.units.temperature", bundle: .localized) }
        static var unitsList: String { String(localized: "fmt.units.list", bundle: .localized) }
        static var unitsBytes: String { String(localized: "fmt.units.bytes", bundle: .localized) }
        static var unitsFooter: String { String(localized: "fmt.units.footer", bundle: .localized) }
        static var sectionPitfalls: String { String(localized: "fmt.section.pitfalls", bundle: .localized) }
        static var pitfallsFooter: String { String(localized: "fmt.pitfalls.footer", bundle: .localized) }
    }

    enum BidiText {
        static var intro: String { String(localized: "bidi.intro", bundle: .localized) }
        static var sectionPhone: String { String(localized: "bidi.section.phone", bundle: .localized) }
        static var phoneFooter: String { String(localized: "bidi.footer.phone", bundle: .localized) }
        static var sectionName: String { String(localized: "bidi.section.name", bundle: .localized) }
        static var nameFooter: String { String(localized: "bidi.footer.name", bundle: .localized) }
        static var sectionTags: String { String(localized: "bidi.section.tags", bundle: .localized) }
        static var sectionCurrent: String { String(localized: "bidi.section.current", bundle: .localized) }
        static var sectionCopy: String { String(localized: "bidi.section.copy", bundle: .localized) }
        static var copyRaw: String { String(localized: "bidi.copy.raw", bundle: .localized) }
        static var copyClean: String { String(localized: "bidi.copy.clean", bundle: .localized) }
        static var copyFooter: String { String(localized: "bidi.footer.copy", bundle: .localized) }

        static func liked(_ name: String) -> String { L10n.format("bidi.liked", name) }
    }

    enum RTLLayout {
        static var sectionAuto: String { String(localized: "rtl.section.auto", bundle: .localized) }
        static var rowTitle: String { String(localized: "rtl.row.title", bundle: .localized) }
        static var rowValue: String { String(localized: "rtl.row.value", bundle: .localized) }
        static var progress: String { String(localized: "rtl.progress", bundle: .localized) }
        static var autoFooter: String { String(localized: "rtl.auto.footer", bundle: .localized) }
        static var sectionIcons: String { String(localized: "rtl.section.icons", bundle: .localized) }
        static var iconsMirror: String { String(localized: "rtl.icons.mirror", bundle: .localized) }
        static var iconsKeep: String { String(localized: "rtl.icons.keep", bundle: .localized) }
        static var iconsFooter: String { String(localized: "rtl.icons.footer", bundle: .localized) }
        static var sectionAnimation: String { String(localized: "rtl.section.animation", bundle: .localized) }
        static var animationPlay: String { String(localized: "rtl.animation.play", bundle: .localized) }
        static var animationFooter: String { String(localized: "rtl.animation.footer", bundle: .localized) }
        static var sectionForced: String { String(localized: "rtl.section.forced", bundle: .localized) }
        static var forcedFooter: String { String(localized: "rtl.forced.footer", bundle: .localized) }
    }

    enum LongText {
        static var sectionTruncation: String { String(localized: "longtext.section.truncation", bundle: .localized) }
        static var sample: String { String(localized: "longtext.sample", bundle: .localized) }
        static var truncationFooter: String { String(localized: "longtext.truncation.footer", bundle: .localized) }
        static var sectionButtons: String { String(localized: "longtext.section.buttons", bundle: .localized) }
        static var buttonLater: String { String(localized: "longtext.button.later", bundle: .localized) }
        static var buttonEnable: String { String(localized: "longtext.button.enable", bundle: .localized) }
        static var buttonsFooter: String { String(localized: "longtext.buttons.footer", bundle: .localized) }
        static var sectionCompound: String { String(localized: "longtext.section.compound", bundle: .localized) }
        static var compound: String { String(localized: "longtext.compound", bundle: .localized) }
        static var compoundFooter: String { String(localized: "longtext.compound.footer", bundle: .localized) }
    }

    enum Typography {
        static var sectionCJK: String { String(localized: "typo.section.cjk", bundle: .localized) }
        static var cjkFooter: String { String(localized: "typo.cjk.footer", bundle: .localized) }
        static var sectionArabic: String { String(localized: "typo.section.arabic", bundle: .localized) }
        static var arabicFooter: String { String(localized: "typo.arabic.footer", bundle: .localized) }
        static var sectionFallback: String { String(localized: "typo.section.fallback", bundle: .localized) }
        static var fallbackFooter: String { String(localized: "typo.fallback.footer", bundle: .localized) }
    }

    enum Images {
        static var sectionLocalized: String { String(localized: "images.section.localized", bundle: .localized) }
        static var localizedFooter: String { String(localized: "images.localized.footer", bundle: .localized) }
        static var sectionDirection: String { String(localized: "images.section.direction", bundle: .localized) }
        static var directionFooter: String { String(localized: "images.direction.footer", bundle: .localized) }
    }

    enum Input {
        static var sectionAlignment: String { String(localized: "input.section.alignment", bundle: .localized) }
        static var namePlaceholder: String { String(localized: "input.name.placeholder", bundle: .localized) }
        static var alignmentFooter: String { String(localized: "input.alignment.footer", bundle: .localized) }
        static var sectionPhone: String { String(localized: "input.section.phone", bundle: .localized) }
        static var phoneFooter: String { String(localized: "input.phone.footer", bundle: .localized) }
        static var sectionParsing: String { String(localized: "input.section.parsing", bundle: .localized) }
        static var parsingInput: String { String(localized: "input.parsing.input", bundle: .localized) }
        static var parsingFooter: String { String(localized: "input.parsing.footer", bundle: .localized) }
    }

    enum SystemStrings {
        static var sectionAppName: String { String(localized: "sys.section.appName", bundle: .localized) }
        static var appNameBase: String { String(localized: "sys.appName.base", bundle: .localized) }
        static var appNameSystem: String { String(localized: "sys.appName.system", bundle: .localized) }
        static var appNameCurrent: String { String(localized: "sys.appName.current", bundle: .localized) }
        static var appNameFooter: String { String(localized: "sys.appName.footer", bundle: .localized) }
        static var sectionPermissions: String { String(localized: "sys.section.permissions", bundle: .localized) }
        static var launchLanguage: String { String(localized: "sys.permission.launchLanguage", bundle: .localized) }
        static var permissionCamera: String { String(localized: "sys.permission.camera", bundle: .localized) }
        static var permissionPhotos: String { String(localized: "sys.permission.photos", bundle: .localized) }
        static var permissionLocation: String { String(localized: "sys.permission.location", bundle: .localized) }
        static var permissionFooter: String { String(localized: "sys.permission.footer", bundle: .localized) }
        static var sectionControls: String { String(localized: "sys.section.controls", bundle: .localized) }
        static var controlsFooter: String { String(localized: "sys.controls.footer", bundle: .localized) }
        static var sectionLaunch: String { String(localized: "sys.section.launch", bundle: .localized) }
        static var launchBody: String { String(localized: "sys.launch.body", bundle: .localized) }
    }

    enum ServerContent {
        static var sectionHeader: String { String(localized: "server.section.header", bundle: .localized) }
        static var headerFooter: String { String(localized: "server.header.footer", bundle: .localized) }
        static var sectionResponse: String { String(localized: "server.section.response", bundle: .localized) }
        static var published: String { String(localized: "server.published", bundle: .localized) }
        static var loading: String { String(localized: "server.loading", bundle: .localized) }
        static var responseFooter: String { String(localized: "server.response.footer", bundle: .localized) }
        static var sectionCache: String { String(localized: "server.section.cache", bundle: .localized) }
        static var cacheFooter: String { String(localized: "server.cache.footer", bundle: .localized) }
    }
}
