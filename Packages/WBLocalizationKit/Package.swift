// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WBLocalizationKit",
    // macOS 仅用于在命令行执行 `swift test`，框架面向 iOS
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "WBLocalizationKit", targets: ["WBLocalizationKit"]),
    ],
    targets: [
        .target(name: "WBLocalizationKit"),
        .testTarget(
            name: "WBLocalizationKitTests",
            dependencies: ["WBLocalizationKit"],
            resources: [.copy("Resources/Fixture.bundle")]
        ),
    ]
)
