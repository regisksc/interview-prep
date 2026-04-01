import SwiftUI

struct User: Identifiable {
    let id: UUID
    var username: String
    var displayName: String
    var avatarColor: Color

    init(id: UUID = UUID(), username: String, displayName: String, avatarColor: Color) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.avatarColor = avatarColor
    }
}

struct Post: Identifiable {
    let id: UUID
    var author: User
    var imageNames: [String]
    var caption: String
    var likeCount: Int
    var commentCount: Int
    var createdAt: Date
    var isLiked: Bool

    init(
        id: UUID = UUID(),
        author: User,
        imageNames: [String] = [],
        caption: String,
        likeCount: Int = 0,
        commentCount: Int = 0,
        createdAt: Date = .now,
        isLiked: Bool = false
    ) {
        self.id = id
        self.author = author
        self.imageNames = imageNames
        self.caption = caption
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.createdAt = createdAt
        self.isLiked = isLiked
    }
}

extension User {
    static let alice = User(username: "alice", displayName: "Alice Johnson", avatarColor: .purple)
    static let bob = User(username: "bob_dev", displayName: "Bob Smith", avatarColor: .blue)
    static let carol = User(username: "carol_designs", displayName: "Carol Lee", avatarColor: .pink)
}

extension Post {
    static let samples: [Post] = [
        Post(author: .alice, caption: "Beautiful sunset at the beach today!", likeCount: 42, commentCount: 5),
        Post(author: .bob, caption: "Just shipped a new feature — feeling great about this release.", likeCount: 108, commentCount: 12),
        Post(author: .carol, caption: "New design system exploration. Thoughts?", likeCount: 73, commentCount: 8),
        Post(author: .alice, caption: "Morning coffee and code — the perfect combo.", likeCount: 25, commentCount: 3),
    ]
}
