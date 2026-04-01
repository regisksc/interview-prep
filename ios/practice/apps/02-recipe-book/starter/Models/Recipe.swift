import Foundation

struct Recipe: Identifiable {
    let id: UUID
    var name: String
    var category: Category
    var cookTime: Int
    var difficulty: Difficulty
    var imageName: String
    var ingredients: [String]
    var isFavorite: Bool

    init(
        id: UUID = UUID(),
        name: String,
        category: Category,
        cookTime: Int,
        difficulty: Difficulty,
        imageName: String,
        ingredients: [String],
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.cookTime = cookTime
        self.difficulty = difficulty
        self.imageName = imageName
        self.ingredients = ingredients
        self.isFavorite = isFavorite
    }

    enum Category: String, CaseIterable, Identifiable {
        case italian, asian, desserts, mexican, american

        var id: String { rawValue }
        var label: String { rawValue.capitalized }
    }

    enum Difficulty: String, CaseIterable, Identifiable {
        case easy, medium, hard

        var id: String { rawValue }
        var label: String { rawValue.capitalized }
    }
}

extension Recipe {
    static let samples: [Recipe] = [
        Recipe(
            name: "Spaghetti Carbonara",
            category: .italian,
            cookTime: 30,
            difficulty: .medium,
            imageName: "carbonara",
            ingredients: ["Spaghetti", "Pancetta", "Eggs", "Parmesan", "Black pepper"],
            isFavorite: true
        ),
        Recipe(
            name: "Chicken Pad Thai",
            category: .asian,
            cookTime: 25,
            difficulty: .medium,
            imageName: "pad-thai",
            ingredients: ["Rice noodles", "Chicken breast", "Eggs", "Bean sprouts", "Peanuts", "Lime"]
        ),
        Recipe(
            name: "Tiramisu",
            category: .desserts,
            cookTime: 45,
            difficulty: .hard,
            imageName: "tiramisu",
            ingredients: ["Ladyfingers", "Mascarpone", "Espresso", "Eggs", "Cocoa powder", "Sugar"]
        ),
        Recipe(
            name: "Fish Tacos",
            category: .mexican,
            cookTime: 20,
            difficulty: .easy,
            imageName: "fish-tacos",
            ingredients: ["White fish", "Tortillas", "Cabbage", "Lime crema", "Cilantro", "Avocado"]
        ),
        Recipe(
            name: "Classic Cheeseburger",
            category: .american,
            cookTime: 15,
            difficulty: .easy,
            imageName: "cheeseburger",
            ingredients: ["Ground beef", "Cheddar cheese", "Brioche bun", "Lettuce", "Tomato", "Pickles"]
        ),
        Recipe(
            name: "Miso Ramen",
            category: .asian,
            cookTime: 60,
            difficulty: .hard,
            imageName: "miso-ramen",
            ingredients: ["Ramen noodles", "Miso paste", "Pork belly", "Soft-boiled egg", "Nori", "Green onions"],
            isFavorite: true
        ),
    ]
}
