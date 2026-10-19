import UIKit

final class PluralsViewController: DemoViewController {
    private var count = 1 { didSet { updateSingle() } }
    private var files = 3 { didSet { updateMulti() } }
    private var folders = 1 { didSet { updateMulti() } }

    private lazy var countRow = StepperRow(value: count, range: 0...120) { [weak self] in self?.count = $0 }
    private lazy var filesRow = StepperRow(value: files, range: 0...30) { [weak self] in self?.files = $0 }
    private lazy var foldersRow = StepperRow(value: folders, range: 0...30) { [weak self] in self?.folders = $0 }
    private lazy var singleLabel = makeLabel("", style: .headline)
    private lazy var multiLabel = makeLabel("", style: .headline)

    init() {
        super.init(title: Feature.plurals.title)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addSection(L10n.Plurals.sectionSingle, footer: L10n.Plurals.singleFooter, rows: [
            viewRow(countRow), viewRow(singleLabel),
        ])
        addSection(L10n.Plurals.sectionMulti, footer: L10n.Plurals.multiFooter, rows: [
            viewRow(filesRow), viewRow(foldersRow), viewRow(multiLabel),
        ])
        addSection(L10n.Plurals.sectionTable, footer: L10n.Plurals.tableFooter, rows: PluralsDemo.sampleCounts.map {
            valueRow(PluralsDemo.number($0), L10n.Plurals.files($0))
        })

        updateSingle()
        updateMulti()
    }

    private func updateSingle() {
        countRow.title = "\(L10n.Plurals.countLabel)  \(PluralsDemo.number(count))"
        singleLabel.text = L10n.Plurals.files(count)
    }

    private func updateMulti() {
        filesRow.title = "\(L10n.Plurals.filesLabel)  \(PluralsDemo.number(files))"
        foldersRow.title = "\(L10n.Plurals.foldersLabel)  \(PluralsDemo.number(folders))"
        multiLabel.text = L10n.Plurals.summary(files: files, folders: folders)
    }
}

/// 标题 + UIStepper。UIStepper 在 RTL 下会自动交换 +/- 位置。
final class StepperRow: UIView {
    private let label = UILabel()
    private let stepper = UIStepper()
    private let onChange: (Int) -> Void

    var title: String? {
        get { label.text }
        set { label.text = newValue }
    }

    init(value: Int, range: ClosedRange<Int>, onChange: @escaping (Int) -> Void) {
        self.onChange = onChange
        super.init(frame: .zero)
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        stepper.minimumValue = Double(range.lowerBound)
        stepper.maximumValue = Double(range.upperBound)
        stepper.value = Double(value)
        stepper.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        stepper.setContentHuggingPriority(.required, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [label, stepper])
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func valueChanged() {
        onChange(Int(stepper.value))
    }
}
