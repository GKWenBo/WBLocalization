import SwiftUI

struct FormattingView: View {
    var body: some View {
        List {
            Section {
                rows(FormattingDemo.dateRows)
                // SwiftUI 自带的日期 Text 读取环境 \.locale，由 localizedRoot() 注入，同样跟随 App 语言
                DemoValueRow(title: "Text(date, style: .date)", value: "")
                Text(FormattingDemo.now, style: .date)
                    .foregroundColor(.secondary)
            } header: {
                Text(L10n.Formatting.sectionDate)
            } footer: {
                Text(L10n.Formatting.dateFooter)
            }

            Section {
                rows(FormattingDemo.numberRows)
            } header: {
                Text(L10n.Formatting.sectionNumber)
            } footer: {
                Text(L10n.Formatting.numberFooter)
            }

            Section {
                rows(FormattingDemo.unitRows)
            } header: {
                Text(L10n.Formatting.sectionUnits)
            } footer: {
                Text(L10n.Formatting.unitsFooter)
            }

            Section {
                ForEach(Array(FormattingDemo.pitfalls.enumerated()), id: \.offset) { _, item in
                    DemoCase(item.verdict) {
                        Text(verbatim: item.code)
                            .font(.system(.footnote, design: .monospaced))
                            .foregroundColor(.secondary)
                        Text(item.result)
                    }
                }
            } header: {
                Text(L10n.Formatting.sectionPitfalls)
            } footer: {
                Text(L10n.Formatting.pitfallsFooter)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(Feature.formatting.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func rows(_ items: [(String, String)]) -> some View {
        ForEach(items, id: \.0) { title, value in
            DemoValueRow(title: title, value: value)
        }
    }
}
