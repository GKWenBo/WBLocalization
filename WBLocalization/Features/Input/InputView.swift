import SwiftUI

struct InputView: View {
    @State private var name = ""
    @State private var wrongPhone = InputDemo.phone
    @State private var rightPhone = InputDemo.phone

    var body: some View {
        List {
            Section {
                // TextField 默认按布局方向对齐（RTL 靠右）
                TextField(L10n.Input.namePlaceholder, text: $name)
            } header: {
                Text(L10n.Input.sectionAlignment)
            } footer: {
                Text(L10n.Input.alignmentFooter)
            }

            Section {
                DemoCase(.wrong) {
                    TextField("", text: $wrongPhone).keyboardType(.phonePad)
                    codeBoxes
                }
                DemoCase(.right) {
                    Group {
                        TextField("", text: $rightPhone).keyboardType(.phonePad)
                        codeBoxes
                    }
                    .environment(\.layoutDirection, .leftToRight)
                }
            } header: {
                Text(L10n.Input.sectionPhone)
            } footer: {
                Text(L10n.Input.phoneFooter)
            }

            Section {
                DemoValueRow(title: L10n.Input.parsingInput, value: InputDemo.arabicInput)
                ForEach(InputDemo.parsingRows, id: \.code) { item in
                    DemoCase(item.verdict) {
                        Text(verbatim: item.code).font(.system(.footnote, design: .monospaced)).foregroundColor(.secondary)
                        Text(verbatim: item.result)
                    }
                }
            } header: {
                Text(L10n.Input.sectionParsing)
            } footer: {
                Text(L10n.Input.parsingFooter)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(Feature.input.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var codeBoxes: some View {
        HStack(spacing: 8) {
            ForEach(Array(InputDemo.code.enumerated()), id: \.offset) { _, digit in
                Text(verbatim: digit)
                    .font(.title2.monospacedDigit())
                    .frame(width: 36, height: 44)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.4)))
            }
        }
    }
}
