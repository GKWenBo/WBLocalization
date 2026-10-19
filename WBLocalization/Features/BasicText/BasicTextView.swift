import SwiftUI

struct BasicTextView: View {
    /// 运行时得到的 key（如来自服务端配置），用来演示 Text 传入变量的坑。
    private let dynamicKey = "basic.greeting"

    var body: some View {
        List {
            Section(L10n.BasicText.sectionStatic) {
                Text(L10n.BasicText.greeting)
            }

            Section {
                Text(BasicTextDemo.welcome)
            } header: {
                Text(L10n.BasicText.sectionPositional)
            } footer: {
                Text(L10n.BasicText.positionalFooter)
            }

            Section {
                DemoCase(.wrong) { Text(BasicTextDemo.concatenated) }
                DemoCase(.right) { Text(BasicTextDemo.pluralized) }
            } header: {
                Text(L10n.BasicText.sectionConcat)
            } footer: {
                Text(L10n.BasicText.concatFooter)
            }

            Section {
                // 字面量会被推断为 LocalizedStringKey，按环境 \.locale 查找
                apiRow(code: #"Text("basic.greeting")"#, verdict: .right) { Text("basic.greeting") }
                // String 变量走 Text<S: StringProtocol> 重载，不会本地化
                apiRow(code: "Text(key)", verdict: .wrong) { Text(dynamicKey) }
                apiRow(code: "Text(LocalizedStringKey(key))", verdict: .right) { Text(LocalizedStringKey(dynamicKey)) }
                apiRow(code: #"String(localized: "…")"#, verdict: .wrong) { Text(String(localized: "basic.greeting")) }
                apiRow(code: #"String(localized: "…", bundle: .localized)"#, verdict: .right) {
                    Text(String(localized: "basic.greeting", bundle: .localized))
                }
            } header: {
                Text(L10n.BasicText.sectionAPI)
            } footer: {
                Text(L10n.BasicText.apiFooterSwiftUI)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(Feature.basicText.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func apiRow<Content: View>(code: String, verdict: DemoVerdict, @ViewBuilder content: () -> Content) -> some View {
        DemoCase(verdict) {
            Text(verbatim: code)
                .font(.system(.footnote, design: .monospaced))
                .foregroundColor(.secondary)
            content()
        }
    }
}
