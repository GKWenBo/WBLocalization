import Foundation
import Testing

/// 测试辅助：每次复制一份独立的 fixture bundle 与 UserDefaults，
/// 避免 object_setClass / 覆盖状态在并行测试之间互相干扰。
enum Fixture {
    static func makeBundle() throws -> Bundle {
        let source = try #require(Bundle.module.url(forResource: "Fixture", withExtension: "bundle"))
        let destination = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("Fixture.bundle")
        try FileManager.default.createDirectory(
            at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
        try FileManager.default.copyItem(at: source, to: destination)
        return try #require(Bundle(url: destination))
    }

    static func makeDefaults() -> UserDefaults {
        let name = "WBLocalizationKitTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }
}
