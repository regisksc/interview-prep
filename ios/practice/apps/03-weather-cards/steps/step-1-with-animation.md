# Step 1: Explicit Animation with withAnimation

**Read first:** [swiftui-advanced.md — Advanced Animations](../../../../lessons/swiftui-advanced.md#advanced-animations)

**Difficulty:** ★★☆ Intermediate

---

## Goal

Tapping a day card selects it. The selected card visually expands (e.g. larger frame, highlighted background) and the transition is animated using `withAnimation`.

## When you're done

- [ ] A `@State` property tracks which `DayForecast` is selected (optional, nil by default)
- [ ] Tapping a day card sets it as selected; tapping the selected card deselects it
- [ ] The selected card is visually distinct (e.g. scaled up, colored border, or background change)
- [ ] The state change is wrapped in `withAnimation { }` so the transition animates smoothly
- [ ] The animation uses a non-default curve (e.g. `.easeInOut` or `.spring()`)
- [ ] Other cards remain in their normal state
- [ ] The app compiles and the `#Preview` works

## Files to edit

- `Views/ContentView.swift`

## Hints

<details>
<summary>Hint 1 — wrapping state changes</summary>
In the tap gesture handler, wrap the assignment inside <code>withAnimation(.easeInOut(duration: 0.3)) { selectedDay = day }</code>. This tells SwiftUI to animate any view changes caused by the state mutation.
</details>

<details>
<summary>Hint 2 — visual feedback for selection</summary>
Use <code>.scaleEffect(selectedDay?.id == day.id ? 1.05 : 1.0)</code> and <code>.background(selectedDay?.id == day.id ? Color.blue.opacity(0.15) : Color(.systemBackground))</code> on each card. Because the state change is inside <code>withAnimation</code>, these modifier values animate automatically.
</details>

---

## LLM Review

Copy your `ContentView.swift` and this block into an LLM. Ask it to review without showing corrected code — pass/fail per item with directional hints only.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

STATE
- A @State property tracks the selected day (optional DayForecast or optional UUID)
- Selection allows nil (no day selected)
- Tapping a selected card deselects it (sets to nil)

ANIMATION
- The state change is wrapped in withAnimation { }
- withAnimation uses an explicit animation curve (not just withAnimation { } with default)
- No .animation() modifier used for this selection effect (explicit only)

VISUAL
- The selected card looks different from unselected cards (scale, background, border, or similar)
- The visual change is driven by comparing the selected state to each card's identity
- Unselected cards are in their default/normal state

QUALITY
- ForEach iterates DayForecast.samples using Identifiable conformance
- No force-unwrapping
- #Preview compiles
```
