import Foundation
import WBLocalizationKit

/// 格式化示例的共享数据，所有展示都通过 `LocalizedFormatters.current`（App 当前 locale）。
enum FormattingDemo {
    /// 固定的示例时间：页面打开时刻。
    static let now = Date()
    static let threeHoursAgo = now.addingTimeInterval(-3 * 3600)
    static let names = ["Lina", "Omar", "Yuki"]

    static var formatters: LocalizedFormatters { .current }

    static var dateRows: [(String, String)] {
        let f = formatters
        return [
            (L10n.Formatting.dateFull, f.date(now, dateStyle: .full)),
            (L10n.Formatting.dateTemplate, f.date(now, template: "yMMMd")),
            (L10n.Formatting.dateTime, f.date(now, dateStyle: .none, timeStyle: .short)),
            (L10n.Formatting.dateRelative, f.relative(threeHoursAgo, to: now)),
            (L10n.Formatting.dateCalendar, "\(f.locale.calendar.identifier)".forcedLeftToRight),
        ]
    }

    static var numberRows: [(String, String)] {
        let f = formatters
        return [
            (L10n.Formatting.numberDecimal, f.number(1_234_567.89)),
            (L10n.Formatting.numberPercent, f.percent(0.256)),
            (L10n.Formatting.numberUSD, f.currency(1299.5, code: "USD")),
            (L10n.Formatting.numberEUR, f.currency(1299.5, code: "EUR")),
            (L10n.Formatting.numberJPY, f.currency(1299.5, code: "JPY")),
        ]
    }

    static var unitRows: [(String, String)] {
        let f = formatters
        return [
            (L10n.Formatting.unitsDistance, f.measurement(Measurement(value: 5, unit: UnitLength.kilometers))),
            (L10n.Formatting.unitsTemperature, f.measurement(Measurement(value: 25, unit: UnitTemperature.celsius))),
            (L10n.Formatting.unitsList, f.list(names)),
            (L10n.Formatting.unitsBytes, f.bytes(1_536_000)),
        ]
    }

    /// 常见错误的对比：代码片段 + 结果。
    static var pitfalls: [(verdict: DemoVerdict, code: String, result: String)] {
        let value = 1234.5
        let fixedFormatter = DateFormatter()
        fixedFormatter.dateFormat = "MM/dd/yyyy"
        let currentLocaleFormatter = NumberFormatter()
        currentLocaleFormatter.numberStyle = .currency
        currentLocaleFormatter.currencyCode = "USD"
        currentLocaleFormatter.locale = .current
        return [
            (.wrong, #""\(value)""#, "\(value)"),
            (.right, "formatters.number(value)", formatters.number(value)),
            (.wrong, #"dateFormat = "MM/dd/yyyy""#, fixedFormatter.string(from: now)),
            (.right, #"date(now, template: "yMd")"#, formatters.date(now, template: "yMd")),
            (.wrong, "Locale.current → \(Locale.current.identifier)", currentLocaleFormatter.string(from: 1299.5) ?? ""),
            (.right, "LocalizationContext.locale → \(formatters.locale.identifier)", formatters.currency(1299.5, code: "USD")),
        ]
    }
}
