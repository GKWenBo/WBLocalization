import CoreText
import UIKit

final class TypographyViewController: DemoViewController {
    init() {
        super.init(title: Feature.typography.title)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addSection(L10n.Typography.sectionCJK, footer: L10n.Typography.cjkFooter, rows: [
            caseRow(.wrong, content: cjkSamples(code: "UILabel.text", tagged: false)),
            caseRow(.right, content: cjkSamples(code: "kCTLanguageAttributeName", tagged: true)),
        ])

        addSection(L10n.Typography.sectionArabic, footer: L10n.Typography.arabicFooter, rows: [
            caseRow(.wrong, content: arabicLabel(fixedLineHeight: true)),
            caseRow(.right, content: arabicLabel(fixedLineHeight: false)),
        ])

        let custom = makeLabel(TypographyDemo.mixedScripts)
        custom.font = UIFont(name: TypographyDemo.customFontName, size: 24)
        let system = makeLabel(TypographyDemo.mixedScripts)
        system.font = .systemFont(ofSize: 24, weight: .heavy)
        addSection(L10n.Typography.sectionFallback, footer: L10n.Typography.fallbackFooter, rows: [
            caseRow(.wrong, content: custom),
            caseRow(.right, content: system),
        ])
    }

    /// `tagged` 时通过 kCTLanguageAttributeName 标注文本语言，系统据此选择中文或日文字形；
    /// 不标注时两行都跟随 App 的启动语言。
    private func cjkSamples(code: String, tagged: Bool) -> UIView {
        let codeLabel = makeLabel(code, color: .secondaryLabel)
        codeLabel.font = .monospacedSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .regular)
        let rows = TypographyDemo.cjkLanguages.map { language -> UIView in
            var attributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .largeTitle)]
            if tagged { attributes[NSAttributedString.Key(kCTLanguageAttributeName as String)] = language }
            let sample = makeLabel("")
            sample.attributedText = NSAttributedString(string: TypographyDemo.hanCharacters, attributes: attributes)
            let name = makeLabel(TypographyDemo.languageName(language), style: .caption1, color: .secondaryLabel)
            name.widthAnchor.constraint(equalToConstant: 64).isActive = true
            let row = UIStackView(arrangedSubviews: [name, sample])
            row.alignment = .center
            row.spacing = 8
            return row
        }
        let stack = UIStackView(arrangedSubviews: [codeLabel] + rows)
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }

    private func arabicLabel(fixedLineHeight: Bool) -> UILabel {
        let label = makeLabel("", style: .title1)
        let font = UIFont.preferredFont(forTextStyle: .title1)
        let style = NSMutableParagraphStyle()
        if fixedLineHeight {
            // 常见错误：按设计稿把行高写死为字号，并裁切超出部分
            style.minimumLineHeight = font.pointSize
            style.maximumLineHeight = font.pointSize
            label.clipsToBounds = true
        }
        label.attributedText = NSAttributedString(string: TypographyDemo.arabic, attributes: [.font: font, .paragraphStyle: style])
        return label
    }
}
