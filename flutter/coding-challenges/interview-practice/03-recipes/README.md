# Challenge 03: Recipe Browser

## Description

A recipe browsing app that fetches recipes and shows them in a list with detail navigation. Each recipe has: name, ingredients, prepTimeMinutes, cookTimeMinutes, difficulty, cuisine, image.

**API:** `https://dummyjson.com/recipes?limit=20`

### Key Classes

- `main.dart` — everything in one file.

## Goal

Refactor to a layered architecture. Add proper navigation and state management.

### Tasks

1. **Refactor** — Extract Model, Repository (abstract class), and separate widgets (RecipeListScreen, RecipeDetailScreen, RecipeCard). Use Navigator for detail push. Add repository tests.

2. **Algorithm** — Group recipes by difficulty (Easy/Medium) and calculate the average prepTimeMinutes per group. The `avgPrepByDifficulty()` function currently returns empty.

3. **Feature** — Add a cuisine filter dropdown and sort-by toggle (prep time vs cook time).

### Discussion

- How does Navigator 2.0 compare to Navigator 1.0?
- What's the difference between StatefulWidget and using a state management solution?
- How would you test widgets that depend on network data?
