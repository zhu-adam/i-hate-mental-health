import SwiftUI
import SwiftData

@main
struct MentalHealthApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: MoodEntry.self)
    }
}
