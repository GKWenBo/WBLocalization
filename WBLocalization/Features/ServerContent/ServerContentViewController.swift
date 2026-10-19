import UIKit

final class ServerContentViewController: DemoViewController {
    private let store = ArticleStore.shared
    private lazy var titleLabel = makeLabel(L10n.ServerContent.loading, style: .headline)
    private lazy var bodyLabel = makeLabel("")
    private lazy var publishedRow = UIListContentView(configuration: .valueCell())
    private lazy var wrongCacheLabel = makeLabel(L10n.ServerContent.loading)
    private lazy var rightCacheLabel = makeLabel(L10n.ServerContent.loading)

    init() {
        super.init(title: Feature.serverContent.title)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let header = makeLabel(ArticleStore.acceptLanguage)
        header.font = .monospacedSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)
        let headerStack = UIStackView(arrangedSubviews: [makeLabel("Accept-Language", style: .caption1, color: .secondaryLabel), header])
        headerStack.axis = .vertical
        headerStack.spacing = 4
        addSection(L10n.ServerContent.sectionHeader, footer: L10n.ServerContent.headerFooter, rows: [viewRow(headerStack)])

        let article = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        article.axis = .vertical
        article.spacing = 6
        addSection(L10n.ServerContent.sectionResponse, footer: L10n.ServerContent.responseFooter,
                   rows: [viewRow(article), publishedRow])

        addSection(L10n.ServerContent.sectionCache, footer: L10n.ServerContent.cacheFooter, rows: [
            caseRow(.wrong, content: wrongCacheLabel),
            caseRow(.right, content: rightCacheLabel),
        ])

        update()
        Task {
            await store.load()
            update()
        }
    }

    private func update() {
        guard let article = store.current else { return }
        titleLabel.text = article.title
        bodyLabel.text = article.body
        var published = UIListContentConfiguration.valueCell()
        published.text = L10n.ServerContent.published
        published.secondaryText = ArticleStore.displayDate(article.publishedAt)
        publishedRow.configuration = published
        wrongCacheLabel.text = store.unkeyedCache?.title
        rightCacheLabel.text = article.title
    }
}
