import SwiftUI

struct ContentView: View {
    @State private var recipes: [Recipe] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading recipes...")
                } else if let error = errorMessage {
                    VStack(spacing: 12) {
                        Text(error).foregroundStyle(.red)
                        Button("Retry") { Task { await loadRecipes() } }
                    }
                } else {
                    List(recipes) { recipe in
                        NavigationLink(destination: recipeDetail(recipe)) {
                            HStack {
                                AsyncImage(url: URL(string: recipe.image)) { image in
                                    image.resizable().aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                }
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(recipe.name).font(.headline)
                                    Text("\(recipe.cuisine) · \(recipe.difficulty)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    HStack(spacing: 12) {
                                        Label("\(recipe.prepTimeMinutes)m prep", systemImage: "clock")
                                        Label("\(recipe.cookTimeMinutes)m cook", systemImage: "flame")
                                    }
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Recipes")
            .task { await loadRecipes() }
        }
    }

    private func recipeDetail(_ recipe: Recipe) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: URL(string: recipe.image)) { image in
                    image.resizable().aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(maxHeight: 200)

                Text(recipe.name).font(.title2.bold())
                Text("\(recipe.difficulty) · \(recipe.servings) servings · \(recipe.caloriesPerServing) cal")
                    .foregroundStyle(.secondary)

                Text("Ingredients").font(.headline)
                ForEach(recipe.ingredients, id: \.self) { ingredient in
                    Text("• \(ingredient)")
                }

                Text("Instructions").font(.headline)
                ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                    Text("\(index + 1). \(step)")
                }
            }
            .padding()
        }
    }

    private func loadRecipes() async {
        isLoading = true
        errorMessage = nil
        do {
            guard let url = URL(string: "https://dummyjson.com/recipes?limit=20") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(RecipeResponse.self, from: data)
            recipes = response.recipes
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func averagePrepTimeByDifficulty(_ recipes: [Recipe]) -> [(difficulty: String, avgPrepTime: Double)] {
        return []
    }
}

#Preview { ContentView() }
