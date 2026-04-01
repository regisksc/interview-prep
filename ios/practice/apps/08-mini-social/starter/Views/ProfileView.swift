import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Profile",
                systemImage: "person.circle",
                description: Text("Your profile will appear here.")
            )
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
}
