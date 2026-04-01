import SwiftUI

struct SavedView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "No Saved Articles",
                systemImage: "bookmark",
                description: Text("Articles you bookmark will appear here.")
            )
            .navigationTitle("Saved")
        }
    }
}

#Preview {
    SavedView()
}
