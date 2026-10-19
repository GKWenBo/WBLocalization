import Foundation
import WBLocalizationKit

enum TypographyDemo {
    /// 中日字形差异明显的汉字。
    static let hanCharacters = "令 刃 着 遍 骨 直"
    static let cjkLanguages = ["zh-Hans", "ja"]
    /// 带完整音标（tashkeel）的阿拉伯语：「阿拉伯语很美」。
    static let arabic = "اللُّغَةُ الْعَرَبِيَّةُ جَمِيلَةٌ"
    static let mixedScripts = "Hello 你好 مرحبا Привет"
    /// 自定义字体只覆盖拉丁/西里尔字母，用于演示其它文字的回退。
    static let customFontName = "AvenirNext-Heavy"

    /// 为文本标注语言，系统据此选择中文或日文字形。
    static func attributedHan(language code: String) -> AttributedString {
        var text = AttributedString(hanCharacters)
        text.languageIdentifier = code
        return text
    }

    static func languageName(_ code: String) -> String {
        AppLanguage.specific(code).nativeName ?? code
    }
}
