import Foundation

/// 面向「展示」的本地化格式化工具，统一使用当前语言的 locale。
///
/// - 所有 Formatter 按「locale + 配置」缓存：创建 DateFormatter/NumberFormatter 成本很高，
///   在列表 cell 中频繁创建会明显掉帧。语言切换时缓存自动清空。
/// - 与服务端交互的日期解析/序列化请使用 `posixDateFormatter`，切勿使用展示用格式化器。
///
/// ```swift
/// let f = LocalizedFormatters.current
/// f.date(Date())                     // ar: ١٩‏/١٠‏/٢٠٢٦
/// f.currency(99.5, code: "USD")      // de: 99,50 $
/// ```
public struct LocalizedFormatters: Sendable {
    public let locale: Locale

    /// 基于当前 App 语言的格式化器。
    public static var current: LocalizedFormatters { LocalizedFormatters(locale: LocalizationContext.locale) }

    public init(locale: Locale) {
        self.locale = locale
    }

    // MARK: - 日期

    /// 按系统预设风格格式化日期/时间。
    public func date(_ date: Date, dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .none) -> String {
        dateFormatter(key: "style.\(dateStyle.rawValue).\(timeStyle.rawValue)") {
            $0.dateStyle = dateStyle
            $0.timeStyle = timeStyle
        }.string(from: date)
    }

    /// 按模板格式化，系统会根据语言调整字段顺序与分隔符。
    /// 例如模板 `"MMMd"`：en → `Oct 19`，zh → `10月19日`，de → `19. Okt.`。
    /// 不要直接写死 `dateFormat = "MM/dd"`，那样所有语言都会是同一种顺序。
    public func date(_ date: Date, template: String) -> String {
        dateFormatter(key: "template.\(template)") {
            $0.setLocalizedDateFormatFromTemplate(template)
        }.string(from: date)
    }

    /// 相对时间，如「3 小时前」「明天」。
    public func relative(
        _ date: Date,
        to reference: Date = Date(),
        unitsStyle: RelativeDateTimeFormatter.UnitsStyle = .full,
        dateTimeStyle: RelativeDateTimeFormatter.DateTimeStyle = .named
    ) -> String {
        cached("relative.\(unitsStyle.rawValue).\(dateTimeStyle.rawValue)") { () -> RelativeDateTimeFormatter in
            let formatter = RelativeDateTimeFormatter()
            formatter.locale = locale
            formatter.unitsStyle = unitsStyle
            formatter.dateTimeStyle = dateTimeStyle
            return formatter
        }.localizedString(for: date, relativeTo: reference)
    }

    // MARK: - 数字

    /// 数字，自动使用当地的分组符、小数点与数字字形（如阿拉伯-印度数字 ٠١٢٣）。
    public func number(_ value: Double, fractionDigits: ClosedRange<Int> = 0...2) -> String {
        numberFormatter(key: "decimal.\(fractionDigits)") {
            $0.numberStyle = .decimal
            $0.minimumFractionDigits = fractionDigits.lowerBound
            $0.maximumFractionDigits = fractionDigits.upperBound
        }.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    /// 百分比，`0.45` → `45%`（de: `45 %`，ar: `٤٥٪؜`）。
    public func percent(_ value: Double, fractionDigits: Int = 0) -> String {
        numberFormatter(key: "percent.\(fractionDigits)") {
            $0.numberStyle = .percent
            $0.maximumFractionDigits = fractionDigits
        }.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    /// 货币。金额币种来自业务数据（`code`），不要用 locale 的默认币种代替：
    /// 用户切换到日语不代表价格要变成日元。
    public func currency(_ value: Decimal, code: String) -> String {
        numberFormatter(key: "currency.\(code)") {
            $0.numberStyle = .currency
            $0.currencyCode = code
        }.string(from: value as NSDecimalNumber) ?? "\(value) \(code)"
    }

    // MARK: - 其他

    /// 度量单位，默认 `.naturalScale` 会按地区自动换算公制/英制（如 km ↔ mi）。
    public func measurement<U: Unit>(
        _ measurement: Measurement<U>,
        unitStyle: Formatter.UnitStyle = .medium,
        unitOptions: MeasurementFormatter.UnitOptions = .naturalScale
    ) -> String {
        cached("measurement.\(unitStyle.rawValue).\(unitOptions.rawValue)") { () -> MeasurementFormatter in
            let formatter = MeasurementFormatter()
            formatter.locale = locale
            formatter.unitStyle = unitStyle
            formatter.unitOptions = unitOptions
            return formatter
        }.string(from: measurement)
    }

    /// 列表，`["A", "B", "C"]` → en: `A, B, and C`，zh: `A、B和C`。不要用 `joined(separator: ", ")`。
    public func list(_ items: [String]) -> String {
        cached("list") { () -> ListFormatter in
            let formatter = ListFormatter()
            formatter.locale = locale
            return formatter
        }.string(from: items) ?? items.joined(separator: ", ")
    }

    /// 文件大小。注意 `ByteCountFormatter` 没有 `locale` 属性，只会使用系统语言，
    /// 因此这里使用 iOS 15 的 `ByteCountFormatStyle`。
    public func bytes(_ count: Int64, style: ByteCountFormatStyle.Style = .file) -> String {
        count.formatted(.byteCount(style: style).locale(locale))
    }

    // MARK: - 服务端

    /// 与服务端交互专用：固定 `en_US_POSIX` + 公历 + UTC，不受用户语言、日历（如日本年号、伊斯兰历）、12/24 小时制影响。
    public static func posixDateFormatter(format: String = "yyyy-MM-dd'T'HH:mm:ssZZZZZ") -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = format
        return formatter
    }
}

// MARK: - 缓存

extension LocalizedFormatters {
    /// Formatter 在 iOS 7+ 格式化操作是线程安全的；缓存只在创建时写入，之后只读。
    private static let cache = Locked<[String: Formatter]>([:])

    static func removeCache() {
        cache.withLock { $0.removeAll() }
    }

    private func cached<F: Formatter>(_ key: String, make: () -> F) -> F {
        let fullKey = "\(locale.identifier)|\(key)"
        return Self.cache.withLock { cache in
            if let formatter = cache[fullKey] as? F { return formatter }
            let formatter = make()
            cache[fullKey] = formatter
            return formatter
        }
    }

    private func dateFormatter(key: String, configure: (DateFormatter) -> Void) -> DateFormatter {
        cached("date.\(key)") {
            let formatter = DateFormatter()
            formatter.locale = locale // 设置 locale 会同时采用该 locale 的日历
            formatter.timeZone = .autoupdatingCurrent // 缓存的 formatter 也能跟随用户时区变化
            configure(formatter)
            return formatter
        }
    }

    private func numberFormatter(key: String, configure: (NumberFormatter) -> Void) -> NumberFormatter {
        cached("number.\(key)") {
            let formatter = NumberFormatter()
            formatter.locale = locale
            configure(formatter)
            return formatter
        }
    }
}
