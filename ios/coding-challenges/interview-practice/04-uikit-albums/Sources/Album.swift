import Foundation

struct Album: Codable, Identifiable {
    let userId: Int
    let id: Int
    let title: String
}
