import Foundation

struct UserResponse: Codable {
    let users: [DummyUser]
    let total: Int
}

struct DummyUser: Codable, Identifiable {
    let id: Int
    let firstName: String
    let lastName: String
    let age: Int
    let email: String
    let phone: String
    let username: String
    let image: String
}
