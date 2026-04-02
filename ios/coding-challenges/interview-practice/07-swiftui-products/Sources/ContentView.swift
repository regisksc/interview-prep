import SwiftUI

struct ContentView: View {
    @State private var products: [Product] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading products...")
                } else if let error = errorMessage {
                    VStack(spacing: 12) {
                        Text(error).foregroundStyle(.red)
                        Button("Retry") { Task { await loadProducts() } }
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(products) { product in
                                VStack(alignment: .leading, spacing: 6) {
                                    AsyncImage(url: URL(string: product.thumbnail)) { image in
                                        image.resizable().aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Color.gray.opacity(0.3)
                                    }
                                    .frame(height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))

                                    Text(product.title)
                                        .font(.caption)
                                        .lineLimit(2)

                                    Text("$\(product.price, specifier: "%.2f")")
                                        .font(.caption.bold())
                                        .foregroundStyle(.green)

                                    HStack(spacing: 2) {
                                        Image(systemName: "star.fill")
                                            .font(.caption2)
                                            .foregroundStyle(.yellow)
                                        Text(String(format: "%.1f", product.rating))
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(8)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Products")
            .task { await loadProducts() }
        }
    }

    private func loadProducts() async {
        isLoading = true
        errorMessage = nil
        do {
            guard let url = URL(string: "https://dummyjson.com/products?limit=30") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(ProductResponse.self, from: data)
            products = response.products
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func maxProductsWithinBudget(_ products: [Product], budget: Double) -> [Product] {
        return []
    }
}

#Preview { ContentView() }
