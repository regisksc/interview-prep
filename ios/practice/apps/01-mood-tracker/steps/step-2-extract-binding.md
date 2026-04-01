# Step 2: Extract the Mood Picker

**Read first:** [swiftui-state.md — @Binding](../../../../lessons/swiftui-state.md#binding--two-way-connection)

**Difficulty:** 🟢 Beginner | **Time:** ~15 min

> **Key interview concept — `@Binding`:**
> *"What is `@Binding` and how does it differ from `@State`?"*
> **Answer:** `@Binding` creates a **two-way connection** to a piece of state owned by another view. The child can read AND write the value, but does **not** own it. The parent passes it with the `$` prefix. This is how SwiftUI avoids duplicating state across views.

---

## Goal

Extract the mood buttons into a reusable `MoodPickerView`. The parent (`TodayTab`) still owns the state. You also add a text field for a mood note.

## Files

- **Create** `Views/MoodPickerView.swift`
- **Edit** `Views/TodayTab.swift`

---

## Micro-steps

### Create the MoodPickerView file

1. In Xcode, right-click the `Views` folder → New File → Swift File. Name it `MoodPickerView.swift`.
2. Replace the file contents with this skeleton:
   ```swift
   import SwiftUI

   struct MoodPickerView: View {
       @Binding var selectedMood: Mood?

       var body: some View {
           Text("Picker placeholder")
       }
   }

   #Preview {
       MoodPickerView(selectedMood: .constant(.good))
   }
   ```
3. **Build** (Cmd+B). It should compile. Note two things:
   - `@Binding var selectedMood: Mood?` — **no default value**. This property must always be provided by the parent.
   - In the `#Preview`, we use `.constant(.good)` — a read-only binding for preview purposes.

### Move the mood buttons from TodayTab into MoodPickerView

4. Open `Views/TodayTab.swift`. **Cut** (Cmd+X) the entire `HStack` containing the `ForEach` over `Mood.allCases` — the button code, the styling, everything.
5. Open `Views/MoodPickerView.swift`. Replace `Text("Picker placeholder")` with the code you just cut.
6. **Build** (Cmd+B). It should compile. The `MoodPickerView` now contains all the mood button UI.

### Use MoodPickerView inside TodayTab

7. Back in `Views/TodayTab.swift`, where you removed the `HStack`, add:
   ```swift
   MoodPickerView(selectedMood: $selectedMood)
   ```
   Note the `$` prefix — this passes a **binding** (two-way connection), not just the value.
8. **Run in preview** for TodayTab. Everything should work exactly like Step 1 — tapping moods selects/deselects them. The header still updates.

> **Why the `$`?** Without it, you'd pass just the current value (read-only). With `$`, you pass a binding — the child can write back to the parent's `@State`.

### Add a note text field to TodayTab

9. In `Views/TodayTab.swift`, add a new `@State` property below `selectedMood`:
   ```swift
   @State private var noteText: String = ""
   ```
10. **Build** (Cmd+B). Should compile.
11. Below the `MoodPickerView(selectedMood: $selectedMood)` line, add:
    ```swift
    TextField("Add a note...", text: $noteText)
        .textFieldStyle(.roundedBorder)
        .padding(.horizontal)
    ```
12. **Run in preview.** You should see:
    - The header (selected mood or prompt)
    - The horizontal row of emoji buttons
    - A text field below the buttons with placeholder "Add a note..."

### Verify the separation is clean

13. Open `Views/MoodPickerView.swift` and confirm it contains **only** the mood buttons — no header, no text field, no title.
14. Open `Views/TodayTab.swift` and confirm it has **no** `ForEach` over `Mood.allCases` — it delegates entirely to `MoodPickerView`.
15. **Build and Run** (Cmd+R) on a simulator. Verify:
    - [ ] Tapping moods still selects/deselects (unchanged from Step 1)
    - [ ] The header still updates
    - [ ] The note text field appears and you can type in it
    - [ ] MoodPickerView's `#Preview` works independently
    - [ ] TodayTab's `#Preview` works

---

## Hints (if you get stuck)

<details>
<summary>Hint — "Cannot convert value of type 'Mood?' to expected argument"</summary>
You probably wrote <code>MoodPickerView(selectedMood: selectedMood)</code> without the <code>$</code>. You need <code>$selectedMood</code> to pass a binding.
</details>

<details>
<summary>Hint — MoodPickerView preview crashes</summary>
Use <code>.constant(.good)</code> or <code>.constant(nil)</code> for the preview binding. You cannot use a raw <code>Mood</code> value.
</details>

---

## 🎯 Interview takeaway

You just used `@Binding` — the standard way to share state **downward** without duplicating it.

- **Parent owns** with `@State`, **child borrows** with `@Binding`.
- Always pass bindings with `$`. The child never sets a default value.
- This is SwiftUI's answer to "single source of truth" — there is exactly **one** copy of `selectedMood`, living in `TodayTab`.
- For previews, use `.constant(value)` to create a read-only binding.
- Common interview follow-up: *"What happens if two views both declare @State for the same data?"* — You get **two independent copies**. They won't sync. That's why @Binding exists.

---

## LLM Review

Copy `TodayTab.swift` and `MoodPickerView.swift` plus this block into an LLM.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

SEPARATION
- MoodPickerView exists as a separate struct in its own file
- MoodPickerView contains ONLY mood button UI (no note field, no title)
- TodayTab has no mood button logic — it delegates entirely to MoodPickerView

DATA FLOW
- TodayTab owns the mood selection with a local value-type state wrapper
- MoodPickerView receives a two-way connection (not a read-only copy)
- MoodPickerView does NOT have a default value for its mood parameter
- Modifying the mood inside MoodPickerView updates TodayTab's state

NEW FEATURE
- A TextField or TextEditor for a note exists in TodayTab (not in MoodPickerView)
- The note text is stored with a local state wrapper in TodayTab

QUALITY
- MoodPickerView compiles in #Preview (uses a constant binding)
- No @StateObject or @EnvironmentObject used yet
- No regressions from Step 1
```
