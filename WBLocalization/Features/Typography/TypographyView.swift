import SwiftUI

struct TypographyView: View {
    var body: some View {
        List {
            Section {
                // 实测：环境 \.locale 不影响字形选择，字形跟随 App 的启动语言
                DemoCase(.wrong) {
                    Text(verbatim: ".environment(\\.locale, …)").font(.system(.footnote, design: .monospaced)).foregroundColor(.secondary)
                    cjkRows { code in
                        Text(TypographyDemo.hanCharacters).environment(\.locale, Locale(identifier: code))
                    }
                }
                // AttributedString.languageIdentifier（iOS 15+），iOS 17+ 也可用 .typesettingLanguage
                DemoCase(.right) {
                    Text(verbatim: "AttributedString.languageIdentifier").font(.system(.footnote, design: .monospaced)).foregroundColor(.secondary)
                    cjkRows { code in
                        Text(TypographyDemo.attributedHan(language: code))
                    }
                }
            } header: {
                Text(L10n.Typography.sectionCJK)
            } footer: {
                Text(L10n.Typography.cjkFooter)
            }

            Section {
                DemoCase(.wrong) {
                    Text(TypographyDemo.arabic).font(.title).frame(height: 24).clipped()
                }
                DemoCase(.right) {
                    Text(TypographyDemo.arabic).font(.title)
                }
            } header: {
                Text(L10n.Typography.sectionArabic)
            } footer: {
                Text(L10n.Typography.arabicFooter)
            }

            Section {
                DemoCase(.wrong) {
                    Text(TypographyDemo.mixedScripts).font(.custom(TypographyDemo.customFontName, size: 24))
                }
                DemoCase(.right) {
                    Text(TypographyDemo.mixedScripts).font(.system(size: 24, weight: .heavy))
                }
            } header: {
                Text(L10n.Typography.sectionFallback)
            } footer: {
                Text(L10n.Typography.fallbackFooter)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(Feature.typography.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func cjkRows<Content: View>(@ViewBuilder _ sample: @escaping (String) -> Content) -> some View {
        ForEach(TypographyDemo.cjkLanguages, id: \.self) { code in
            HStack(alignment: .firstTextBaseline) {
                Text(TypographyDemo.languageName(code)).font(.caption).foregroundColor(.secondary).frame(width: 64, alignment: .leading)
                sample(code).font(.largeTitle)
            }
        }
    }
}
