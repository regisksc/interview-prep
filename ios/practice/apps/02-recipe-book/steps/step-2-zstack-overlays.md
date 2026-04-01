# Step 2: Card Overlays with ZStack

**Read first:** [swiftui-advanced.md — Custom ViewModifiers](../../../../lessons/swiftui-advanced.md#custom-viewmodifiers) (modifier stacking concepts) and [swiftui-troubleshooting.md — Layout Issues § ZStack](../../../../lessons/swiftui-troubleshooting.md#layout-issues)

**Difficulty:** ★☆☆ Beginner

---

## Goal

Each recipe row becomes a card with ZStack overlays: a colored difficulty badge in the top-trailing corner and a favorite heart icon in the top-leading corner for favorited recipes.

## When you're done

- [ ] Each recipe card is wrapped in a ZStack
- [ ] A difficulty badge (small Text with colored background) appears in the top-trailing corner
- [ ] The badge background color differs by difficulty: green for easy, orange for medium, red for hard
- [ ] A heart icon (SF Symbol `"heart.fill"`) appears in the top-leading corner only for recipes where `isFavorite` is true
- [ ] The heart is colored (e.g. `.red`)
- [ ] Overlays don't obscure the main card content
- [ ] The app compiles and the `#Preview` works

## Files to edit

- `Views/ContentView.swift`

## Hints

<details>
<summary>Hint 1 — ZStack alignment</summary>
Wrap your existing HStack row in a <code>ZStack(alignment: .topTrailing)</code>. The first child is the row content; subsequent children are overlays. You can use <code>.padding(8)</code> on the badge to inset it from the corner.
</details>

<details>
<summary>Hint 2 — badge coloring</summary>
Use a computed property or a switch on <code>recipe.difficulty</code> to return the right <code>Color</code>. Apply it as the <code>.background()</code> of a small <code>Text</code> with <code>.font(.caption2)</code>, <code>.padding(.horizontal, 6)</code>, <code>.padding(.vertical, 2)</code>, and <code>.clipShape(Capsule())</code>.
</details>

<details>
<summary>Hint 3 — conditional heart overlay</summary>
Use <code>.overlay(alignment: .topLeading)</code> instead of another ZStack child for the heart. Inside, conditionally show <code>Image(systemName: "heart.fill")</code> only when <code>recipe.isFavorite</code> is true. Give it some padding so it doesn't sit right on the edge.
</details>

---

## LLM Review

Copy your `ContentView.swift` and this block into an LLM. Ask it to review without showing corrected code — pass/fail per item with directional hints only.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

LAYOUT
- Each recipe card uses ZStack or .overlay to layer content
- The difficulty badge is positioned in the top-trailing area
- The favorite heart is positioned in the top-leading area
- Main row content (image, name, time) is still visible and not obscured

BADGE
- Difficulty badge is a Text showing the difficulty label
- Badge has a colored background that varies by difficulty level (3 distinct colors)
- Badge has rounded/capsule shape
- Badge uses a small font (caption or caption2)

FAVORITE
- Heart icon uses SF Symbol "heart.fill"
- Heart only appears when isFavorite is true (conditional rendering)
- Heart has a visible color (red or similar)
- Heart has padding/offset so it doesn't overlap the card edge

QUALITY
- No force-unwrapping
- ZStack or overlay has explicit alignment (not default .center)
- The card still compiles and renders in #Preview
```
