import UIKit
import WBLocalizationKit

final class ImagesViewController: DemoViewController {
    init() {
        super.init(title: Feature.images.title)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let banner = UIImageView(image: UIImage(named: "GreetingBanner"))
        banner.contentMode = .scaleAspectFit
        banner.heightAnchor.constraint(equalToConstant: 100).isActive = true
        addSection(L10n.Images.sectionLocalized, footer: L10n.Images.localizedFooter, rows: [viewRow(banner)])

        let arrow = UIImage(systemName: "arrow.right")
        addSection(L10n.Images.sectionDirection, footer: L10n.Images.directionFooter, rows: [
            row(#"UIImage(named: "ForwardArrow")  // Direction: Left to Right"#, .right, UIImage(named: "ForwardArrow")),
            row(#"UIImage(systemName: "arrow.right")"#, .wrong, arrow),
            // directional 来自 WBLocalizationKit，等价于 imageFlippedForRightToLeftLayoutDirection()
            row(".imageFlippedForRightToLeftLayoutDirection()", .right, arrow?.directional),
        ])
    }

    private func row(_ code: String, _ verdict: DemoVerdict, _ image: UIImage?) -> UIView {
        let imageView = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 32),
            imageView.heightAnchor.constraint(equalToConstant: 32),
        ])
        let codeLabel = makeLabel(code, color: .secondaryLabel)
        codeLabel.font = .monospacedSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .regular)
        let stack = UIStackView(arrangedSubviews: [imageView, codeLabel])
        stack.spacing = 12
        stack.alignment = .center
        return caseRow(verdict, content: stack)
    }
}
