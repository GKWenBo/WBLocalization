import SwiftUI

/// 示例页通用的 SwiftUI 组件。全部使用 leading/trailing 语义，RTL 下自动镜像。

/// 「标题 —— 值」行。
struct DemoValueRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            Text(title)
            Spacer(minLength: 0)
            Text(value)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}

/// 对比示例的结论标记：错误示例 / 推荐做法。
enum DemoVerdict {
    case wrong, right

    var title: String { self == .wrong ? L10n.Common.wrong : L10n.Common.right }
    var symbolName: String { self == .wrong ? "xmark.circle.fill" : "checkmark.circle.fill" }
    var color: Color { self == .wrong ? .red : .green }
    var uiColor: UIColor { self == .wrong ? .systemRed : .systemGreen }
}

/// 带结论标记的示例：上方小标签，下方为示例内容。
struct DemoCase<Content: View>: View {
    let verdict: DemoVerdict
    let content: Content

    init(_ verdict: DemoVerdict, @ViewBuilder content: () -> Content) {
        self.verdict = verdict
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(verdict.title, systemImage: verdict.symbolName)
                .font(.caption.weight(.semibold))
                .foregroundColor(verdict.color)
            content
        }
        .padding(.vertical, 2)
    }
}
