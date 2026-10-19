import SwiftUI

struct PluralsView: View {
    @State private var count = 1
    @State private var files = 3
    @State private var folders = 1

    var body: some View {
        List {
            Section {
                Stepper(value: $count, in: 0...120) {
                    DemoValueRow(title: L10n.Plurals.countLabel, value: PluralsDemo.number(count))
                }
                Text(L10n.Plurals.files(count))
                    .font(.headline)
            } header: {
                Text(L10n.Plurals.sectionSingle)
            } footer: {
                Text(L10n.Plurals.singleFooter)
            }

            Section {
                Stepper(value: $files, in: 0...30) {
                    DemoValueRow(title: L10n.Plurals.filesLabel, value: PluralsDemo.number(files))
                }
                Stepper(value: $folders, in: 0...30) {
                    DemoValueRow(title: L10n.Plurals.foldersLabel, value: PluralsDemo.number(folders))
                }
                Text(L10n.Plurals.summary(files: files, folders: folders))
                    .font(.headline)
            } header: {
                Text(L10n.Plurals.sectionMulti)
            } footer: {
                Text(L10n.Plurals.multiFooter)
            }

            Section {
                ForEach(PluralsDemo.sampleCounts, id: \.self) { value in
                    DemoValueRow(title: PluralsDemo.number(value), value: L10n.Plurals.files(value))
                }
            } header: {
                Text(L10n.Plurals.sectionTable)
            } footer: {
                Text(L10n.Plurals.tableFooter)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(Feature.plurals.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
