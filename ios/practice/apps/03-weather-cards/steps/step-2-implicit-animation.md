# Step 2: Implicit Animation for Background Gradient

**Read first:** [swiftui-advanced.md — Advanced Animations](../../../../lessons/swiftui-advanced.md#advanced-animations) and [swiftui-troubleshooting.md — Animation Issues](../../../../lessons/swiftui-troubleshooting.md#animation-issues)

**Difficulty:** ★★☆ Intermediate

---

## Goal

The screen background displays a gradient that shifts color based on the selected day's temperature. The gradient change is driven by an implicit `.animation()` modifier so it transitions smoothly whenever the selected day changes.

## When you're done

- [ ] The background shows a `LinearGradient` (or similar) behind all content
- [ ] Gradient colors change based on the selected day's temperature range (e.g. blue for cold, orange for warm, red for hot)
- [ ] When no day is selected, a neutral/default gradient is shown
- [ ] The gradient transition uses an implicit `.animation(.easeInOut, value:)` modifier
- [ ] Changing selection smoothly transitions the background colors (no instant jump)
- [ ] The gradient does not interfere with card readability
- [ ] The app compiles and the `#Preview` works

## Files to edit

- `Views/ContentView.swift`

## Hints

<details>
<summary>Hint 1 — temperature-based colors</summary>
Create a computed property that returns gradient colors based on temperature: e.g. <code>< 55° → [.blue, .cyan]</code>, <code>55–70° → [.cyan, .yellow]</code>, <code>> 70° → [.orange, .red]</code>. Use the selected day's temperature, or a default when nil.
</details>

<details>
<summary>Hint 2 — implicit animation on the gradient</summary>
Apply <code>.animation(.easeInOut(duration: 0.6), value: selectedDay?.id)</code> to the gradient background view. This animates the gradient whenever <code>selectedDay</code> changes. Place the gradient in a <code>ZStack</code> behind your content, using <code>.ignoresSafeArea()</code> to fill the screen.
</details>

---

## LLM Review

Copy your `ContentView.swift` and this block into an LLM. Ask it to review without showing corrected code — pass/fail per item with directional hints only.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

GRADIENT
- A LinearGradient (or similar gradient) is used as the background
- Gradient colors change based on the selected day's temperature
- At least 2-3 distinct color ranges exist (cold, warm, hot)
- A default/neutral gradient appears when no day is selected

ANIMATION
- The gradient uses an implicit .animation() modifier (not withAnimation)
- The .animation modifier specifies a value parameter (value: selectedDay or similar)
- The animation has an explicit duration or curve
- The gradient transitions smoothly (no instant color jumps)

LAYOUT
- The gradient is behind all content (ZStack or .background)
- The gradient uses .ignoresSafeArea() or fills the full screen
- Card text remains readable over the gradient (contrast or card backgrounds)

QUALITY
- Temperature logic is clean (computed property or function, not inline in body)
- No force-unwrapping
- #Preview compiles
```
