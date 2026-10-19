import UIKit

/// UIKit 示例页基类：滚动视图 + 分组卡片，风格与 SwiftUI 的 insetGrouped List 保持一致。
///
/// 子类在 `viewDidLoad` 中调用 `addSection` 搭建内容。所有约束使用 leading/trailing，RTL 下自动镜像。
class DemoViewController: UIViewController {
    let contentStack = UIStackView()

    init(title: String) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
        navigationItem.largeTitleDisplayMode = .never
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground

        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 8
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 32, trailing: 16)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
        ])
    }

    // MARK: - 分组

    /// 添加一个分组卡片：可选标题、若干行、可选脚注。
    func addSection(_ title: String?, footer: String? = nil, rows: [UIView]) {
        if let title {
            let header = makeLabel(title, style: .footnote, color: .secondaryLabel)
            contentStack.addArrangedSubview(inset(header, leading: 16, top: 12))
        }

        let card = UIStackView()
        card.axis = .vertical
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 12
        card.layer.cornerCurve = .continuous
        card.clipsToBounds = true
        for (index, row) in rows.enumerated() {
            if index > 0 { card.addArrangedSubview(makeSeparator()) }
            card.addArrangedSubview(row)
        }
        contentStack.addArrangedSubview(card)

        if let footer {
            let label = makeLabel(footer, style: .footnote, color: .secondaryLabel)
            contentStack.addArrangedSubview(inset(label, leading: 16))
        }
    }

    // MARK: - 行

    /// 「标题 —— 值」行，使用系统 valueCell 配置。
    func valueRow(_ title: String, _ value: String) -> UIView {
        var content = UIListContentConfiguration.valueCell()
        content.text = title
        content.secondaryText = value
        content.prefersSideBySideTextAndSecondaryText = true
        return UIListContentView(configuration: content)
    }

    /// 文本行，可带副标题。
    func textRow(_ text: String, secondary: String? = nil) -> UIView {
        var content = UIListContentConfiguration.subtitleCell()
        content.text = text
        content.secondaryText = secondary
        content.secondaryTextProperties.color = .secondaryLabel
        return UIListContentView(configuration: content)
    }

    /// 带「错误示例 / 推荐做法」标记的行，`content` 为示例视图。
    func caseRow(_ verdict: DemoVerdict, content: UIView) -> UIView {
        let badge = UILabel()
        let symbol = NSTextAttachment(image: UIImage(systemName: verdict.symbolName)!.withTintColor(verdict.uiColor))
        let text = NSMutableAttributedString(attachment: symbol)
        text.append(NSAttributedString(string: " " + verdict.title))
        text.addAttributes([.foregroundColor: verdict.uiColor,
                            .font: UIFont.preferredFont(forTextStyle: .caption1).bold()],
                           range: NSRange(location: 0, length: text.length))
        badge.attributedText = text

        let stack = UIStackView(arrangedSubviews: [badge, content])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 6
        return inset(stack, leading: 16, top: 10, trailing: 16, bottom: 10)
    }

    /// 把任意视图包装成卡片中的一行（带标准边距）。
    func viewRow(_ view: UIView) -> UIView {
        inset(view, leading: 16, top: 10, trailing: 16, bottom: 10)
    }

    // MARK: - 工具

    func makeLabel(_ text: String, style: UIFont.TextStyle = .body, color: UIColor = .label, lines: Int = 0) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: style)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = color
        label.numberOfLines = lines
        // .natural：按布局方向对齐（LTR 靠左、RTL 靠右），不要写死 .left
        label.textAlignment = .natural
        return label
    }

    func inset(_ view: UIView, leading: CGFloat = 0, top: CGFloat = 0, trailing: CGFloat = 0, bottom: CGFloat = 0) -> UIView {
        let container = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: container.topAnchor, constant: top),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -bottom),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: leading),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -trailing),
        ])
        return container
    }

    private func makeSeparator() -> UIView {
        let line = UIView()
        line.backgroundColor = .separator
        line.translatesAutoresizingMaskIntoConstraints = false
        line.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
        return inset(line, leading: 16)
    }
}

extension UIFont {
    func bold() -> UIFont {
        UIFont(descriptor: fontDescriptor.withSymbolicTraits(.traitBold) ?? fontDescriptor, size: 0)
    }
}
