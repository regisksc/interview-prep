import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TodayTab()
                .tabItem {
                    Label("Today", systemImage: "sun.max")
                }

            HistoryTab()
                .tabItem {
                    Label("History", systemImage: "calendar")
                }

            SettingsTab()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
}
