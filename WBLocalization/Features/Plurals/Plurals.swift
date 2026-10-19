import Foundation
import WBLocalizationKit

enum PluralsDemo {
    /// 覆盖各语言主要复数类别的样例数字：0、1、2、3–4、5–10、11–19、21、22、100、101。
    static let sampleCounts = [0, 1, 2, 3, 5, 11, 21, 22, 100, 101]

    /// 数字本身也要本地化（阿拉伯语地区可能使用 ٠١٢٣）。
    static func number(_ value: Int) -> String {
        LocalizedFormatters.current.number(Double(value))
    }
}
