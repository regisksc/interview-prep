import SwiftUI

struct ContentView: View {
    @State private var quotes: [Quote] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading quotes...")
                } else if let error = errorMessage {
                    VStack(spacing: 12) {
                        Text(error).foregroundStyle(.red)
                        Button("Retry") { Task { await loadQuotes() } }
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(quotes) { quote in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("\"\(quote.quote)\"")
                                        .font(.body)
                                        .italic()

                                    HStack {
                                        Spacer()
                                        Text("— \(quote.author)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Text("\(quote.quote.count) characters")
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Quotes")
            .task { await loadQuotes() }
        }
    }

    private func loadQuotes() async {
        isLoading = true
        errorMessage = nil
        do {
            guard let url = URL(string: "https://dummyjson.com/quotes?limit=30") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(QuoteResponse.self, from: data)
            quotes = response.quotes
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func longestIncreasingSubsequence(_ quotes: [Quote]) -> [Quote] {
        return []
    }
}

#Preview { ContentView() }
