import SwiftUI

struct LongTextView: View {
    var body: some View {
        List {
            Section {
                DemoCase(.wrong) {
                    Text(L10n.LongText.sample).lineLimit(1).frame(width: 200, alignment: .leading)
                }
                DemoCase(.right) {
                    Text(L10n.LongText.sample)
                }
            } header: {
                Text(L10n.LongText.sectionTruncation)
            } footer: {
                Text(L10n.LongText.truncationFooter)
            }

            Section {
                DemoCase(.wrong) {
                    HStack {
                        secondaryButton.frame(width: 110)
                        primaryButton.frame(width: 110)
                    }
                    .lineLimit(1)
                }
                DemoCase(.right) { adaptiveButtons }
            } header: {
                Text(L10n.LongText.sectionButtons)
            } footer: {
                Text(L10n.LongText.buttonsFooter)
            }

            Section {
                DemoCase(.wrong) {
                    Text(L10n.LongText.compound).font(.title2).lineLimit(1)
                        .frame(width: 160, alignment: .leading)
                }
                DemoCase(.right) {
                    Text(L10n.LongText.compound).font(.title2).lineLimit(1).minimumScaleFactor(0.5)
                        .frame(width: 160, alignment: .leading)
                }
            } header: {
                Text(L10n.LongText.sectionCompound)
            } footer: {
                Text(L10n.LongText.compoundFooter)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(Feature.longText.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var secondaryButton: some View {
        Button(L10n.LongText.buttonLater) {}
            .buttonStyle(.bordered)
    }

    private var primaryButton: some View {
        Button(L10n.LongText.buttonEnable) {}
            .buttonStyle(.borderedProminent)
    }

    /// 横排放得下就横排，否则竖排。ViewThatFits 需要 iOS 16，iOS 15 直接竖排。
    ///
    /// 不在 @ViewBuilder 中写 `if #available … else`：Xcode 27 SDK 下部署目标 ≥ iOS 16 时，
    /// 该分支会被推断为仅 iOS 26 可用的类型而编译失败，这里改为显式返回 AnyView。
    private var adaptiveButtons: AnyView {
        let vertical = VStack(alignment: .leading) { secondaryButton; primaryButton }
        if #available(iOS 16, *) {
            return AnyView(ViewThatFits(in: .horizontal) {
                HStack { secondaryButton; primaryButton }.fixedSize()
                vertical
            })
        }
        return AnyView(vertical)
    }
}
