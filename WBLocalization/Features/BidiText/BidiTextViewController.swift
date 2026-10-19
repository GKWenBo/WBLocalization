import UIKit

final class BidiTextViewController: DemoViewController {
    init() {
        super.init(title: Feature.bidiText.title)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addSection(nil, rows: [viewRow(makeLabel(L10n.BidiText.intro, color: .secondaryLabel))])
        addSection(L10n.BidiText.sectionPhone, footer: L10n.BidiText.phoneFooter, rows: [
            caseRow(.wrong, content: sample(BidiTextDemo.phoneWrong)),
            caseRow(.right, content: sample(BidiTextDemo.phoneRight)),
        ])
        addSection(L10n.BidiText.sectionName, footer: L10n.BidiText.nameFooter, rows: [
            caseRow(.wrong, content: sample(BidiTextDemo.nameWrong)),
            caseRow(.right, content: sample(BidiTextDemo.nameRight)),
        ])
        addSection(L10n.BidiText.sectionTags, rows: [
            caseRow(.wrong, content: sample(BidiTextDemo.tagWrong)),
            caseRow(.right, content: sample(BidiTextDemo.tagRight)),
        ])
        addSection(L10n.BidiText.sectionCurrent, rows: [
            viewRow(makeLabel(BidiTextDemo.currentLanguageSample)),
        ])
        addSection(L10n.BidiText.sectionCopy, footer: L10n.BidiText.copyFooter,
                   rows: BidiTextDemo.copyRows.map { valueRow($0.0, $0.1) })
    }

    /// 阿拉伯语样例：强制 RTL 方向并右对齐，与真实阿语界面一致。
    private func sample(_ text: String) -> UILabel {
        let label = makeLabel(text, style: .title3)
        label.semanticContentAttribute = .forceRightToLeft
        label.textAlignment = .natural
        return label
    }
}
