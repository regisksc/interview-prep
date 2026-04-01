import SwiftUI

struct ContentView: View {
    let recipes = Recipe.samples

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(recipes) { recipe in
                    Text(recipe.name)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .navigationTitle("Recipes")
        }
    }
}

#Preview {
    ContentView()
}
