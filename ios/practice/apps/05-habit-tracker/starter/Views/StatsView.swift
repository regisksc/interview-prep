import SwiftUI

struct StatsView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Stats",
                systemImage: "chart.bar",
                description: Text("Your habit statistics will appear here.")
            )
            .navigationTitle("Stats")
        }
    }
}

#Preview {
    StatsView()
}
