import AVFoundation
import CoreLocation
import Foundation
import Photos

enum SystemStringsDemo {
    static var appNameRows: [(String, String)] {
        let key = "CFBundleDisplayName"
        return [
            // Info.plist 中的原始值（开发语言）
            (L10n.SystemStrings.appNameBase, Bundle.main.infoDictionary?[key] as? String ?? ""),
            // 系统按进程启动语言解析，App 内切换后不变
            (L10n.SystemStrings.appNameSystem, Bundle.main.localizedInfoDictionary?[key] as? String ?? ""),
            // 从 InfoPlist.strings 表中按 App 当前语言读取
            (L10n.SystemStrings.appNameCurrent, Bundle.localized.localizedString(forKey: key, value: nil, table: "InfoPlist")),
        ]
    }

    /// 进程启动时的首选语言（Locale.preferredLanguages 在进程内缓存，不随 App 内切换变化）。
    static var launchLanguage: String {
        (Locale.preferredLanguages.first ?? "").forcedLeftToRight
    }
}

/// 触发系统权限弹窗。弹窗由系统绘制，文案来自 InfoPlist.xcstrings。
@MainActor
final class PermissionRequester: NSObject {
    static let shared = PermissionRequester()
    private let locationManager = CLLocationManager()

    func requestCamera() {
        AVCaptureDevice.requestAccess(for: .video) { _ in }
    }

    func requestPhotos() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { _ in }
    }

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
    }
}
