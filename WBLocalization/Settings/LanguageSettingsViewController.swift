import UIKit
import WBLocalizationKit

/// 语言设置：App 内即时切换 + 跳转系统设置。
///
/// 选择语言后 `LocalizationManager` 发出通知，AppDelegate 统一重建界面，本页无需自行刷新。
final class LanguageSettingsViewController: UITableViewController {
    private enum Section: Int, CaseIterable {
        case languages, status, system
    }

    private let manager = LocalizationManager.shared
    private let cellID = "Cell"

    init() {
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.Tab.settings
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }

    // MARK: - 数据

    /// 当前状态区的行：标题 + 值。
    private var statusRows: [(title: String, value: String)] {
        let resolved = AppLanguage.specific(manager.resolvedCode)
        return [
            (L10n.Settings.statusLanguage, resolved.nativeName ?? manager.resolvedCode),
            // Locale 标识符是给开发者看的代码，强制 LTR，避免在阿语界面中下划线、连字符位置错乱
            (L10n.Settings.statusLocale, manager.locale.identifier.forcedLeftToRight),
            (L10n.Settings.statusDirection, manager.isRightToLeft ? L10n.Settings.directionRTL : L10n.Settings.directionLTR),
        ]
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .languages: L10n.Settings.sectionLanguage
        case .status: L10n.Settings.sectionStatus
        case .system: L10n.Settings.sectionSystem
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        Section(rawValue: section) == .system ? L10n.Settings.systemFooter : nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .languages: manager.availableLanguages.count
        case .status: statusRows.count
        case .system: 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.accessoryType = .none
        cell.selectionStyle = .default

        switch Section(rawValue: indexPath.section)! {
        case .languages:
            let language = manager.availableLanguages[indexPath.row]
            cell.contentConfiguration = languageContent(for: language)
            cell.accessoryType = language == manager.language ? .checkmark : .none
        case .status:
            let row = statusRows[indexPath.row]
            var content = UIListContentConfiguration.valueCell()
            content.text = row.title
            content.secondaryText = row.value
            cell.contentConfiguration = content
            cell.selectionStyle = .none
        case .system:
            var content = UIListContentConfiguration.cell()
            content.text = L10n.Settings.openSystemSettings
            content.textProperties.color = .tintColor
            cell.contentConfiguration = content
        }
        return cell
    }

    /// 主标题用语言自身的名称（用户切错语言后仍能认出自己的母语），副标题用当前语言下的译名。
    private func languageContent(for language: AppLanguage) -> UIListContentConfiguration {
        var content = UIListContentConfiguration.subtitleCell()
        switch language {
        case .system:
            content.text = L10n.Settings.followSystem
        case .specific:
            content.text = language.nativeName
            let translated = language.displayName(in: manager.locale)
            content.secondaryText = translated == language.nativeName ? nil : translated
            content.secondaryTextProperties.color = .secondaryLabel
        }
        return content
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        Section(rawValue: indexPath.section) != .status
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch Section(rawValue: indexPath.section)! {
        case .languages:
            manager.setLanguage(manager.availableLanguages[indexPath.row])
        case .status:
            break
        case .system:
            manager.openSystemLanguageSettings()
        }
    }
}
