import SwiftUI

struct HomeView: View {
    @Environment(AppRouter.self) private var router
    @State private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    quoteCard
                    quickNav
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Home")
        }
    }

    // MARK: - Quote Card

    private var quoteCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\u{201C}\(viewModel.quote.text)\u{201D}")
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Text("— \(viewModel.quote.author)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    viewModel.refreshQuote()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Quick Nav

    private var quickNav: some View {
        VStack(spacing: 12) {
            QuickNavButton(
                title: "New Journal Entry",
                systemImage: "pencil",
                action: { router.selectedTab = 1 }
            )
            QuickNavButton(
                title: "Mood Check-In",
                systemImage: "face.smiling",
                action: { router.selectedTab = 1 }
            )
            QuickNavButton(
                title: "View Insights",
                systemImage: "chart.bar",
                action: { router.selectedTab = 2 }
            )
        }
    }
}

// MARK: - Quick Nav Button

private struct QuickNavButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                    .frame(width: 24)
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
        .environment(AppRouter())
        .modelContainer(for: MoodEntry.self, inMemory: true)
}
