import Foundation

// MARK: - API Response Wrapper

struct PostResponse: Codable {
    let posts: [Post]
    let total: Int
    let skip: Int
    let limit: Int
}

// MARK: - Reactions

struct Reactions: Codable, Equatable {
    let likes: Int
    let dislikes: Int
}

// MARK: - Post (maps to DummyJSON /posts endpoint)

struct Post: Codable, Identifiable, Equatable {
    let id: Int
    let title: String
    let body: String
    let tags: [String]
    let reactions: Reactions
    let userId: Int
}
