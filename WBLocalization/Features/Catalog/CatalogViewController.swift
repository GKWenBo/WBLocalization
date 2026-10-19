import UIKit

/// UIKit 功能目录。
final class CatalogViewController: UITableViewController {
    private let sections = FeatureSection.allCases
    private let cellID = "FeatureCell"

    init() {
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.Catalog.uiKitTitle
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].features.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let feature = sections[indexPath.section].features[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        // UIListContentConfiguration 与 disclosureIndicator 会随布局方向自动镜像，无需手动处理
        var content = UIListContentConfiguration.subtitleCell()
        content.text = feature.title
        content.secondaryText = feature.subtitle
        content.secondaryTextProperties.color = .secondaryLabel
        content.image = UIImage(systemName: feature.symbolName)
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feature = sections[indexPath.section].features[indexPath.row]
        navigationController?.pushViewController(feature.makeViewController(), animated: true)
    }
}
