import SwiftUI

struct SystemStringsView: View {
    @State private var query = ""
    @State private var date = Date()

    var body: some View {
        List {
            Section {
                ForEach(SystemStringsDemo.appNameRows, id: \.0) { DemoValueRow(title: $0.0, value: $0.1) }
            } header: {
                Text(L10n.SystemStrings.sectionAppName)
            } footer: {
                Text(L10n.SystemStrings.appNameFooter)
            }

            Section {
                DemoValueRow(title: L10n.SystemStrings.launchLanguage, value: SystemStringsDemo.launchLanguage)
                Button(L10n.SystemStrings.permissionCamera) { PermissionRequester.shared.requestCamera() }
                Button(L10n.SystemStrings.permissionPhotos) { PermissionRequester.shared.requestPhotos() }
                Button(L10n.SystemStrings.permissionLocation) { PermissionRequester.shared.requestLocation() }
            } header: {
                Text(L10n.SystemStrings.sectionPermissions)
            } footer: {
                Text(L10n.SystemStrings.permissionFooter)
            }

            Section {
                // EditButton 的标题来自系统框架；DatePicker 读取环境 \.locale
                HStack {
                    Text(verbatim: "EditButton()").font(.system(.footnote, design: .monospaced)).foregroundColor(.secondary)
                    Spacer()
                    EditButton()
                }
                DatePicker(selection: $date, displayedComponents: .date) {
                    Text(verbatim: "DatePicker").font(.system(.footnote, design: .monospaced)).foregroundColor(.secondary)
                }
            } header: {
                Text(L10n.SystemStrings.sectionControls)
            } footer: {
                Text(L10n.SystemStrings.controlsFooter)
            }

            Section(L10n.SystemStrings.sectionLaunch) {
                Text(L10n.SystemStrings.launchBody)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(Feature.systemStrings.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
