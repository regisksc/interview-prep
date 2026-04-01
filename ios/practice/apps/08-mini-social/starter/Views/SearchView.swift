import SwiftUI

struct SearchView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Search",
                systemImage: "magnifyingglass",
                description: Text("Search for people and posts.")
            )
            .navigationTitle("Search")
        }
    }
}

#Preview {
    SearchView()
}
