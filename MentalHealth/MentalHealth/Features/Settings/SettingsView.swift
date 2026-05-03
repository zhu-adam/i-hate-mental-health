import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import UserNotifications

// MARK: - File Document

struct JSONDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var data: Data

    init(data: Data) { self.data = data }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

// MARK: - Crisis Resources

struct CrisisResourcesView: View {
    @Environment(\.dismiss) private var dismiss

    private let resources: [(name: String, detail: String)] = [
        ("988 Suicide & Crisis Lifeline", "Call or text 988"),
        ("Crisis Text Line", "Text HOME to 741741"),
        ("SAMHSA Helpline", "1-800-662-4357"),
        ("International Crisis Centers", "iasp.info/resources/Crisis_Centres"),
    ]

    var body: some View {
        NavigationStack {
            List(resources, id: \.name) { resource in
                VStack(alignment: .leading, spacing: 4) {
                    Text(resource.name).font(.headline)
                    Text(resource.detail).font(.subheadline).foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Crisis Resources")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [MoodEntry]
    @State private var viewModel = SettingsViewModel()

    @AppStorage("colorScheme") private var colorSchemeRaw = "system"
    @AppStorage("accentColor") private var accentColorName = "blue"
    @AppStorage("reminder") private var reminderFrequency = "none"

    var body: some View {
        NavigationStack {
            Form {
                Section("Data") {
                    Button("Export Save File") { prepareExport() }
                    Button("Import Save File") { viewModel.isImporting = true }
                    Button("Reset All Data", role: .destructive) {
                        viewModel.showResetConfirm = true
                    }
                }

                Section("Appearance") {
                    Picker("Theme", selection: $colorSchemeRaw) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(.segmented)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Accent Color")
                        HStack(spacing: 14) {
                            ForEach(AccentPreset.allCases) { preset in
                                Button {
                                    accentColorName = preset.rawValue
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(preset.color)
                                            .frame(width: 28, height: 28)
                                        if accentColorName == preset.rawValue {
                                            Image(systemName: "checkmark")
                                                .font(.caption.bold())
                                                .foregroundStyle(.white)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Reminders") {
                    Picker("Frequency", selection: $reminderFrequency) {
                        Text("None").tag("none")
                        Text("Daily").tag("daily")
                        Text("Weekly").tag("weekly")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: reminderFrequency) { _, newValue in
                        scheduleReminder(newValue)
                    }
                }

                Section("Support") {
                    Button("Crisis Resources") {
                        viewModel.showCrisisResources = true
                    }
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Reset All Data?",
                isPresented: $viewModel.showResetConfirm,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) { resetAllData() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently deletes all entries.")
            }
            .fileExporter(
                isPresented: $viewModel.isExporting,
                document: viewModel.exportDocument,
                contentType: .json,
                defaultFilename: "mentalhealth-export"
            ) { _ in }
            .fileImporter(
                isPresented: $viewModel.isImporting,
                allowedContentTypes: [.json]
            ) { result in
                importData(result: result)
            }
            .sheet(isPresented: $viewModel.showCrisisResources) {
                CrisisResourcesView()
            }
        }
    }

    // MARK: - Actions

    private func prepareExport() {
        do {
            let data = try DataExporter.export(entries)
            viewModel.exportDocument = JSONDocument(data: data)
            viewModel.isExporting = true
        } catch {
            viewModel.errorMessage = error.localizedDescription
        }
    }

    private func importData(result: Result<URL, Error>) {
        do {
            let url = try result.get()
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            let data = try Data(contentsOf: url)
            let imported = try DataExporter.import(from: data)
            imported.forEach { modelContext.insert($0) }
            try modelContext.save()
        } catch {
            viewModel.errorMessage = error.localizedDescription
        }
    }

    private func resetAllData() {
        entries.forEach { modelContext.delete($0) }
        try? modelContext.save()
    }

    private func scheduleReminder(_ frequency: String) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        guard frequency != "none" else { return }

        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = "Check In"
            content.body = "How are you feeling today?"
            content.sound = .default

            var components = DateComponents()
            components.hour = 9
            components.minute = 0
            if frequency == "weekly" { components.weekday = 2 }

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: "checkin", content: content, trigger: trigger)
            center.add(request)
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: MoodEntry.self, inMemory: true)
}
