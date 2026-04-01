import SwiftUI

struct Expense: Identifiable {
    let id: UUID
    var amount: Double
    var category: Category
    var note: String
    var date: Date

    init(id: UUID = UUID(), amount: Double, category: Category, note: String, date: Date = .now) {
        self.id = id
        self.amount = amount
        self.category = category
        self.note = note
        self.date = date
    }

    enum Category: String, CaseIterable {
        case food, transport, entertainment, shopping, bills, health

        var sfSymbol: String {
            switch self {
            case .food: "fork.knife"
            case .transport: "car"
            case .entertainment: "film"
            case .shopping: "bag"
            case .bills: "doc.text"
            case .health: "heart"
            }
        }

        var color: Color {
            switch self {
            case .food: .orange
            case .transport: .blue
            case .entertainment: .purple
            case .shopping: .pink
            case .bills: .gray
            case .health: .red
            }
        }
    }
}

extension Expense {
    static let samples: [Expense] = [
        Expense(amount: 12.50, category: .food, note: "Lunch"),
        Expense(amount: 45.00, category: .transport, note: "Gas"),
        Expense(amount: 15.99, category: .entertainment, note: "Movie ticket"),
        Expense(amount: 89.99, category: .shopping, note: "New shoes"),
        Expense(amount: 120.00, category: .bills, note: "Electricity"),
        Expense(amount: 35.00, category: .health, note: "Gym membership"),
        Expense(amount: 8.75, category: .food, note: "Coffee & pastry"),
        Expense(amount: 2.50, category: .transport, note: "Bus fare"),
        Expense(amount: 59.99, category: .shopping, note: "Headphones"),
        Expense(amount: 25.00, category: .entertainment, note: "Concert ticket"),
    ]
}
