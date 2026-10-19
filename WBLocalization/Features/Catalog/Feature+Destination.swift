import SwiftUI
import UIKit

/// 每个适配点在两端的入口页面。新增功能时在这里注册即可。
extension Feature {
    @MainActor @ViewBuilder
    var swiftUIDestination: some View {
        switch self {
        case .basicText: BasicTextView()
        case .plurals: PluralsView()
        case .formatting: FormattingView()
        case .bidiText: BidiTextView()
        case .rtlLayout: RTLLayoutView()
        case .longText: LongTextView()
        case .typography: TypographyView()
        case .images: ImagesView()
        case .input: InputView()
        case .systemStrings: SystemStringsView()
        case .serverContent: ServerContentView()
        }
    }

    @MainActor
    func makeViewController() -> UIViewController {
        switch self {
        case .basicText: BasicTextViewController()
        case .plurals: PluralsViewController()
        case .formatting: FormattingViewController()
        case .bidiText: BidiTextViewController()
        case .rtlLayout: RTLLayoutViewController()
        case .longText: LongTextViewController()
        case .typography: TypographyViewController()
        case .images: ImagesViewController()
        case .input: InputViewController()
        case .systemStrings: SystemStringsViewController()
        case .serverContent: ServerContentViewController()
        }
    }
}
