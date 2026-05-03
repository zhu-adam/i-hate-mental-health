import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "book")
                }
            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
