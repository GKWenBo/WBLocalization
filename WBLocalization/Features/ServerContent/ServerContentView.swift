import SwiftUI

struct ServerContentView: View {
    @ObservedObject private var store = ArticleStore.shared

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text(verbatim: "Accept-Language").font(.caption).foregroundColor(.secondary)
                    Text(ArticleStore.acceptLanguage).font(.system(.body, design: .monospaced))
                }
            } header: {
                Text(L10n.ServerContent.sectionHeader)
            } footer: {
                Text(L10n.ServerContent.headerFooter)
            }

            Section {
                if let article = store.current {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(article.title).font(.headline)
                        Text(article.body)
                    }
                    DemoValueRow(title: L10n.ServerContent.published, value: ArticleStore.displayDate(article.publishedAt))
                } else {
                    Text(L10n.ServerContent.loading).foregroundColor(.secondary)
                }
            } header: {
                Text(L10n.ServerContent.sectionResponse)
            } footer: {
                Text(L10n.ServerContent.responseFooter)
            }

            Section {
                DemoCase(.wrong) { Text(store.unkeyedCache?.title ?? L10n.ServerContent.loading) }
                DemoCase(.right) { Text(store.current?.title ?? L10n.ServerContent.loading) }
            } header: {
                Text(L10n.ServerContent.sectionCache)
            } footer: {
                Text(L10n.ServerContent.cacheFooter)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(Feature.serverContent.title)
        .navigationBarTitleDisplayMode(.inline)
        .task { await store.load() }
    }
}
