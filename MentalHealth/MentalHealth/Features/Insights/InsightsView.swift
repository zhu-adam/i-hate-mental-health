import SwiftUI
import SwiftData
import Charts

// MARK: - Insights View

struct InsightsView: View {
    @Query(
        filter: #Predicate<MoodEntry> { $0.mood > 0 },
        sort: \MoodEntry.date,
        order: .forward
    ) private var moodEntries: [MoodEntry]

    private let moodLabels = ["", "Very Bad", "Bad", "Okay", "Good", "Very Good"]

    private var averageMood: Double? {
        guard !moodEntries.isEmpty else { return nil }
        return Double(moodEntries.map(\.mood).reduce(0, +)) / Double(moodEntries.count)
    }

    private var thisWeekCount: Int {
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now
        return moodEntries.filter { $0.date >= cutoff }.count
    }

    private var moodDistribution: [(mood: Int, count: Int)] {
        (1...5).map { mood in (mood, moodEntries.filter { $0.mood == mood }.count) }
    }

    var body: some View {
        NavigationStack {
            if moodEntries.isEmpty {
                ContentUnavailableView(
                    "No Mood Data",
                    systemImage: "chart.bar",
                    description: Text("Log mood check-ins in Journal to see charts.")
                )
                .navigationTitle("Insights")
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        statsRow
                        moodOverTimeChart
                        moodDistributionChart
                    }
                    .padding()
                }
                .navigationTitle("Insights")
                .background(Color(.systemGroupedBackground))
            }
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 12) {
            StatCard(label: "Total", value: "\(moodEntries.count)")
            StatCard(label: "This Week", value: "\(thisWeekCount)")
            if let avg = averageMood {
                StatCard(label: "Avg Mood", value: String(format: "%.1f", avg))
            }
        }
    }

    // MARK: - Mood Over Time

    private var moodOverTimeChart: some View {
        ChartCard(title: "Mood Over Time") {
            Chart(moodEntries) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Mood", entry.mood)
                )
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", entry.date),
                    y: .value("Mood", entry.mood)
                )
            }
            .chartYScale(domain: 1...5)
            .chartYAxis {
                AxisMarks(values: [1, 2, 3, 4, 5]) { _ in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                }
            }
            .frame(height: 200)
        }
    }

    // MARK: - Mood Distribution

    private var moodDistributionChart: some View {
        ChartCard(title: "Mood Distribution") {
            Chart(moodDistribution, id: \.mood) { item in
                BarMark(
                    x: .value("Mood", moodLabels[item.mood]),
                    y: .value("Count", item.count)
                )
            }
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .frame(height: 180)
        }
    }
}

// MARK: - Supporting Views

private struct StatCard: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct ChartCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    InsightsView()
        .modelContainer(for: MoodEntry.self, inMemory: true)
}
