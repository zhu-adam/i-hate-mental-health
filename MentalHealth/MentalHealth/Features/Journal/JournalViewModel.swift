import Foundation
import SwiftData

enum JournalTab: String, CaseIterable {
    case entries = "Entries"
    case mood = "Mood Check-In"
}

@Observable
final class JournalViewModel {
    var selectedTab: JournalTab = .entries

    // Entry detail
    var selectedEntry: MoodEntry?

    // Add journal entry form
    var showAddEntry = false
    var journalTitle = ""
    var journalNote = ""

    // Mood check-in form
    var selectedMood: Int = 0
    var moodNote = ""
    var moodSaved = false

    func resetJournalForm() {
        journalTitle = ""
        journalNote = ""
    }

    func resetMoodForm() {
        selectedMood = 0
        moodNote = ""
        moodSaved = false
    }
}
