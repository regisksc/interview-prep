# Step 1: Recipe Row Layout

**Read first:** [README — Module 2: UIKit & SwiftUI Lifecycle § 2.5](../../../../README.md#25-auto-layout--layout-systems) (SwiftUI layout with VStack/HStack)

**Difficulty:** ★☆☆ Beginner

---

## Goal

Each recipe in the list becomes a proper row with a placeholder image, the recipe name and cook time stacked vertically, and a difficulty label on the right.

## When you're done

- [ ] Each recipe displays as an HStack row
- [ ] The row starts with a placeholder image using the SF Symbol `"photo"` (via `Image(systemName:)`)
- [ ] Next to the image, a VStack shows the recipe name (headline font) and cook time (subheadline, secondary color)
- [ ] A difficulty label (`recipe.difficulty.label`) appears at the trailing end of the row
- [ ] Rows have consistent vertical spacing between them
- [ ] The placeholder image has a fixed frame (e.g. 50×50) with `.foregroundStyle(.secondary)`
- [ ] The app compiles and the `#Preview` works

## Files to edit

- `Views/ContentView.swift`

## Hints

<details>
<summary>Hint 1 — row structure</summary>
Each row is an <code>HStack</code> containing three sections: an <code>Image(systemName: "photo")</code>, a <code>VStack(alignment: .leading)</code> for name + time, and a <code>Text</code> for difficulty. Use <code>Spacer()</code> to push the difficulty to the trailing edge.
</details>

<details>
<summary>Hint 2 — iterating recipes</summary>
<code>Recipe</code> already conforms to <code>Identifiable</code>, so <code>ForEach(recipes)</code> works directly. Replace the plain <code>Text(recipe.name)</code> with your new row layout.
</details>

<details>
<summary>Hint 3 — styling the image placeholder</summary>
Give the SF Symbol image a fixed <code>.frame(width: 50, height: 50)</code>, add <code>.foregroundStyle(.secondary)</code>, and optionally <code>.background(Color(.systemGray6))</code> with <code>.clipShape(RoundedRectangle(cornerRadius: 8))</code> for a nice placeholder look.
</details>

---

## LLM Review

Copy your `ContentView.swift` and this block into an LLM. Ask it to review without showing corrected code — pass/fail per item with directional hints only.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

LAYOUT
- Each recipe is rendered inside an HStack (not just Text)
- The HStack contains an Image, a VStack, and a difficulty Text
- The Image uses systemName "photo" as a placeholder (not an asset image)
- The VStack has .leading alignment with recipe name and cook time
- The difficulty label is pushed to the trailing edge (Spacer or similar)

STYLING
- Recipe name uses .headline or similar prominent font
- Cook time uses .subheadline or .caption with secondary color
- The placeholder image has a fixed frame size
- The image has .foregroundStyle(.secondary) or equivalent muted color

DATA
- ForEach iterates over the recipes array (not hardcoded rows)
- Recipe.Identifiable conformance is used (no manual id: parameter needed)
- Cook time displays with a unit label (e.g. "30 min")
- Difficulty text uses recipe.difficulty.label

QUALITY
- No hardcoded recipe data in the view
- VStack/HStack spacing is explicit (not relying on defaults everywhere)
- #Preview compiles
```
