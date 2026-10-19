import Foundation

/// 生成 HTTP `Accept-Language` 请求头，让服务端下发与 App 内语言一致的内容（推送文案、商品描述、错误信息等）。
///
/// URLSession 默认会根据系统语言自动添加该头，**不会**感知 App 内切换的语言，因此需要手动设置。
public enum AcceptLanguage {
    /// 例：当前语言 `ar`、系统偏好 `["zh-Hans-CN", "en-US"]` → `ar, zh-Hans-CN;q=0.9, en-US;q=0.8`
    /// - Parameters:
    ///   - primary: 首选语言，默认为 App 当前语言。
    ///   - preferences: 追加的备选语言，默认为系统偏好。
    ///   - maxCount: 最多语言数，避免请求头过长。
    public static func headerValue(
        primary: String? = LocalizationContext.code,
        preferences: [String] = Locale.preferredLanguages,
        maxCount: Int = 5
    ) -> String {
        var seen = Set<String>()
        let languages = ([primary].compactMap { $0 } + preferences)
            .map { $0.replacingOccurrences(of: "_", with: "-") }  // BCP 47 使用连字符
            .filter { seen.insert($0.lowercased()).inserted }
            .prefix(maxCount)

        return languages.enumerated().map { index, language in
            guard index > 0 else { return language }
            let quality = max(0.1, 1.0 - Double(index) * 0.1)
            return "\(language);q=\(String(format: "%.1f", locale: Locale(identifier: "en_US_POSIX"), quality))"
        }.joined(separator: ", ")
    }
}

public extension URLRequest {
    /// 设置 `Accept-Language` 为 App 当前语言。
    mutating func setAcceptLanguage(_ value: String = AcceptLanguage.headerValue()) {
        setValue(value, forHTTPHeaderField: "Accept-Language")
    }
}
