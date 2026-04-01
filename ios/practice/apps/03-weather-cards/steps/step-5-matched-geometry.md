# Step 5: Hero Animation with matchedGeometryEffect

**Read first:** [swiftui-advanced.md — Advanced Animations § Matched Geometry Effect](../../../../lessons/swiftui-advanced.md#matched-geometry-effect)

**Difficulty:** ★★☆ Intermediate

---

## Goal

Tapping a day card expands it into a full-screen detail view with a hero animation. The card frame smoothly morphs from its list position to fill the screen using `matchedGeometryEffect`.

## When you're done

- [ ] A `@Namespace` property is declared for the geometry matching
- [ ] In the collapsed state, each card has `.matchedGeometryEffect(id:in:)` on its frame/background
- [ ] Tapping a card sets it as the expanded card
- [ ] In the expanded state, a full-screen detail view uses the same `matchedGeometryEffect` id + namespace
- [ ] The card smoothly animates from its list position to full screen (hero transition)
- [ ] Tapping the expanded view collapses it back with the reverse animation
- [ ] The expanded view shows full day details (all weather properties)
- [ ] The app compiles and the `#Preview` works

## Files to edit

- `Views/ContentView.swift`

## Hints

<details>
<summary>Hint 1 — @Namespace and matching IDs</summary>
Declare <code>@Namespace private var heroNamespace</code> at the view level. On each card's background, add <code>.matchedGeometryEffect(id: day.id, in: heroNamespace)</code>. On the expanded detail's background, use the same id and namespace. SwiftUI interpolates the frame between the two.
</details>

<details>
<summary>Hint 2 — switching between states</summary>
Use <code>@State private var expandedDay: DayForecast?</code>. In body, use <code>if let expanded = expandedDay { ExpandedView(...) } else { CardListView(...) }</code>. Wrap the state change in <code>withAnimation(.spring(response: 0.4, dampingFraction: 0.8))</code>. Both branches must apply <code>.matchedGeometryEffect</code> with the matching day's id.
</details>

---

## LLM Review

Copy your `ContentView.swift` and this block into an LLM. Ask it to review without showing corrected code — pass/fail per item with directional hints only.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

MATCHED GEOMETRY
- @Namespace is declared as a property on the view
- .matchedGeometryEffect(id:in:) is applied in the collapsed card state
- .matchedGeometryEffect with the SAME id and namespace is applied in the expanded state
- The id uniquely identifies each card (using day.id or similar)

STATES
- A @State property tracks which day is expanded (optional, nil = none expanded)
- The body uses if/else or conditional to switch between card list and expanded view
- The state change is wrapped in withAnimation with a spring curve

EXPANDED VIEW
- The expanded view shows comprehensive weather details (temp, humidity, wind, UV, condition)
- The expanded view fills more of the screen than the collapsed card
- Tapping the expanded view dismisses it (sets expanded to nil)

ANIMATION
- The transition between collapsed and expanded animates smoothly (hero effect)
- Both the expand and collapse directions animate
- No instant jump between states

QUALITY
- No force-unwrapping
- #Preview compiles
```
