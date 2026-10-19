import SwiftUI

/// SwiftUI 功能目录。
struct CatalogView: View {
    var body: some View {
        List {
            ForEach(FeatureSection.allCases) { section in
                Section(section.title) {
                    ForEach(section.features) { feature in
                        NavigationLink {
                            feature.swiftUIDestination
                        } label: {
                            FeatureRow(feature: feature)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(L10n.Catalog.swiftUITitle)
    }
}

private struct FeatureRow: View {
    let feature: Feature

    var body: some View {
        // 使用 leading 对齐与系统 Label，RTL 下图标与文字位置自动镜像
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                Text(feature.subtitle)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        } icon: {
            Image(systemName: feature.symbolName)
                .foregroundColor(.accentColor)
        }
        .padding(.vertical, 2)
    }
}
