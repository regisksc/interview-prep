import SwiftUI

struct ContentView: View {
    @State private var users: [DummyUser] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var searchText = ""

    private var filteredUsers: [DummyUser] {
        if searchText.isEmpty { return users }
        return users.filter {
            $0.firstName.localizedCaseInsensitiveContains(searchText) ||
            $0.lastName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading users...")
                } else if let error = errorMessage {
                    VStack(spacing: 12) {
                        Text(error).foregroundStyle(.red)
                        Button("Retry") { Task { await loadUsers() } }
                    }
                } else {
                    List(filteredUsers) { user in
                        HStack(spacing: 12) {
                            AsyncImage(url: URL(string: user.image)) { image in
                                image.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay(
                                        Text(String(user.firstName.prefix(1)))
                                            .font(.title3.bold())
                                            .foregroundStyle(.white)
                                    )
                            }
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(user.firstName) \(user.lastName)")
                                    .font(.headline)
                                Text(user.email)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("Age: \(user.age)")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Users")
            .searchable(text: $searchText, prompt: "Search by name")
            .task { await loadUsers() }
        }
    }

    private func loadUsers() async {
        isLoading = true
        errorMessage = nil
        do {
            guard let url = URL(string: "https://dummyjson.com/users?limit=20") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(UserResponse.self, from: data)
            users = response.users
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func buildInvertedIndex(_ users: [DummyUser]) -> [Character: [DummyUser]] {
        return [:]
    }
}

#Preview { ContentView() }
