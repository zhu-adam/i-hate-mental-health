import SwiftUI
import SwiftData

// MARK: - Entry Row

private struct EntryRow: View {
    let entry: MoodEntry

    private var headline: String {
        if entry.mood > 0 {
            return "Mood: \(entry.mood)/5"
        }
        return entry.title.isEmpty ? "Journal Entry" : entry.title
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(headline).font(.headline)
                Spacer()
                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if !entry.note.isEmpty {
                Text(entry.note)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Entry Detail Sheet

private struct EntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let entry: MoodEntry

    private let moodLabels = ["", "Very Bad", "Bad", "Okay", "Good", "Very Good"]
    private let moodEmoji  = ["", "😢", "😕", "😐", "🙂", "😄"]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text(entry.date.formatted(date: .long, time: .shortened))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }

                if entry.mood > 0 {
                    Section("Mood") {
                        HStack(spacing: 12) {
                            Text(moodEmoji[entry.mood]).font(.largeTitle)
                            VStack(alignment: .leading) {
                                Text(moodLabels[entry.mood]).font(.headline)
                                Text("\(entry.mood) out of 5").font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                if !entry.note.isEmpty {
                    Section("Note") {
                        Text(entry.note)
                            .font(.body)
                    }
                }
            }
            .navigationTitle(entry.title.isEmpty ? (entry.mood > 0 ? "Mood Check-In" : "Journal Entry") : entry.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Add Journal Entry Sheet

private struct AddJournalEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var title: String
    @Binding var note: String
    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Optional title", text: $title)
                }
                Section("Entry") {
                    TextEditor(text: $note)
                        .frame(minHeight: 160)
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                    .disabled(note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

// MARK: - Mood Check-In View

private struct MoodCheckInView: View {
    @Binding var selectedMood: Int
    @Binding var note: String
    let onSave: () -> Void

    private let moodLabels = ["", "Very Bad", "Bad", "Okay", "Good", "Very Good"]
    private let moodEmoji  = ["", "😢", "😕", "😐", "🙂", "😄"]

    var body: some View {
        Form {
            Section("How are you feeling?") {
                HStack(spacing: 0) {
                    ForEach(1...5, id: \.self) { value in
                        Button {
                            selectedMood = value
                        } label: {
                            VStack(spacing: 6) {
                                Text(moodEmoji[value])
                                    .font(.title2)
                                Text("\(value)")
                                    .font(.caption2)
                                    .foregroundStyle(selectedMood == value ? .primary : .secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                selectedMood == value
                                    ? Color.accentColor.opacity(0.15)
                                    : Color.clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)

                if selectedMood > 0 {
                    Text(moodLabels[selectedMood])
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }

            Section("Note (optional)") {
                TextEditor(text: $note)
                    .frame(minHeight: 80)
            }

            Section {
                Button("Save Check-In") {
                    onSave()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .disabled(selectedMood == 0)
            }
        }
    }
}

// MARK: - Journal View

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MoodEntry.date, order: .reverse) private var entries: [MoodEntry]
    @State private var viewModel = JournalViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Tab", selection: $viewModel.selectedTab) {
                    ForEach(JournalTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .background(Color(.systemGroupedBackground))

                if viewModel.selectedTab == .entries {
                    if entries.isEmpty {
                        ContentUnavailableView(
                            "No Entries",
                            systemImage: "book",
                            description: Text("Tap + to write your first entry.")
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                    } else {
                        entriesList
                    }
                } else {
                    MoodCheckInView(
                        selectedMood: $viewModel.selectedMood,
                        note: $viewModel.moodNote
                    ) {
                        saveMoodEntry()
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Journal")
            .toolbar {
                if viewModel.selectedTab == .entries {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            viewModel.showAddEntry = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddEntry) {
                AddJournalEntryView(
                    title: $viewModel.journalTitle,
                    note: $viewModel.journalNote
                ) {
                    saveJournalEntry()
                }
            }
        }
    }

    // MARK: - Entries List

    private var entriesList: some View {
        List {
            ForEach(entries) { entry in
                Button {
                    viewModel.selectedEntry = entry
                } label: {
                    EntryRow(entry: entry)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .onDelete { indexSet in
                indexSet.forEach { modelContext.delete(entries[$0]) }
                try? modelContext.save()
            }
        }
        .sheet(item: $viewModel.selectedEntry) { entry in
            EntryDetailView(entry: entry)
        }
    }

    // MARK: - Actions

    private func saveJournalEntry() {
        let entry = MoodEntry(
            mood: 0,
            note: viewModel.journalNote,
            title: viewModel.journalTitle
        )
        modelContext.insert(entry)
        try? modelContext.save()
        viewModel.resetJournalForm()
    }

    private func saveMoodEntry() {
        let entry = MoodEntry(
            mood: viewModel.selectedMood,
            note: viewModel.moodNote
        )
        modelContext.insert(entry)
        try? modelContext.save()
        viewModel.resetMoodForm()
        viewModel.selectedTab = .entries
    }
}

#Preview {
    JournalView()
        .modelContainer(for: MoodEntry.self, inMemory: true)
}
