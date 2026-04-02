import Foundation

struct ProductResponse: Codable {
    let products: [Product]
    let total: Int
}

struct Product: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let price: Double
    let rating: Double
    let stock: Int
    let thumbnail: String
}
