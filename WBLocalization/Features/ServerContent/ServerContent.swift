import Foundation
import WBLocalizationKit

/// 服务端返回的文章。
struct Article: Sendable {
    let language: String
    let title: String
    let body: String
    /// ISO 8601，服务端统一使用 UTC。
    let publishedAt: String
}

/// 模拟服务端：根据请求头 Accept-Language 返回对应语言的内容。
/// 这些多语言内容属于「服务端数据」，不放在 App 的 String Catalog 中。
enum MockArticleAPI {
    private static let articles: [String: (title: String, body: String)] = [
        "zh-Hans": ("春季新品上市", "本季新品现已上架，会员可享受限时优惠。"),
        "en": ("Spring Collection Is Here", "Our new seasonal collection is now available, with limited-time offers for members."),
        "ar": ("وصلت تشكيلة الربيع", "تشكيلتنا الموسمية الجديدة متاحة الآن مع عروض لفترة محدودة للأعضاء."),
        "de": ("Die Frühjahrskollektion ist da", "Unsere neue Saisonkollektion ist jetzt erhältlich – mit zeitlich begrenzten Angeboten für Mitglieder."),
        "ja": ("春の新作が登場", "今シーズンの新作を発売しました。会員の方は期間限定の特典をご利用いただけます。"),
        "ru": ("Весенняя коллекция уже здесь", "Новая сезонная коллекция уже в продаже — для участников действуют ограниченные предложения."),
    ]

    static func fetchArticle(_ request: URLRequest) async -> Article {
        try? await Task.sleep(nanoseconds: 300_000_000) // 模拟网络延迟
        // 解析 "ar, en;q=0.9" → ["ar", "en"]，再用与客户端一致的回退规则匹配
        let preferences = (request.value(forHTTPHeaderField: "Accept-Language") ?? "")
            .split(separator: ",")
            .map { $0.split(separator: ";")[0].trimmingCharacters(in: .whitespaces) }
        let language = LanguageResolver(supported: Array(articles.keys), fallback: "en").resolve(preferences: preferences)
        let article = articles[language]!
        return Article(language: language, title: article.title, body: article.body, publishedAt: "2026-03-01T09:30:00Z")
    }
}

/// 文章仓库，生命周期跨越语言切换（单例），用于对比两种缓存策略。
@MainActor
final class ArticleStore: ObservableObject {
    static let shared = ArticleStore()

    /// ❌ 缓存 key 不含语言：第一次加载后就不再变化。
    @Published private(set) var unkeyedCache: Article?
    /// ✅ 缓存 key 含语言。
    @Published private(set) var keyedCache: [String: Article] = [:]

    var currentLanguage: String { LocalizationContext.code ?? "" }
    var current: Article? { keyedCache[currentLanguage] }

    func load() async {
        let language = currentLanguage
        guard keyedCache[language] == nil || unkeyedCache == nil else { return }

        var request = URLRequest(url: URL(string: "https://api.example.com/articles/spring")!)
        request.setAcceptLanguage()
        let article = await MockArticleAPI.fetchArticle(request)
        keyedCache[language] = article
        if unkeyedCache == nil { unkeyedCache = article }
    }

    /// 服务端时间 → Date（POSIX 解析）→ 当前语言展示。
    static func displayDate(_ iso: String) -> String {
        guard let date = LocalizedFormatters.posixDateFormatter().date(from: iso) else { return iso }
        return LocalizedFormatters.current.date(date, dateStyle: .medium, timeStyle: .short)
    }

    static var acceptLanguage: String {
        AcceptLanguage.headerValue().forcedLeftToRight
    }
}
