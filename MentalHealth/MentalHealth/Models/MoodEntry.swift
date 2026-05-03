import Foundation
import SwiftData

@Model
final class MoodEntry {
    var id: UUID
    var date: Date
    var mood: Int        // 1–5; 0 = journal-only (no mood recorded)
    var note: String
    var title: String    // journal title; empty for mood-only entries

    init(mood: Int = 0, note: String = "", title: String = "", date: Date = .now) {
        self.id = UUID()
        self.date = date
        self.mood = mood
        self.note = note
        self.title = title
    }
}

// MARK: - Codable DTO

struct MoodEntryDTO: Codable {
    var id: UUID
    var date: Date
    var mood: Int
    var note: String
    var title: String

    init(from entry: MoodEntry) {
        id = entry.id
        date = entry.date
        mood = entry.mood
        note = entry.note
        title = entry.title
    }

    func toModel() -> MoodEntry {
        let entry = MoodEntry(mood: mood, note: note, title: title, date: date)
        entry.id = id
        return entry
    }
}
