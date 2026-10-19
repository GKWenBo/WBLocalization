import SwiftUI
import UIKit

/// 每个适配点在两端的入口页面。新增功能时在这里注册即可。
extension Feature {
    @MainActor @ViewBuilder
    var swiftUIDestination: some View {
        switch self {
        default:
            PlaceholderView(feature: self)
        }
    }

    @MainActor
    func makeViewController() -> UIViewController {
        switch self {
        default:
            PlaceholderViewController(feature: self)
        }
    }
}

/// 尚未实现的功能占位页。
struct PlaceholderView: View {
    let feature: Feature

    var body: some View {
        Text(L10n.Common.comingSoon)
            .foregroundColor(.secondary)
            .navigationTitle(feature.title)
    }
}

final class PlaceholderViewController: UIViewController {
    private let feature: Feature

    init(feature: Feature) {
        self.feature = feature
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = feature.title
        view.backgroundColor = .systemBackground

        let label = UILabel()
        label.text = L10n.Common.comingSoon
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
