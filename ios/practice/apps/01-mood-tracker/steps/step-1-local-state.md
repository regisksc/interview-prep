# Step 1: Select a Mood

**Read first:** [swiftui-state.md — @State](../../../../lessons/swiftui-state.md#state--local-view-storage)

**Difficulty:** 🟢 Beginner | **Time:** ~15 min

> **Key interview concept — `@State`:**
> *"What is `@State` and when do you use it?"*
> **Answer:** `@State` is a property wrapper for **local, value-type data** owned by a single view. SwiftUI manages its storage — when it changes, the view re-renders. Mark it `private` because no other view should own it.

---

## Goal

The Today tab displays all five moods as tappable emoji buttons. Tapping one selects it (shown with a highlight). Tapping it again deselects it. A header area shows the selected mood or a prompt.

## File to edit

`Views/TodayTab.swift`

---

## Micro-steps

### Add state to track the selected mood

1. Open `Views/TodayTab.swift`.
2. Below `struct TodayTab: View {`, add this property:
   ```swift
   @State private var selectedMood: Mood? = nil
   ```
3. **Build** (Cmd+B). It should compile with zero errors. The `Mood` type comes from `Models/Mood.swift` — it's already in the project.

> **Why `Mood?` (optional)?** When the app launches, no mood is selected yet. `nil` means "nothing selected."

### Display the five mood buttons

4. Find the `body` property. Inside the existing `VStack`, replace any `Spacer()` or placeholder text with:
   ```swift
   ForEach(Mood.allCases) { mood in
       Button {
           // we'll fill this in step 7
       } label: {
           Text(mood.emoji)
               .font(.system(size: 48))
       }
   }
   ```
5. **Run in preview** (Cmd+Option+P, or click the Resume button in the Canvas). You should see **5 emoji buttons** stacked vertically: 😄 🙂 😐 😔 😢.

### Wire up the tap action

6. Replace the `// we'll fill this in step 7` comment inside the `Button` action with:
   ```swift
   if selectedMood == mood {
       selectedMood = nil
   } else {
       selectedMood = mood
   }
   ```
7. **Run in preview.** Tap an emoji — nothing visually changes yet (we haven't styled the selected state). But the code compiles and the taps are wired.

### Style the selected mood button

8. After `.font(.system(size: 48))`, add modifiers to visually highlight the selected mood:
   ```swift
   .padding()
   .background(
       RoundedRectangle(cornerRadius: 12)
           .fill(selectedMood == mood ? Color.blue.opacity(0.2) : Color.clear)
   )
   .scaleEffect(selectedMood == mood ? 1.15 : 1.0)
   .animation(.easeInOut(duration: 0.2), value: selectedMood)
   ```
9. **Run in preview.** Tap 😄 — it should grow slightly and get a blue background. Tap it again — it deselects (shrinks back, background disappears). Tap a different mood — the highlight moves.

### Add the header showing the current selection

10. **Above** the `ForEach`, add this header inside the same `VStack`:
    ```swift
    if let mood = selectedMood {
        Text(mood.emoji)
            .font(.system(size: 72))
        Text(mood.label)
            .font(.title2)
            .foregroundStyle(.secondary)
    } else {
        Text("How are you feeling?")
            .font(.title2)
            .foregroundStyle(.secondary)
    }
    ```
11. **Run in preview.** You should see "How are you feeling?" at the top. Tap 🙂 — the header changes to a large 🙂 with "Good" below it. Tap 🙂 again — it goes back to the prompt text.

### Arrange buttons horizontally (optional polish)

12. Wrap the `ForEach` in an `HStack` instead of leaving them in the `VStack`:
    ```swift
    HStack(spacing: 8) {
        ForEach(Mood.allCases) { mood in
            // ... Button code unchanged ...
        }
    }
    ```
13. **Run in preview.** The five mood buttons should now be in a horizontal row. The header stays above.

### Final build check

14. **Build and Run** (Cmd+R) on a simulator. Verify:
    - [ ] Five moods appear as tappable emoji buttons
    - [ ] Tapping a mood selects it (visual change)
    - [ ] Tapping the same mood again deselects it
    - [ ] Header shows the selection or the prompt
    - [ ] Switching to another tab and back preserves the selection
    - [ ] The `#Preview` compiles and works

---

## Hints (if you get stuck)

<details>
<summary>Hint — the ForEach isn't compiling</summary>
Make sure <code>Mood</code> conforms to <code>Identifiable</code> — check Models/Mood.swift. It should have <code>var id: String { rawValue }</code>.
</details>

<details>
<summary>Hint — the animation looks weird</summary>
Make sure the <code>.animation()</code> modifier is attached to the <code>Text</code> or the <code>Button</code>, not the <code>ForEach</code>. Attach it to the innermost view that changes.
</details>

---

## 🎯 Interview takeaway

You just used `@State` — the most fundamental SwiftUI property wrapper. In an interview, remember:
- `@State` is for **private, local, value-type** data.
- SwiftUI **owns the storage** — you just declare it.
- When `@State` changes, the view's `body` is re-evaluated.
- Always mark it `private` — other views should not directly access another view's `@State`.
- `@State` works for structs, enums, and primitives. For classes, you'll need `@StateObject` (Step 3).

---

## LLM Review

Copy your `TodayTab.swift` and the block below into an LLM. Ask it to review without showing corrected code — pass/fail per item with directional hints only.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

STATE MANAGEMENT
- A property wrapper stores the selected mood locally in the view
- The wrapper is the correct one for local value-type data (not class-based)
- The property is private
- The type allows "no selection" (nil)

BEHAVIOR
- All five Mood cases are rendered (using CaseIterable, not hardcoded)
- A tap handler on each mood updates the selected mood
- Tapping the already-selected mood sets selection to nil
- A prominent display above the buttons reflects the current selection or a placeholder

QUALITY
- No ObservableObject, @StateObject, or @ObservedObject used
- No force-unwrapping
- #Preview compiles
```
