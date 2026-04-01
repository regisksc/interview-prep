# Step 5: Reusable CardStyle Modifier

**Read first:** [swiftui-advanced.md — Custom ViewModifiers § Creating Reusable Modifiers](../../../../lessons/swiftui-advanced.md#creating-reusable-modifiers)

**Difficulty:** ★★☆ Intermediate

---

## Goal

Extract the card styling (background, corner radius, shadow) into a reusable `ViewModifier` so every card uses `.cardStyle()` instead of repeating the same modifiers.

## When you're done

- [ ] A new file `ViewModifiers/CardStyle.swift` exists
- [ ] `CardStyle` is a struct conforming to `ViewModifier`
- [ ] It applies: background color, corner radius, and a subtle shadow
- [ ] A `View` extension adds a `.cardStyle()` method
- [ ] All recipe cards in ContentView use `.cardStyle()` instead of inline styling
- [ ] The card appearance is identical to before (just refactored)
- [ ] The app compiles and the `#Preview` works

## Files to create/edit

- **Create** `ViewModifiers/CardStyle.swift`
- **Edit** `Views/ContentView.swift`

## Hints

<details>
<summary>Hint 1 — ViewModifier protocol</summary>
Create a struct that conforms to <code>ViewModifier</code>. It has one required method: <code>func body(content: Content) -> some View</code>. The <code>content</code> parameter is whatever view the modifier is applied to. Chain your styling modifiers onto it.
</details>

<details>
<summary>Hint 2 — the View extension</summary>
Add <code>extension View { func cardStyle() -> some View { modifier(CardStyle()) } }</code>. This lets any view call <code>.cardStyle()</code>. You can add parameters (e.g. <code>shadowRadius: CGFloat = 4</code>) to make it configurable.
</details>

<details>
<summary>Hint 3 — what to include in the modifier</summary>
A good card modifier typically includes: <code>.background(Color(.systemBackground))</code> for light/dark mode support, <code>.cornerRadius(12)</code>, and <code>.shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)</code>. You might also add <code>.padding(.horizontal, 16)</code> if your cards need consistent outer margins.
</details>

---

## LLM Review

Copy your `CardStyle.swift` and `ContentView.swift` plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

VIEWMODIFIER
- CardStyle is a struct conforming to ViewModifier
- The body(content:) method applies styling to the content parameter
- Styling includes background color, corner radius, and shadow
- The modifier lives in its own file (not inline in ContentView)

EXTENSION
- A View extension provides a .cardStyle() convenience method
- The extension calls modifier(CardStyle()) internally
- The method returns some View

USAGE
- ContentView applies .cardStyle() to each recipe card
- No duplicate background/cornerRadius/shadow modifiers remain inline
- The visual appearance matches what it looked like before the refactor

QUALITY
- Background color supports dark mode (using system color or Color(.systemBackground))
- Shadow is subtle (low opacity and/or small radius)
- No hardcoded colors that would look wrong in dark mode
- #Preview compiles
```
