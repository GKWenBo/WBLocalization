import SwiftUI

struct RTLLayoutView: View {
    @State private var slider = 0.6
    @State private var moved = false

    var body: some View {
        List {
            Section {
                // HStack、Spacer、padding(.leading) 都基于语义方向，RTL 下自动镜像
                HStack {
                    Image(systemName: "bell.fill").foregroundColor(.orange)
                    Text(L10n.RTLLayout.rowTitle)
                    Spacer()
                    Text(L10n.RTLLayout.rowValue).foregroundColor(.secondary)
                    Image(systemName: "chevron.forward").foregroundColor(.secondary)
                }
                ProgressView(L10n.RTLLayout.progress, value: 0.3)
                Slider(value: $slider)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(0..<RTLLayoutDemo.cardCount, id: \.self) { index in
                            Text(RTLLayoutDemo.cardTitle(index))
                                .font(.title2.bold())
                                .frame(width: 64, height: 64)
                                .background(Color.accentColor.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            } header: {
                Text(L10n.RTLLayout.sectionAuto)
            } footer: {
                Text(L10n.RTLLayout.autoFooter)
            }

            Section {
                iconRow(L10n.RTLLayout.iconsMirror, symbols: RTLLayoutDemo.mirroredSymbols, custom: RTLLayoutDemo.customArrow)
                iconRow(L10n.RTLLayout.iconsKeep, symbols: RTLLayoutDemo.fixedSymbols, custom: nil)
            } header: {
                Text(L10n.RTLLayout.sectionIcons)
            } footer: {
                Text(L10n.RTLLayout.iconsFooter)
            }

            Section {
                DemoCase(.wrong) {
                    Text(verbatim: ".offset(x: moved ? 120 : 0)").font(.system(.footnote, design: .monospaced)).foregroundColor(.secondary)
                    dot.offset(x: moved ? RTLLayoutDemo.animationDistance : 0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                DemoCase(.right) {
                    Text(verbatim: ".frame(alignment: moved ? .trailing : .leading)").font(.system(.footnote, design: .monospaced)).foregroundColor(.secondary)
                    dot.frame(maxWidth: .infinity, alignment: moved ? .trailing : .leading)
                }
                Button(L10n.RTLLayout.animationPlay) {
                    withAnimation(.easeInOut(duration: 0.6)) { moved.toggle() }
                }
            } header: {
                Text(L10n.RTLLayout.sectionAnimation)
            } footer: {
                Text(L10n.RTLLayout.animationFooter)
            }

            Section {
                DemoCase(.wrong) { playerBar }
                DemoCase(.right) { playerBar.environment(\.layoutDirection, .leftToRight) }
            } header: {
                Text(L10n.RTLLayout.sectionForced)
            } footer: {
                Text(L10n.RTLLayout.forcedFooter)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(Feature.rtlLayout.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var dot: some View {
        Circle().fill(Color.accentColor).frame(width: 24, height: 24)
    }

    private var playerBar: some View {
        HStack(spacing: 16) {
            Image(systemName: "backward.fill")
            Image(systemName: "play.fill")
            Image(systemName: "forward.fill")
            ProgressView(value: 0.3)
        }
        .font(.title3)
    }

    private func iconRow(_ title: String, symbols: [String], custom: String?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.subheadline.weight(.semibold))
            HStack(alignment: .top, spacing: 12) {
                ForEach(symbols, id: \.self) { name in
                    icon(Image(systemName: name), caption: name)
                }
                if let custom {
                    icon(Image(custom).renderingMode(.template), caption: custom)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func icon(_ image: Image, caption: String) -> some View {
        VStack(spacing: 4) {
            image.resizable().scaledToFit().frame(width: 24, height: 24).foregroundColor(.accentColor)
            Text(verbatim: caption).font(.system(size: 9, design: .monospaced)).foregroundColor(.secondary)
                .lineLimit(2).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}
