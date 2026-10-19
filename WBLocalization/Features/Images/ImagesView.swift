import SwiftUI

struct ImagesView: View {
    var body: some View {
        List {
            Section {
                Image("GreetingBanner")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 100)
                    .frame(maxWidth: .infinity)
            } header: {
                Text(L10n.Images.sectionLocalized)
            } footer: {
                Text(L10n.Images.localizedFooter)
            }

            Section {
                row(code: #"Image("ForwardArrow")  // Direction: Left to Right"#, verdict: .right) {
                    Image("ForwardArrow").renderingMode(.template)
                }
                row(code: #"Image(systemName: "arrow.right")"#, verdict: .wrong) {
                    Image(systemName: "arrow.right")
                }
                row(code: ".flipsForRightToLeftLayoutDirection(true)", verdict: .right) {
                    Image(systemName: "arrow.right").flipsForRightToLeftLayoutDirection(true)
                }
            } header: {
                Text(L10n.Images.sectionDirection)
            } footer: {
                Text(L10n.Images.directionFooter)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(Feature.images.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row<Content: View>(code: String, verdict: DemoVerdict, @ViewBuilder image: () -> Content) -> some View {
        DemoCase(verdict) {
            HStack(spacing: 12) {
                image().font(.title2).foregroundColor(.accentColor).frame(width: 32, height: 32)
                Text(verbatim: code).font(.system(.footnote, design: .monospaced)).foregroundColor(.secondary)
            }
        }
    }
}
