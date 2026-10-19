import UIKit

final class LongTextViewController: DemoViewController {
    init() {
        super.init(title: Feature.longText.title)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let truncated = makeLabel(L10n.LongText.sample, lines: 1)
        truncated.widthAnchor.constraint(equalToConstant: 200).isActive = true
        addSection(L10n.LongText.sectionTruncation, footer: L10n.LongText.truncationFooter, rows: [
            caseRow(.wrong, content: leadingAligned(truncated)),
            caseRow(.right, content: makeLabel(L10n.LongText.sample)),
        ])

        let fixed = UIStackView(arrangedSubviews: [makeButton(L10n.LongText.buttonLater, primary: false, fixedWidth: 110),
                                                   makeButton(L10n.LongText.buttonEnable, primary: true, fixedWidth: 110)])
        fixed.spacing = 8
        let adaptive = AdaptiveButtonStack(arrangedSubviews: [makeButton(L10n.LongText.buttonLater, primary: false),
                                                              makeButton(L10n.LongText.buttonEnable, primary: true)])
        addSection(L10n.LongText.sectionButtons, footer: L10n.LongText.buttonsFooter, rows: [
            caseRow(.wrong, content: leadingAligned(fixed)),
            caseRow(.right, content: adaptive),
        ])

        addSection(L10n.LongText.sectionCompound, footer: L10n.LongText.compoundFooter, rows: [
            caseRow(.wrong, content: leadingAligned(compoundLabel(hyphenated: false))),
            caseRow(.right, content: leadingAligned(compoundLabel(hyphenated: true))),
        ])
    }

    /// 窄宽度下展示长复合词。
    /// - 反例：单行，被截断。
    /// - 正例：多行 + 断字。实测 iOS 27 的 UILabel 对德语默认断字，低版本需显式设置 hyphenationFactor。
    private func compoundLabel(hyphenated: Bool) -> UILabel {
        let label = makeLabel("", style: .title2, lines: hyphenated ? 0 : 1)
        let style = NSMutableParagraphStyle()
        style.hyphenationFactor = hyphenated ? 1 : 0
        style.lineBreakMode = hyphenated ? .byWordWrapping : .byTruncatingTail
        label.attributedText = NSAttributedString(string: L10n.LongText.compound, attributes: [
            .paragraphStyle: style,
            .font: UIFont.preferredFont(forTextStyle: .title2),
        ])
        label.widthAnchor.constraint(equalToConstant: 160).isActive = true
        return label
    }

    private func makeButton(_ title: String, primary: Bool, fixedWidth: CGFloat? = nil) -> UIButton {
        var configuration: UIButton.Configuration = primary ? .filled() : .gray()
        configuration.title = title
        configuration.titleLineBreakMode = .byTruncatingTail
        let button = UIButton(configuration: configuration)
        if let fixedWidth {
            button.widthAnchor.constraint(equalToConstant: fixedWidth).isActive = true
        }
        return button
    }

    private func leadingAligned(_ view: UIView) -> UIView {
        let stack = UIStackView(arrangedSubviews: [view, UIView()])
        stack.alignment = .top
        return stack
    }
}

/// 根据可用宽度自动在横排 / 竖排之间切换的 UIStackView。
/// iOS 15 的 UIKit 没有 ViewThatFits，这里比较子视图的固有宽度之和与自身宽度。
final class AdaptiveButtonStack: UIStackView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        spacing = 8
        alignment = .leading
    }

    convenience init(arrangedSubviews views: [UIView]) {
        self.init(frame: .zero)
        views.forEach(addArrangedSubview)
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        let required = arrangedSubviews.reduce(0) { $0 + $1.intrinsicContentSize.width }
            + spacing * CGFloat(max(arrangedSubviews.count - 1, 0))
        let newAxis: NSLayoutConstraint.Axis = required > bounds.width ? .vertical : .horizontal
        if bounds.width > 0, axis != newAxis {
            axis = newAxis
        }
        super.layoutSubviews()
    }
}
