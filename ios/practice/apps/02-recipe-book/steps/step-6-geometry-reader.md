# Step 6: Responsive Layout with GeometryReader

**Read first:** [swiftui-advanced.md — Custom Layout § GeometryReader](../../../../lessons/swiftui-advanced.md#geometryreader-for-custom-layouts)

**Difficulty:** ★★☆ Intermediate

---

## Goal

The grid adapts to screen width: single-column on narrow screens (compact width), two-column on wider screens. Use GeometryReader to read the available width and choose the column count.

## When you're done

- [ ] A GeometryReader wraps the grid content
- [ ] When the available width is below a threshold (e.g. 500pt), the grid shows 1 column
- [ ] When the width is ≥ the threshold, the grid shows 2 columns
- [ ] Rotating an iPad (or resizing a preview) switches between layouts
- [ ] The grid columns are computed from the geometry, not hardcoded
- [ ] Content doesn't jump or clip during rotation
- [ ] The app compiles and the `#Preview` works

## Files to edit

- `Views/ContentView.swift`

## Hints

<details>
<summary>Hint 1 — reading available width</summary>
Wrap your <code>ScrollView</code> content in a <code>GeometryReader { geo in ... }</code>. Read <code>geo.size.width</code> to decide how many columns to show. You can define a helper: <code>let columnCount = geo.size.width < 500 ? 1 : 2</code>.
</details>

<details>
<summary>Hint 2 — dynamic GridItem array</summary>
Create the columns array from the count: <code>Array(repeating: GridItem(.flexible()), count: columnCount)</code>. Pass this to your existing <code>LazyVGrid</code>. The grid will re-layout when the count changes.
</details>

<details>
<summary>Hint 3 — GeometryReader sizing gotcha</summary>
GeometryReader expands to fill all available space and proposes zero size to its children. If your content disappears, make sure the <code>ScrollView</code> is <em>inside</em> the GeometryReader, and your content uses <code>.frame(maxWidth: .infinity)</code> rather than relying on GeometryReader to size it.
</details>

---

## LLM Review

Copy your `ContentView.swift` and this block into an LLM. Ask it to review without showing corrected code — pass/fail per item with directional hints only.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

GEOMETRY
- A GeometryReader is used to read the available width
- The column count is derived from geo.size.width (not hardcoded)
- A sensible width threshold determines single vs multi-column layout
- The GridItem array is built dynamically from the column count

RESPONSIVE
- Narrow width (< threshold) shows 1 column
- Wide width (≥ threshold) shows 2 columns
- The layout changes appropriately when screen size changes (rotation, resize)

LAYOUT
- Content renders correctly in both 1-column and 2-column modes
- No content clipping or overflow in either mode
- Cards fill available column width in both modes

QUALITY
- GeometryReader does not cause content to collapse to zero size
- The .cardStyle() modifier still applies correctly
- No hardcoded pixel widths for cards
- #Preview compiles (test with different preview device sizes if possible)
```
