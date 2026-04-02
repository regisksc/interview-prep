import Foundation

struct Comment: Codable, Identifiable {
    let postId: Int
    let id: Int
    let name: String
    let email: String
    let body: String
}
