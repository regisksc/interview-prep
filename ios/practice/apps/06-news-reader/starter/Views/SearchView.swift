import SwiftUI

struct SearchView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Search",
                systemImage: "magnifyingglass",
                description: Text("Search for articles by topic or keyword.")
            )
            .navigationTitle("Search")
        }
    }
}

#Preview {
    SearchView()
}
