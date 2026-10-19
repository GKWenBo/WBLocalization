import SwiftUI

/// SwiftUI 功能目录。
struct CatalogView: View {
    /// 启动后直接进入的功能页（调试截图用）。
    /// 不用 NavigationLink(tag:selection:)：List 懒加载，屏幕外的行尚未创建时无法跳转。
    private let initialFeature: Feature?
    @State private var showsInitialFeature: Bool

    init(initialFeature: Feature? = nil) {
        self.initialFeature = initialFeature
        _showsInitialFeature = State(initialValue: initialFeature != nil)
    }

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
        .background {
            if let initialFeature {
                NavigationLink(isActive: $showsInitialFeature) {
                    initialFeature.swiftUIDestination
                } label: {
                    EmptyView()
                }
                .hidden()
            }
        }
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
