import Testing
@testable import WBLocalizationKit

struct BidiTextTests {
    @Test func wrapping() {
        #expect("+86 138".forcedLeftToRight == "\u{2066}+86 138\u{2069}")
        #expect("Tom".bidiIsolated == "\u{2068}Tom\u{2069}")
        #expect("abc".forcedRightToLeft == "\u{2067}abc\u{2069}")
    }

    @Test func removingControls() {
        let text = "رقم \("+86 138".forcedLeftToRight)\u{200F}"
        #expect(text.removingBidiControls == "رقم +86 138")
    }
}
