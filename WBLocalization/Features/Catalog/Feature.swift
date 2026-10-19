import Foundation

/// 功能目录中的适配点，SwiftUI 与 UIKit 两个目录共用这份数据。
enum Feature: String, CaseIterable, Identifiable {
    case basicText, plurals, formatting, bidiText
    case rtlLayout, longText, typography, images, input
    case systemStrings, serverContent

    var id: String { rawValue }

    /// 文案 key 由 rawValue 拼接，对应 `feature.<rawValue>.title / .subtitle`。
    /// 动态 key 无法被 Xcode 自动提取，需在 String Catalog 中手动维护（extractionState = manual）。
    var title: String {
        Bundle.localized.localizedString(forKey: "feature.\(rawValue).title", value: nil, table: nil)
    }

    var subtitle: String {
        Bundle.localized.localizedString(forKey: "feature.\(rawValue).subtitle", value: nil, table: nil)
    }

    var symbolName: String {
        switch self {
        case .basicText: "textformat"
        case .plurals: "number"
        case .formatting: "calendar"
        case .bidiText: "arrow.left.arrow.right"
        case .rtlLayout: "rectangle.lefthalf.inset.filled.arrow.left"
        case .longText: "text.alignleft"
        case .typography: "character.book.closed"
        case .images: "photo"
        case .input: "keyboard"
        case .systemStrings: "gearshape"
        case .serverContent: "network"
        }
    }
}

/// 目录分组。
enum FeatureSection: CaseIterable, Identifiable {
    case text, layout, system

    var id: Self { self }

    var title: String {
        switch self {
        case .text: L10n.Catalog.sectionText
        case .layout: L10n.Catalog.sectionLayout
        case .system: L10n.Catalog.sectionSystem
        }
    }

    var features: [Feature] {
        switch self {
        case .text: [.basicText, .plurals, .formatting, .bidiText]
        case .layout: [.rtlLayout, .longText, .typography, .images, .input]
        case .system: [.systemStrings, .serverContent]
        }
    }
}
