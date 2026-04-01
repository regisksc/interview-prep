# Step 4: View Transitions

**Read first:** [swiftui-advanced.md — Advanced Animations](../../../../lessons/swiftui-advanced.md#advanced-animations) and [swiftui-troubleshooting.md — Animation Issues § Transition not animating](../../../../lessons/swiftui-troubleshooting.md#problem-transition-not-animating)

**Difficulty:** ★★☆ Intermediate

---

## Goal

When a day is selected, a detail panel slides in from the bottom showing extended weather info (humidity, wind, UV index). When deselected, the panel slides out. Use `.transition()` for the insert/remove animation.

## When you're done

- [ ] Selecting a day card shows a detail panel below the cards (or overlaying them)
- [ ] The panel displays the selected day's humidity, wind speed, and UV index
- [ ] The panel uses `.transition(.move(edge: .bottom))` (or a combined transition) to animate in/out
- [ ] The transition is animated (the if/else is inside a container and the state change uses `withAnimation`)
- [ ] Deselecting hides the panel with the reverse transition
- [ ] The transition is smooth (no instant pop-in/pop-out)
- [ ] The app compiles and the `#Preview` works

## Files to edit

- `Views/ContentView.swift`

## Hints

<details>
<summary>Hint 1 — conditional view with transition</summary>
Use <code>if let day = selectedDay { DetailPanel(day: day).transition(.move(edge: .bottom).combined(with: .opacity)) }</code>. The key requirement: the state change that adds/removes this view must be inside <code>withAnimation</code> — otherwise the transition won't animate. You already have <code>withAnimation</code> from Step 1's tap handler.
</details>

<details>
<summary>Hint 2 — combined transitions</summary>
<code>.transition(.move(edge: .bottom).combined(with: .opacity))</code> makes the panel slide up while fading in. You can also use <code>.transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))</code> to have different animations for showing vs hiding. Make sure the parent container (VStack or ZStack) is stable so SwiftUI can track the insertion/removal.
</details>

---

## LLM Review

Copy your `ContentView.swift` and this block into an LLM. Ask it to review without showing corrected code — pass/fail per item with directional hints only.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

TRANSITION
- A detail panel is conditionally shown using if/if-let based on selectedDay
- The panel has a .transition() modifier applied
- The transition uses .move, .opacity, .combined, or .asymmetric
- The state change that triggers insertion/removal is inside withAnimation

CONTENT
- The detail panel shows humidity for the selected day
- The detail panel shows wind speed for the selected day
- The detail panel shows UV index for the selected day
- Day name or temperature is shown as a header in the detail panel

BEHAVIOR
- Selecting a day slides the panel in
- Deselecting (tapping the same day) slides the panel out
- Selecting a different day updates the panel content
- The transition animates smoothly (not instant appear/disappear)

QUALITY
- The detail panel is readable and clearly separated from the card list
- No force-unwrapping
- #Preview compiles
```
