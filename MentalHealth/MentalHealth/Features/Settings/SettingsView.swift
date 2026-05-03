import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            Text("Settings")
                .navigationTitle("Settings")
        }
    }
}
