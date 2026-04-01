# Step 3: Spring Animation on Appear

**Read first:** [swiftui-advanced.md — Advanced Animations § Custom Animations](../../../../lessons/swiftui-advanced.md#custom-animations)

**Difficulty:** ★★☆ Intermediate

---

## Goal

When the view first appears, each day card bounces in with a staggered spring animation instead of appearing all at once.

## When you're done

- [ ] Each card starts offset or scaled down (invisible initial state)
- [ ] On appear, cards animate to their final position using a spring animation
- [ ] Cards appear one after another with a slight stagger delay (not all at once)
- [ ] The spring animation has a visible bounce (not overdamped)
- [ ] The animation only runs once on initial appear (not on every state change)
- [ ] The app compiles and the `#Preview` works

## Files to edit

- `Views/ContentView.swift`

## Hints

<details>
<summary>Hint 1 — staggered appear pattern</summary>
Add a <code>@State private var hasAppeared = false</code> flag. In <code>.onAppear</code>, set it to true. For each card at index <code>i</code>, apply <code>.opacity(hasAppeared ? 1 : 0)</code> and <code>.offset(y: hasAppeared ? 0 : 30)</code> with <code>.animation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(i) * 0.1), value: hasAppeared)</code>.
</details>

<details>
<summary>Hint 2 — getting the index in ForEach</summary>
Use <code>ForEach(Array(forecast.enumerated()), id: \.element.id) { index, day in ... }</code> to access both the index (for stagger delay) and the day forecast. Alternatively use <code>.indices</code> and subscript into the array.
</details>

---

## LLM Review

Copy your `ContentView.swift` and this block into an LLM. Ask it to review without showing corrected code — pass/fail per item with directional hints only.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

ANIMATION
- Cards animate in using a spring animation (not linear or easeInOut)
- The spring has visible bounce (dampingFraction < 1.0)
- Each card has a stagger delay based on its index
- Cards start from an invisible/offset state and animate to final position

TRIGGER
- A @State boolean (or similar) controls the animation trigger
- The flag is set in .onAppear (not in init or body)
- The animation runs only on initial appear (not on every selection change)

VISUAL
- Cards start either offset, scaled down, or transparent (or a combination)
- The final state is the card's normal position/size/opacity
- The stagger is visually noticeable (cards don't all animate simultaneously)

QUALITY
- ForEach provides access to the index for computing stagger delay
- Spring parameters are explicitly set (response, dampingFraction)
- No force-unwrapping
- #Preview compiles
```
