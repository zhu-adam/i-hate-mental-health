import Foundation
import SwiftData

@Model
final class MoodEntry {
    var id: UUID
    var date: Date
    var mood: Int        // 1–5
    var note: String

    init(mood: Int, note: String = "", date: Date = .now) {
        self.id = UUID()
        self.date = date
        self.mood = mood
        self.note = note
    }
}

// MARK: - Codable DTO

struct MoodEntryDTO: Codable {
    var id: UUID
    var date: Date
    var mood: Int
    var note: String

    init(from entry: MoodEntry) {
        id = entry.id
        date = entry.date
        mood = entry.mood
        note = entry.note
    }

    func toModel() -> MoodEntry {
        let entry = MoodEntry(mood: mood, note: note, date: date)
        entry.id = id
        return entry
    }
}
