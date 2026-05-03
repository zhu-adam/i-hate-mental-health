import SwiftUI

struct InsightsView: View {
    @State private var viewModel = InsightsViewModel()

    var body: some View {
        NavigationStack {
            Text("Insights")
                .navigationTitle("Insights")
        }
    }
}
