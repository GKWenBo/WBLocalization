import Foundation
import Testing
@testable import WBLocalizationKit

struct LocalizedFormattersTests {
    /// 2026-10-19 12:00 UTC：取正午，保证在 ±12 时区内格式化出来都是 19 日
    let date = Date(timeIntervalSince1970: 1_792_411_200)

    func formatters(_ id: String) -> LocalizedFormatters {
        LocalizedFormatters(locale: Locale(identifier: id))
    }

    @Test func numbers() {
        #expect(formatters("en_US").number(12345.67) == "12,345.67")
        #expect(formatters("de_DE").number(12345.67) == "12.345,67")
        // 沙特地区默认使用阿拉伯-印度数字
        #expect(formatters("ar_SA").number(12345.67) == "١٢٬٣٤٥٫٦٧")
        // 俄语分组符是不换行空格 U+00A0，不是普通空格
        #expect(formatters("ru_RU").number(12345.67) == "12\u{00A0}345,67")
    }

    @Test func percentAndCurrency() {
        #expect(formatters("en_US").percent(0.45) == "45%")
        #expect(formatters("en_US").currency(99.5, code: "USD") == "$99.50")
        let de = formatters("de_DE").currency(99.5, code: "USD")
        #expect(de.hasPrefix("99,50") && de.hasSuffix("$"))
    }

    @Test func datesFollowLocaleOrder() {
        #expect(formatters("zh-Hans_CN").date(date, template: "yMMMd") == "2026年10月19日")
        #expect(formatters("de_DE").date(date, template: "yMMMd") == "19. Okt. 2026")
    }

    @Test func arabicCalendarDependsOnRegion() {
        // 同为阿拉伯语：沙特默认伊斯兰历，其他地区为公历
        #expect(!formatters("ar_SA").date(date, template: "y").contains("2026"))
        #expect(formatters("ar_CN").date(date, template: "y").contains("2026"))
    }

    @Test func relativeAndList() {
        let past = date.addingTimeInterval(-3 * 3600)
        #expect(formatters("en_US").relative(past, to: date) == "3 hours ago")
        #expect(formatters("en_US").list(["A", "B", "C"]) == "A, B, and C")
        #expect(formatters("zh-Hans_CN").list(["A", "B", "C"]) == "A、B和C")
        #expect(formatters("de_DE").list(["A", "B", "C"]) == "A, B und C")
    }

    @Test func bytesUseGivenLocale() {
        #expect(formatters("en_US").bytes(1_500_000) == "1.5 MB")
        #expect(formatters("de_DE").bytes(1_500_000).hasPrefix("1,5"))
    }

    @Test func cacheIsKeyedByLocale() {
        // 同一配置不同 locale 不能互相串用缓存
        #expect(formatters("en_US").number(1.5) == "1.5")
        #expect(formatters("de_DE").number(1.5) == "1,5")
        LocalizedFormatters.removeCache()
        #expect(formatters("de_DE").number(1.5) == "1,5")
    }

    @Test func posixFormatterIgnoresUserLocale() {
        let formatter = LocalizedFormatters.posixDateFormatter()
        #expect(formatter.string(from: date) == "2026-10-19T12:00:00Z")
        #expect(formatter.date(from: "2026-10-19T12:00:00Z") == date)
    }
}
