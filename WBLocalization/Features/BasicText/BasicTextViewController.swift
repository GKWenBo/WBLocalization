import UIKit

final class BasicTextViewController: DemoViewController {
    init() {
        super.init(title: Feature.basicText.title)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addSection(L10n.BasicText.sectionStatic, rows: [
            viewRow(makeLabel(L10n.BasicText.greeting)),
        ])

        addSection(L10n.BasicText.sectionPositional, footer: L10n.BasicText.positionalFooter, rows: [
            viewRow(makeLabel(BasicTextDemo.welcome)),
        ])

        addSection(L10n.BasicText.sectionConcat, footer: L10n.BasicText.concatFooter, rows: [
            caseRow(.wrong, content: makeLabel(BasicTextDemo.concatenated)),
            caseRow(.right, content: makeLabel(BasicTextDemo.pluralized)),
        ])

        addSection(L10n.BasicText.sectionAPI, footer: L10n.BasicText.apiFooterUIKit, rows: [
            apiRow(#"NSLocalizedString("…", comment: "")"#, .right, NSLocalizedString("basic.greeting", comment: "")),
            apiRow(#"String(localized: "…")"#, .wrong, String(localized: "basic.greeting")),
            apiRow(#"String(localized: "…", bundle: .localized)"#, .right, String(localized: "basic.greeting", bundle: .localized)),
        ])
    }

    private func apiRow(_ code: String, _ verdict: DemoVerdict, _ result: String) -> UIView {
        let codeLabel = makeLabel(code, color: .secondaryLabel)
        codeLabel.font = .monospacedSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .regular)
        let stack = UIStackView(arrangedSubviews: [codeLabel, makeLabel(result)])
        stack.axis = .vertical
        stack.spacing = 4
        return caseRow(verdict, content: stack)
    }
}
