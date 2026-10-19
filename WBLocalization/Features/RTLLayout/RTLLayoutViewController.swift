import UIKit

final class RTLLayoutViewController: DemoViewController {
    private let wrongDot = RTLLayoutViewController.makeDot()
    private let rightDot = RTLLayoutViewController.makeDot()
    private var moved = false

    init() {
        super.init(title: Feature.rtlLayout.title)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let progress = UIProgressView(progressViewStyle: .default)
        progress.progress = 0.3
        let slider = UISlider()
        slider.value = 0.6
        addSection(L10n.RTLLayout.sectionAuto, footer: L10n.RTLLayout.autoFooter, rows: [
            viewRow(makeSettingRow()),
            viewRow(labeled(L10n.RTLLayout.progress, progress)),
            viewRow(slider),
            // 实测：UIScrollView 和 UICollectionView 的内容都会镜像，但初始偏移都在最左侧，
            // RTL 用户一进来看到的是最后几项（SwiftUI 的 ScrollView 则会自动从右侧开始）
            caseRow(.wrong, content: CardsCollectionView(startsAtLeadingEdge: false)),
            caseRow(.right, content: CardsCollectionView(startsAtLeadingEdge: true)),
        ])

        addSection(L10n.RTLLayout.sectionIcons, footer: L10n.RTLLayout.iconsFooter, rows: [
            viewRow(iconRow(L10n.RTLLayout.iconsMirror,
                            images: RTLLayoutDemo.mirroredSymbols.map { (UIImage(systemName: $0), $0) }
                                + [(UIImage(named: RTLLayoutDemo.customArrow), RTLLayoutDemo.customArrow)])),
            viewRow(iconRow(L10n.RTLLayout.iconsKeep,
                            images: RTLLayoutDemo.fixedSymbols.map { (UIImage(systemName: $0), $0) })),
        ])

        let play = UIButton(type: .system)
        play.setTitle(L10n.RTLLayout.animationPlay, for: .normal)
        play.contentHorizontalAlignment = .leading
        play.addTarget(self, action: #selector(playAnimation), for: .touchUpInside)
        addSection(L10n.RTLLayout.sectionAnimation, footer: L10n.RTLLayout.animationFooter, rows: [
            caseRow(.wrong, content: track(code: "CGAffineTransform(translationX: 120, y: 0)", dot: wrongDot)),
            caseRow(.right, content: track(code: "translationX: isRightToLeft ? -120 : 120", dot: rightDot)),
            viewRow(play),
        ])

        let rightPlayer = makePlayerBar()
        // .playback：媒体控件语义，在 RTL 下仍保持从左到右
        rightPlayer.semanticContentAttribute = .playback
        rightPlayer.arrangedSubviews.forEach { $0.semanticContentAttribute = .playback }
        addSection(L10n.RTLLayout.sectionForced, footer: L10n.RTLLayout.forcedFooter, rows: [
            caseRow(.wrong, content: makePlayerBar()),
            caseRow(.right, content: rightPlayer),
        ])
    }

    // MARK: - 动画

    @objc private func playAnimation() {
        moved.toggle()
        let distance = RTLLayoutDemo.animationDistance
        // isRightToLeft 来自 WBLocalizationKit：读取视图实际生效的方向
        let direction: CGFloat = view.isRightToLeft ? -1 : 1
        UIView.animate(withDuration: 0.6) {
            self.wrongDot.transform = self.moved ? CGAffineTransform(translationX: distance, y: 0) : .identity
            self.rightDot.transform = self.moved ? CGAffineTransform(translationX: distance * direction, y: 0) : .identity
        }
    }

    private func track(code: String, dot: UIView) -> UIView {
        let codeLabel = makeLabel(code, color: .secondaryLabel)
        codeLabel.font = .monospacedSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .regular)
        let container = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(dot)
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 24),
            dot.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            dot.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 24),
            dot.heightAnchor.constraint(equalToConstant: 24),
        ])
        let stack = UIStackView(arrangedSubviews: [codeLabel, container])
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }

    private static func makeDot() -> UIView {
        let dot = UIView()
        dot.backgroundColor = .tintColor
        dot.layer.cornerRadius = 12
        return dot
    }

    // MARK: - 视图

    private func makeSettingRow() -> UIView {
        let icon = UIImageView(image: UIImage(systemName: "bell.fill"))
        icon.tintColor = .systemOrange
        let chevron = UIImageView(image: UIImage(systemName: "chevron.forward"))
        chevron.tintColor = .tertiaryLabel
        let value = makeLabel(L10n.RTLLayout.rowValue, color: .secondaryLabel)
        value.setContentHuggingPriority(.required, for: .horizontal)
        [icon, chevron].forEach {
            $0.contentMode = .scaleAspectFit
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
        let stack = UIStackView(arrangedSubviews: [icon, makeLabel(L10n.RTLLayout.rowTitle), value, chevron])
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }

    private func labeled(_ title: String, _ view: UIView) -> UIView {
        let stack = UIStackView(arrangedSubviews: [makeLabel(title, style: .subheadline), view])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }

    private func iconRow(_ title: String, images: [(UIImage?, String)]) -> UIView {
        let icons = images.map { image, caption -> UIView in
            let imageView = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
            let label = UILabel()
            label.text = caption
            label.font = .monospacedSystemFont(ofSize: 9, weight: .regular)
            label.textColor = .secondaryLabel
            label.numberOfLines = 2
            label.textAlignment = .center
            let stack = UIStackView(arrangedSubviews: [imageView, label])
            stack.axis = .vertical
            stack.spacing = 4
            return stack
        }
        let row = UIStackView(arrangedSubviews: icons)
        row.distribution = .fillEqually
        row.alignment = .top
        row.spacing = 8
        let titleLabel = makeLabel(title, style: .subheadline)
        titleLabel.font = .preferredFont(forTextStyle: .subheadline).bold()
        let stack = UIStackView(arrangedSubviews: [titleLabel, row])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }

    private func makePlayerBar() -> UIStackView {
        let symbols = ["backward.fill", "play.fill", "forward.fill"].map { UIImageView(image: UIImage(systemName: $0)) }
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progress = 0.3
        let stack = UIStackView(arrangedSubviews: symbols + [progress])
        stack.spacing = 16
        stack.alignment = .center
        return stack
    }
}

