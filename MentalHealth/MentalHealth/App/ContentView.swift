import SwiftUI

@Observable
final class AppRouter {
    var selectedTab: Int = 0
}

struct ContentView: View {
    @AppStorage("colorScheme") private var colorSchemeRaw = "system"
    @AppStorage("accentColor") private var accentColorName = "blue"
    @State private var router = AppRouter()

    private var preferredColorScheme: ColorScheme? {
        switch colorSchemeRaw {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil
        }
    }

    private var accentColor: Color {
        AccentPreset(rawValue: accentColorName)?.color ?? .blue
    }

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $router.selectedTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(0)
            JournalView()
                .tabItem { Label("Journal", systemImage: "book") }
                .tag(1)
            InsightsView()
                .tabItem { Label("Insights", systemImage: "chart.bar") }
                .tag(2)
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(3)
        }
        .environment(router)
        .tint(accentColor)
        .preferredColorScheme(preferredColorScheme)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: MoodEntry.self, inMemory: true)
}
