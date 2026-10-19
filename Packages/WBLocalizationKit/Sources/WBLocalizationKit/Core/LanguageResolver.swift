import Foundation

/// 把「用户偏好语言列表」解析为 App 实际支持的某个 `.lproj`。
///
/// 为什么不直接用 `Bundle.preferredLocalizations(from:forPreferences:)`：
/// 1. 无任何匹配时它会返回 `en`（若支持），而不是开发语言或我们期望的兜底语言，且调用方无法区分「真匹配」与「兜底」；
/// 2. 它不会跨文字变体回退：`zh-Hant` / `zh-HK` 用户在只支持 `zh-Hans` 的 App 中会得到英文。
///
/// 本解析器逐个偏好语言匹配，命中即返回，保证用户的第二、第三偏好也能生效。
public struct LanguageResolver: Sendable {
    /// App 支持的语言（`.lproj` 名称，不含 `Base`）。
    public let supported: [String]
    /// 所有偏好都无法匹配时使用的语言。
    public let fallback: String
    /// 是否允许同一语言不同文字/地区间回退，如 `zh-Hant` → `zh-Hans`。
    public let allowsScriptFallback: Bool

    public init(supported: [String], fallback: String, allowsScriptFallback: Bool = true) {
        self.supported = supported
        self.fallback = supported.contains(fallback) ? fallback : (supported.first ?? fallback)
        self.allowsScriptFallback = allowsScriptFallback
    }

    /// 从 bundle 读取支持语言；`fallback` 为空时使用开发语言。
    public init(bundle: Bundle, fallback: String? = nil, allowsScriptFallback: Bool = true) {
        self.init(
            supported: bundle.localizations.filter { $0 != "Base" },
            fallback: fallback ?? bundle.developmentLocalization ?? "en",
            allowsScriptFallback: allowsScriptFallback
        )
    }

    /// 按偏好顺序解析出最终使用的语言代码。
    public func resolve(preferences: [String]) -> String {
        for preference in preferences {
            if let match = match(preference) { return match }
        }
        return fallback
    }

    /// 单个偏好语言的匹配：先交给系统做精确/地区匹配，再按基础语言做文字变体回退。
    func match(_ preference: String) -> String? {
        let base = AppLanguage.baseLanguage(of: preference)
        let candidates = supported.filter { AppLanguage.baseLanguage(of: $0) == base }
        guard !candidates.isEmpty else { return nil }

        // 系统匹配能正确处理 en-GB → en、zh-Hans-CN → zh-Hans 等；结果必须属于同一基础语言才算命中
        if let system = Bundle.preferredLocalizations(from: candidates, forPreferences: [preference]).first,
           candidates.contains(system),
           Self.isCompatible(system, with: preference) {
            return system
        }
        return allowsScriptFallback ? candidates.first : nil
    }

    /// 文字（script）不冲突才视为兼容：`zh-Hans` 与 `zh-TW`（隐含 Hant）不兼容。
    static func isCompatible(_ localization: String, with preference: String) -> Bool {
        guard let lhs = script(of: localization), let rhs = script(of: preference) else { return true }
        return lhs == rhs
    }

    /// 取文字变体；未显式声明时用 maximalIdentifier 推断（zh-TW → Hant）。
    static func script(of code: String) -> String? {
        if #available(iOS 16, macOS 13, *) {
            return Locale.Language(identifier: code).maximalIdentifier
                .components(separatedBy: "-")
                .first { $0.count == 4 }
        }
        return Locale(identifier: code).scriptCode
    }
}
