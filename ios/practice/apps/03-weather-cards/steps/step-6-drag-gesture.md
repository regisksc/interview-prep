# Step 6: Drag Gesture to Dismiss

**Read first:** [swiftui-advanced.md — Advanced Animations § Custom Animations](../../../../lessons/swiftui-advanced.md#custom-animations) (spring parameters for gesture physics)

**Difficulty:** ★★☆ Intermediate

---

## Goal

The expanded detail view can be dismissed by dragging it downward. If dragged past a threshold, it dismisses; otherwise it springs back to position.

## When you're done

- [ ] A `DragGesture` is attached to the expanded detail view
- [ ] Dragging downward moves the expanded view with the finger
- [ ] A `@State` offset property tracks the drag translation
- [ ] If the drag distance exceeds a threshold (e.g. 100pt), the view dismisses (collapse back to card)
- [ ] If the drag distance is below the threshold, the view springs back to its original position
- [ ] The spring-back uses a spring animation
- [ ] The dismiss uses the same matchedGeometryEffect animation from Step 5
- [ ] Upward dragging is clamped or ignored (can't drag above start position)
- [ ] The app compiles and the `#Preview` works

## Files to edit

- `Views/ContentView.swift`

## Hints

<details>
<summary>Hint 1 — DragGesture basics</summary>
Add <code>.gesture(DragGesture().onChanged { value in dragOffset = value.translation }.onEnded { value in ... })</code> to the expanded view. In <code>onChanged</code>, update an <code>@State var dragOffset: CGSize = .zero</code>. Apply it with <code>.offset(y: max(0, dragOffset.height))</code> — the <code>max(0, ...)</code> prevents upward dragging.
</details>

<details>
<summary>Hint 2 — threshold dismiss vs spring-back</summary>
In <code>onEnded</code>, check <code>if value.translation.height > 100</code>. If yes, dismiss: <code>withAnimation(.spring()) { expandedDay = nil; dragOffset = .zero }</code>. If no, spring back: <code>withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { dragOffset = .zero }</code>.
</details>

---

## LLM Review

Copy your `ContentView.swift` and this block into an LLM. Ask it to review without showing corrected code — pass/fail per item with directional hints only.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

GESTURE
- A DragGesture is attached to the expanded detail view
- .onChanged updates a @State offset property with the drag translation
- .onEnded handles the dismiss/spring-back decision
- The expanded view moves with the drag via .offset()

THRESHOLD
- A distance threshold determines dismiss vs spring-back
- Exceeding the threshold dismisses the expanded view
- Below the threshold, the view springs back to origin

SPRING
- Spring-back uses a spring animation (not linear or easeInOut)
- The spring has visible bounce
- Dismissal uses withAnimation for the matchedGeometryEffect reverse animation

CONSTRAINTS
- Upward dragging is prevented or clamped (offset stays ≥ 0)
- The drag offset resets to zero on dismiss
- The drag offset resets to zero on spring-back

QUALITY
- No force-unwrapping
- The expanded view's matched geometry still works during drag
- #Preview compiles
```
