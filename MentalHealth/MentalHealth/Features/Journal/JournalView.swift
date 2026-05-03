import SwiftUI

struct JournalView: View {
    @State private var viewModel = JournalViewModel()

    var body: some View {
        NavigationStack {
            Text("Journal")
                .navigationTitle("Journal")
        }
    }
}
