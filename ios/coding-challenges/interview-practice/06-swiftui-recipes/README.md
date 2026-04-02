# Challenge 06: Recipe Book

**API:** `https://dummyjson.com/recipes?limit=20`
**Time:** 45 minutes
**Framework:** SwiftUI

## Starting point

A working SwiftUI app that fetches recipes and displays them in a list with navigation to a detail view. All logic — state, networking, formatting, detail view — lives in one `ContentView`.

## Files

| File | What it does |
|------|-------------|
| `Recipe.swift` | Codable model + response wrapper |
| `ContentView.swift` | State, networking, list, detail — everything (the mess) |

## Tasks

### 1. Refactor to MVVM (20 min)

Extract a `RecipeViewModel` with `@Published` properties. Create a `RecipeServiceProtocol` and concrete service. Extract the detail view into its own `RecipeDetailView`. The ContentView should only render.

### 2. Test the ViewModel (10 min)

Create a `MockRecipeService`. Test that loading populates the recipes array. Test the error path.

### 3. Implement the algorithm (15 min)

`averagePrepTimeByDifficulty(_:)` — Group recipes by `difficulty` (e.g. "Easy", "Medium") and compute the average `prepTimeMinutes` per group. Return tuples sorted alphabetically by difficulty. Currently returns `[]`.

## Discussion topics

- `@StateObject` vs `@ObservedObject` — when to use which?
- How would you add a favorites feature?
- How would you handle the recipe image loading lifecycle?
