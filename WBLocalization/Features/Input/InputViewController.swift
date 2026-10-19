import UIKit

final class InputViewController: DemoViewController {
    init() {
        super.init(title: Feature.input.title)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let leftAligned = makeField(placeholder: L10n.Input.namePlaceholder)
        leftAligned.textAlignment = .left
        let natural = makeField(placeholder: L10n.Input.namePlaceholder)
        natural.textAlignment = .natural
        addSection(L10n.Input.sectionAlignment, footer: L10n.Input.alignmentFooter, rows: [
            caseRow(.wrong, content: leftAligned),
            caseRow(.right, content: natural),
        ])

        addSection(L10n.Input.sectionPhone, footer: L10n.Input.phoneFooter, rows: [
            caseRow(.wrong, content: phoneGroup(forceLTR: false)),
            caseRow(.right, content: phoneGroup(forceLTR: true)),
        ])

        addSection(L10n.Input.sectionParsing, footer: L10n.Input.parsingFooter, rows: [
            valueRow(L10n.Input.parsingInput, InputDemo.arabicInput),
        ] + InputDemo.parsingRows.map { item in
            let code = makeLabel(item.code, color: .secondaryLabel)
            code.font = .monospacedSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .regular)
            let stack = UIStackView(arrangedSubviews: [code, makeLabel(item.result)])
            stack.axis = .vertical
            stack.spacing = 4
            return caseRow(item.verdict, content: stack)
        })
    }

    /// 手机号输入框 + 验证码格子。强制 LTR 时，输入框内容方向和格子顺序都保持从左到右。
    private func phoneGroup(forceLTR: Bool) -> UIView {
        let field = makeField(placeholder: nil)
        field.text = InputDemo.phone
        field.keyboardType = .phonePad
        field.textContentType = .telephoneNumber

        let boxes = UIStackView(arrangedSubviews: InputDemo.code.map(makeCodeBox))
        boxes.spacing = 8
        let boxesRow = UIStackView(arrangedSubviews: [boxes, UIView()])

        if forceLTR {
            [field, boxes, boxesRow].forEach { $0.semanticContentAttribute = .forceLeftToRight }
        }
        let stack = UIStackView(arrangedSubviews: [field, boxesRow])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }

    private func makeField(placeholder: String?) -> UITextField {
        let field = UITextField()
        field.placeholder = placeholder
        field.borderStyle = .roundedRect
        field.font = .preferredFont(forTextStyle: .body)
        field.adjustsFontForContentSizeCategory = true
        return field
    }

    private func makeCodeBox(_ digit: String) -> UIView {
        let label = UILabel()
        label.text = digit
        label.font = .monospacedDigitSystemFont(ofSize: 22, weight: .regular)
        label.textAlignment = .center
        label.layer.borderColor = UIColor.separator.cgColor
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 8
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: 36),
            label.heightAnchor.constraint(equalToConstant: 44),
        ])
        return label
    }
}
