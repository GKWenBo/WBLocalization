import UIKit

final class SystemStringsViewController: DemoViewController {
    init() {
        super.init(title: Feature.systemStrings.title)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // 系统按钮（编辑/完成）的标题来自 UIKit，按进程启动语言显示
        navigationItem.rightBarButtonItem = editButtonItem

        addSection(L10n.SystemStrings.sectionAppName, footer: L10n.SystemStrings.appNameFooter,
                   rows: SystemStringsDemo.appNameRows.map { valueRow($0.0, $0.1) })

        addSection(L10n.SystemStrings.sectionPermissions, footer: L10n.SystemStrings.permissionFooter, rows: [
            valueRow(L10n.SystemStrings.launchLanguage, SystemStringsDemo.launchLanguage),
            viewRow(makeButton(L10n.SystemStrings.permissionCamera) { PermissionRequester.shared.requestCamera() }),
            viewRow(makeButton(L10n.SystemStrings.permissionPhotos) { PermissionRequester.shared.requestPhotos() }),
            viewRow(makeButton(L10n.SystemStrings.permissionLocation) { PermissionRequester.shared.requestLocation() }),
        ])

        // UISearchBar 的「取消」按钮文案来自系统
        let searchBar = UISearchBar()
        searchBar.showsCancelButton = true
        searchBar.searchBarStyle = .minimal
        addSection(L10n.SystemStrings.sectionControls, footer: L10n.SystemStrings.controlsFooter, rows: [searchBar])

        addSection(L10n.SystemStrings.sectionLaunch, rows: [viewRow(makeLabel(L10n.SystemStrings.launchBody))])
    }

    private func makeButton(_ title: String, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system, primaryAction: UIAction(title: title) { _ in action() })
        button.contentHorizontalAlignment = .leading
        return button
    }
}
