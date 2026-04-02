import Foundation

struct QuoteResponse: Codable {
    let quotes: [Quote]
    let total: Int
}

struct Quote: Codable, Identifiable {
    let id: Int
    let quote: String
    let author: String
}
