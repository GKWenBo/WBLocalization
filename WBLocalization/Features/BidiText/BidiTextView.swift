import SwiftUI

struct BidiTextView: View {
    var body: some View {
        List {
            Section {
                Text(L10n.BidiText.intro).foregroundColor(.secondary)
            }

            comparison(L10n.BidiText.sectionPhone, footer: L10n.BidiText.phoneFooter,
                       wrong: BidiTextDemo.phoneWrong, right: BidiTextDemo.phoneRight)
            comparison(L10n.BidiText.sectionName, footer: L10n.BidiText.nameFooter,
                       wrong: BidiTextDemo.nameWrong, right: BidiTextDemo.nameRight)
            comparison(L10n.BidiText.sectionTags, footer: nil,
                       wrong: BidiTextDemo.tagWrong, right: BidiTextDemo.tagRight)

            Section(L10n.BidiText.sectionCurrent) {
                Text(BidiTextDemo.currentLanguageSample)
            }

            Section {
                ForEach(BidiTextDemo.copyRows, id: \.0) { DemoValueRow(title: $0.0, value: $0.1) }
            } header: {
                Text(L10n.BidiText.sectionCopy)
            } footer: {
                Text(L10n.BidiText.copyFooter)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(Feature.bidiText.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func comparison(_ title: String, footer: String?, wrong: String, right: String) -> some View {
        Section {
            // 阿拉伯语样例按 RTL 段落对齐展示，与真实阿语界面一致
            DemoCase(.wrong) { sample(wrong) }
            DemoCase(.right) { sample(right) }
        } header: {
            Text(title)
        } footer: {
            if let footer { Text(footer) }
        }
    }

    private func sample(_ text: String) -> some View {
        Text(text)
            .font(.title3)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .environment(\.layoutDirection, .rightToLeft)
    }
}
