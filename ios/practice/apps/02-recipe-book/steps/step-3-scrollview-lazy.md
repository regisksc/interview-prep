# Step 3: Scrollable Lazy List

**Read first:** [swiftui-advanced.md — Performance Optimization § Lazy Loading](../../../../lessons/swiftui-advanced.md#lazy-loading)

**Difficulty:** ★☆☆ Beginner

---

## Goal

The recipe list scrolls and uses lazy loading so views are only created when about to appear on screen.

## When you're done

- [ ] All recipe cards are inside a ScrollView
- [ ] The VStack is replaced with a LazyVStack
- [ ] LazyVStack has explicit spacing between cards
- [ ] Scrolling works smoothly even if you add many more sample recipes
- [ ] The navigation title still shows ("Recipes")
- [ ] The app compiles and the `#Preview` works

## Files to edit

- `Views/ContentView.swift`

## Hints

<details>
<summary>Hint 1 — wrapping in ScrollView</summary>
Place a <code>ScrollView</code> around your existing VStack. The ScrollView provides the scrollable area; the inner stack provides the layout direction. A vertical <code>ScrollView</code> is the default axis.
</details>

<details>
<summary>Hint 2 — switching to LazyVStack</summary>
Replace <code>VStack</code> with <code>LazyVStack(spacing: 16)</code>. LazyVStack creates child views only when they're about to scroll into the visible area. Keep the same <code>.padding()</code> you had before.
</details>

<details>
<summary>Hint 3 — why lazy matters</summary>
With a plain VStack, SwiftUI creates ALL child views immediately — expensive for 100+ items. LazyVStack defers creation. You can verify by adding <code>.onAppear { print("Loading \(recipe.name)") }</code> to each card — with LazyVStack, prints happen as you scroll, not all at once.
</details>

---

## LLM Review

Copy your `ContentView.swift` and this block into an LLM. Ask it to review without showing corrected code — pass/fail per item with directional hints only.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

STRUCTURE
- A ScrollView wraps the recipe list
- The inner stack is LazyVStack (not VStack)
- LazyVStack has explicit spacing set
- The ForEach is inside the LazyVStack

BEHAVIOR
- The list scrolls vertically
- Content appears correctly within the scroll area
- Navigation title is still visible (attached to NavigationStack, not inside ScrollView)

PERFORMANCE
- LazyVStack is used instead of VStack (not eager loading)
- No List is used (this step uses ScrollView + LazyVStack, not List)

QUALITY
- Padding is applied sensibly (not causing horizontal overflow)
- The ZStack overlays from Step 2 still work correctly
- #Preview compiles
```