/// 横向卡片列表。`startsAtLeadingEdge` 时首次布局后滚动到起始边（RTL 为最右侧）。
final class CardsCollectionView: UICollectionView, UICollectionViewDataSource {
    private let cellID = "Card"
    private var needsInitialScroll: Bool

    init(startsAtLeadingEdge: Bool) {
        needsInitialScroll = startsAtLeadingEdge
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 64, height: 64)
        layout.minimumLineSpacing = 8
        super.init(frame: .zero, collectionViewLayout: layout)
        backgroundColor = .clear
        showsHorizontalScrollIndicator = false
        dataSource = self
        register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        heightAnchor.constraint(equalToConstant: 64).isActive = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 等内容尺寸确定后再调整一次；scrollToLeadingEdge 来自 WBLocalizationKit
        if needsInitialScroll, contentSize.width > bounds.width, bounds.width > 0 {
            needsInitialScroll = false
            scrollToLeadingEdge()
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        RTLLayoutDemo.cardCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let card = Self.makeCard(indexPath.item)
        cell.contentView.addSubview(card)
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            card.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            card.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
        ])
        return cell
    }

    static func makeCard(_ index: Int) -> UIView {
        let label = UILabel()
        label.text = RTLLayoutDemo.cardTitle(index)
        label.font = .preferredFont(forTextStyle: .title2).bold()
        label.textAlignment = .center
        label.backgroundColor = .tintColor.withAlphaComponent(0.15)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: 64).withPriority(.defaultHigh),
            label.heightAnchor.constraint(equalToConstant: 64).withPriority(.defaultHigh),
        ])
        return label
    }
}

extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
