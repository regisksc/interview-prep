import SwiftUI

struct Contact: Identifiable {
    let id: UUID
    var firstName: String
    var lastName: String
    var phone: String?
    var email: String?
    var company: String?
    var isFavorite: Bool

    init(
        id: UUID = UUID(),
        firstName: String,
        lastName: String,
        phone: String? = nil,
        email: String? = nil,
        company: String? = nil,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
        self.email = email
        self.company = company
        self.isFavorite = isFavorite
    }

    var fullName: String { "\(firstName) \(lastName)" }

    var initials: String {
        let first = firstName.first.map(String.init) ?? ""
        let last = lastName.first.map(String.init) ?? ""
        return "\(first)\(last)"
    }

    var initialsColor: Color {
        let colors: [Color] = [
            .red, .orange, .yellow, .green, .mint,
            .teal, .cyan, .blue, .indigo, .purple, .pink,
        ]
        let hash = abs(fullName.hashValue)
        return colors[hash % colors.count]
    }
}

extension Contact {
    static let samples: [Contact] = [
        Contact(firstName: "Alice", lastName: "Anderson", phone: "(415) 555-0101", email: "alice@example.com", company: "Acme Inc", isFavorite: true),
        Contact(firstName: "Adam", lastName: "Abbott", phone: "(415) 555-0102", email: "adam@example.com"),
        Contact(firstName: "Anna", lastName: "Archer", phone: "(415) 555-0103", company: "Atlas Corp"),
        Contact(firstName: "Brian", lastName: "Baker", phone: "(415) 555-0201", email: "brian@example.com", company: "Bolt Labs", isFavorite: true),
        Contact(firstName: "Beth", lastName: "Brooks", phone: "(415) 555-0202", email: "beth@example.com"),
        Contact(firstName: "Bradley", lastName: "Burns", email: "bradley@example.com", company: "Bright Co"),
        Contact(firstName: "Clara", lastName: "Chen", phone: "(415) 555-0301", email: "clara@example.com", company: "Craft Studio", isFavorite: true),
        Contact(firstName: "Carlos", lastName: "Cruz", phone: "(415) 555-0302"),
        Contact(firstName: "Diana", lastName: "Diaz", phone: "(415) 555-0401", email: "diana@example.com", company: "Delta Systems"),
        Contact(firstName: "David", lastName: "Dunn", phone: "(415) 555-0402", email: "david@example.com"),
        Contact(firstName: "Elena", lastName: "Evans", phone: "(415) 555-0501", email: "elena@example.com", company: "Echo Media", isFavorite: true),
        Contact(firstName: "Ethan", lastName: "Ellis", phone: "(415) 555-0502"),
        Contact(firstName: "Emily", lastName: "Edwards", email: "emily@example.com", company: "Evergreen LLC"),
        Contact(firstName: "Frank", lastName: "Foster", phone: "(415) 555-0601", email: "frank@example.com", company: "Forge Works"),
        Contact(firstName: "Fiona", lastName: "Fleming", phone: "(415) 555-0602", email: "fiona@example.com"),
    ]
}
