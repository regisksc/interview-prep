import SwiftUI

struct Habit: Identifiable {
    let id: UUID
    var name: String
    var icon: String
    var color: Color
    var isCompletedToday: Bool

    init(id: UUID = UUID(), name: String, icon: String, color: Color, isCompletedToday: Bool = false) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.isCompletedToday = isCompletedToday
    }
}

struct HabitRecord: Identifiable {
    let id: UUID
    let habitId: UUID
    let date: Date

    init(id: UUID = UUID(), habitId: UUID, date: Date = .now) {
        self.id = id
        self.habitId = habitId
        self.date = date
    }
}

extension Habit {
    static let samples: [Habit] = [
        Habit(name: "Exercise", icon: "figure.run", color: .orange),
        Habit(name: "Read 30min", icon: "book", color: .blue),
        Habit(name: "Meditate", icon: "leaf", color: .green),
        Habit(name: "Drink water", icon: "drop", color: .cyan),
    ]
}
