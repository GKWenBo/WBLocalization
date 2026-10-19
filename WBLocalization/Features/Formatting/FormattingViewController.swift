import UIKit

final class FormattingViewController: DemoViewController {
    init() {
        super.init(title: Feature.formatting.title)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // UIKit 中的 UIDatePicker、UICalendarView 等系统控件需要显式设置 locale，否则使用系统语言
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = FormattingDemo.formatters.locale
        picker.calendar = FormattingDemo.formatters.locale.calendar
        let pickerRow = UIStackView(arrangedSubviews: [makeLabel("UIDatePicker.locale", style: .body), picker])
        pickerRow.spacing = 12

        addSection(L10n.Formatting.sectionDate, footer: L10n.Formatting.dateFooter,
                   rows: FormattingDemo.dateRows.map { valueRow($0.0, $0.1) } + [viewRow(pickerRow)])
        addSection(L10n.Formatting.sectionNumber, footer: L10n.Formatting.numberFooter,
                   rows: FormattingDemo.numberRows.map { valueRow($0.0, $0.1) })
        addSection(L10n.Formatting.sectionUnits, footer: L10n.Formatting.unitsFooter,
                   rows: FormattingDemo.unitRows.map { valueRow($0.0, $0.1) })
        addSection(L10n.Formatting.sectionPitfalls, footer: L10n.Formatting.pitfallsFooter,
                   rows: FormattingDemo.pitfalls.map { item in
                       let code = makeLabel(item.code, color: .secondaryLabel)
                       code.font = .monospacedSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .regular)
                       let stack = UIStackView(arrangedSubviews: [code, makeLabel(item.result)])
                       stack.axis = .vertical
                       stack.spacing = 4
                       return caseRow(item.verdict, content: stack)
                   })
    }
}
