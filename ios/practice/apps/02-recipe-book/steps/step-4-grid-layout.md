# Step 4: Two-Column Grid

**Read first:** [swiftui-advanced.md — Custom Layout](../../../../lessons/swiftui-advanced.md#custom-layout) (LazyVGrid usage and GridItem)

**Difficulty:** ★☆☆ Beginner

---

## Goal

The recipe list switches from a single-column scrollable list to a two-column grid of cards.

## When you're done

- [ ] Recipes display in a 2-column grid using LazyVGrid
- [ ] Grid columns use `.flexible()` sizing
- [ ] Each card fills its column width
- [ ] Cards in the same row align at the top
- [ ] Spacing between columns and rows is visually consistent
- [ ] The grid scrolls vertically within the existing ScrollView
- [ ] The app compiles and the `#Preview` works

## Files to edit

- `Views/ContentView.swift`

## Hints

<details>
<summary>Hint 1 — defining grid columns</summary>
Create an array of <code>GridItem</code>: <code>let columns = [GridItem(.flexible()), GridItem(.flexible())]</code>. Two items in the array = two columns. Pass this to <code>LazyVGrid(columns: columns, spacing: 16)</code>.
</details>

<details>
<summary>Hint 2 — replacing LazyVStack</summary>
Swap <code>LazyVStack</code> for <code>LazyVGrid(columns: columns, spacing: 16)</code>. The ForEach inside stays the same. Each recipe card will automatically be placed into the next available grid cell.
</details>

<details>
<summary>Hint 3 — card layout adjustments</summary>
In a grid, each card is narrower. You may need to switch from your HStack row to a VStack card layout (image on top, text below) so content fits better in the narrower column width. Consider using <code>.frame(maxWidth: .infinity)</code> on the card so it fills the column.
</details>

---

## LLM Review

Copy your `ContentView.swift` and this block into an LLM. Ask it to review without showing corrected code — pass/fail per item with directional hints only.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

GRID
- LazyVGrid is used (not LazyVStack or List)
- The columns array contains exactly 2 GridItem elements
- GridItem uses .flexible() sizing (not .fixed or .adaptive)
- LazyVGrid has explicit spacing

LAYOUT
- Each card fills the column width (not a fixed narrow size)
- Cards in the same row have consistent top alignment
- The grid is inside a ScrollView for vertical scrolling

CARD DESIGN
- Cards adapted to fit the narrower column (VStack layout or appropriate HStack)
- The difficulty badge and favorite heart overlays still display correctly
- The placeholder image, name, and cook time are all visible

QUALITY
- No hardcoded widths that break on different screen sizes
- Horizontal padding prevents cards from touching screen edges
- #Preview compiles
```
