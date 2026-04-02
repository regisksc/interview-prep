import Foundation

struct TodoResponse: Codable {
    let todos: [TodoItem]
    let total: Int
}

struct TodoItem: Codable, Identifiable {
    let id: Int
    let todo: String
    var completed: Bool
    let userId: Int
}
