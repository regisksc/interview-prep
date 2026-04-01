import Foundation

enum Mood: String, CaseIterable, Identifiable {
    case great, good, okay, bad, awful

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .great: "😄"
        case .good: "🙂"
        case .okay: "😐"
        case .bad: "😔"
        case .awful: "😢"
        }
    }

    var label: String { rawValue.capitalized }

    var imageName: String { "mood-\(rawValue)" }
}

struct MoodEntry: Identifiable {
    let id: UUID
    let mood: Mood
    let date: Date
    var note: String

    init(id: UUID = UUID(), mood: Mood, date: Date = .now, note: String = "") {
        self.id = id
        self.mood = mood
        self.date = date
        self.note = note
    }
}
