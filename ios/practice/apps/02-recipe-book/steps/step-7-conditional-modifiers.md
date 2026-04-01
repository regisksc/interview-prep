# Step 7: Conditional Modifiers & Category Filters

**Read first:** [swiftui-advanced.md — Custom ViewModifiers § Conditional Modifiers](../../../../lessons/swiftui-advanced.md#conditional-modifiers)

**Difficulty:** ★★☆ Intermediate

---

## Goal

Favorite recipes are visually highlighted with a distinct card style. A row of category filter pills lets the user show only recipes from a selected category (or all).

## When you're done

- [ ] Favorite recipes have a visually distinct card (e.g. a colored border, subtle background tint, or bolder shadow)
- [ ] Non-favorite recipes use the regular `.cardStyle()`
- [ ] A horizontal row of filter pills appears above the grid (one per `Recipe.Category` plus an "All" option)
- [ ] Tapping a pill selects that category — the pill looks active (filled background)
- [ ] When a category is selected, only recipes in that category appear in the grid
- [ ] Tapping "All" (or the active pill again) shows all recipes
- [ ] The selected filter is stored in a `@State` property
- [ ] The app compiles and the `#Preview` works

## Files to edit

- `Views/ContentView.swift`

## Hints

<details>
<summary>Hint 1 — conditional modifier for favorites</summary>
You can create a second modifier like <code>.favoriteCardStyle()</code> that adds a colored border or background tint. Apply it conditionally: <code>.modifier(recipe.isFavorite ? AnyViewModifier(FavoriteCardStyle()) : AnyViewModifier(CardStyle()))</code>. Or simpler: chain <code>.cardStyle()</code> then conditionally add <code>.overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.orange, lineWidth: 2))</code> when favorited.
</details>

<details>
<summary>Hint 2 — filter pills row</summary>
Use a <code>ScrollView(.horizontal, showsIndicators: false)</code> containing an <code>HStack</code> with a button for "All" and a button <code>ForEach(Recipe.Category.allCases)</code>. Store <code>@State private var selectedCategory: Recipe.Category? = nil</code> where <code>nil</code> means "All."
</details>

<details>
<summary>Hint 3 — filtering the recipes</summary>
Create a computed property: <code>var filteredRecipes: [Recipe] { guard let cat = selectedCategory else { return recipes }; return recipes.filter { $0.category == cat } }</code>. Use <code>filteredRecipes</code> in your <code>ForEach</code> instead of <code>recipes</code>.
</details>

---

## LLM Review

Copy your `ContentView.swift` and this block into an LLM. Ask it to review without showing corrected code — pass/fail per item with directional hints only.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

CONDITIONAL STYLING
- Favorite recipes look visually distinct from non-favorites
- The distinction uses a modifier, border, tint, or shadow change (not just a heart icon)
- Non-favorite cards retain the regular card style
- The conditional styling is applied per-card based on isFavorite

FILTER PILLS
- A horizontal scrollable row of category buttons appears above the grid
- There is an "All" option plus one pill per Recipe.Category case
- The active pill has a distinct filled/highlighted appearance
- Inactive pills have a muted/outline appearance
- Tapping a pill updates the selected category

FILTERING
- A @State property tracks the selected category (nil for All)
- A computed property or equivalent filters recipes by the selected category
- The ForEach uses the filtered list (not the raw recipes array)
- Selecting "All" shows every recipe

BEHAVIOR
- Tapping an already-active category pill deselects it (returns to All)
- The grid updates immediately when the filter changes

QUALITY
- Recipe.Category.allCases is used (not hardcoded category names)
- No force-unwrapping
- #Preview compiles
```
