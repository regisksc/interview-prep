# Step 3: Track Mood History

**Read first:** [swiftui-state.md — @StateObject](../../../../lessons/swiftui-state.md#stateobject--owned-observableobject) and [@ObservedObject](../../../../lessons/swiftui-state.md#observedobject--borrowed-observableobject)

**Difficulty:** 🟡 Intermediate | **Time:** ~25 min

> **Key interview concept — `@StateObject` vs `@ObservedObject`:**
> *"When do you use `@StateObject` vs `@ObservedObject`?"*
> **Answer:** Use `@StateObject` in the view that **creates** the object — it survives re-renders. Use `@ObservedObject` in views that **receive** it as a parameter — they borrow but don't own. If you mistakenly use `@ObservedObject` in the creator, the object gets destroyed and recreated on every re-render.

---

## Goal

A `MoodViewModel` manages mood entries. `ContentView` creates and owns it. `TodayTab` can log entries. `HistoryTab` displays them. Both tabs share the same ViewModel.

## Files

- **Create** `ViewModels/MoodViewModel.swift`
- **Edit** `Views/ContentView.swift`
- **Edit** `Views/TodayTab.swift`
- **Edit** `Views/HistoryTab.swift`

---

## Micro-steps

### Create the ViewModel

1. In Xcode, create a new group (folder) called `ViewModels` at the same level as `Views` and `Models`.
2. Inside `ViewModels`, create a new Swift file: `MoodViewModel.swift`.
3. Add this code:
   ```swift
   import Foundation

   class MoodViewModel: ObservableObject {
       @Published var entries: [MoodEntry] = []

       func addEntry(mood: Mood, note: String) {
           let entry = MoodEntry(mood: mood, note: note)
           entries.insert(entry, at: 0)
       }

       func deleteEntry(id: UUID) {
           entries.removeAll { $0.id == id }
       }
   }
   ```
4. **Build** (Cmd+B). Should compile. Key points:
   - `class` (not struct) because `ObservableObject` requires a reference type.
   - `@Published` makes `entries` notify all subscribers when it changes.
   - `insert(at: 0)` puts newest entries first.

### Give ContentView ownership of the ViewModel

5. Open `Views/ContentView.swift`. Add this property at the top of the struct:
   ```swift
   @StateObject private var viewModel = MoodViewModel()
   ```
6. **Build** (Cmd+B). Should compile. `@StateObject` means ContentView **creates and owns** this ViewModel. It won't be destroyed when ContentView re-renders.

### Pass the ViewModel to TodayTab

7. Still in `ContentView.swift`, find where `TodayTab()` is used inside the `TabView`. Change it to:
   ```swift
   TodayTab(viewModel: viewModel)
   ```
8. This won't compile yet — `TodayTab` doesn't accept a `viewModel` parameter. That's okay, we'll fix it next.

### Update TodayTab to receive the ViewModel

9. Open `Views/TodayTab.swift`. Add this property below the existing `@State` properties:
   ```swift
   @ObservedObject var viewModel: MoodViewModel
   ```
   Note: **no** `private`, **no** default value. This is a borrowed reference.
10. **Build** (Cmd+B). The TodayTab `#Preview` will fail — we need to give it a ViewModel. Update the preview:
    ```swift
    #Preview {
        TodayTab(viewModel: MoodViewModel())
    }
    ```
11. **Build** (Cmd+B). Should compile now.

### Add a "Log Mood" button to TodayTab

12. In `TodayTab.swift`, below the `TextField` for the note, add:
    ```swift
    Button("Log Mood") {
        let moodToLog = selectedMood ?? .okay
        viewModel.addEntry(mood: moodToLog, note: noteText)
        selectedMood = nil
        noteText = ""
    }
    .buttonStyle(.borderedProminent)
    .disabled(selectedMood == nil)
    ```
13. **Run in preview.** Select a mood, type a note, and tap "Log Mood." The button should become enabled when a mood is selected, and clear the selection + note after tapping.

> **Why `?? .okay`?** This is a fallback — if somehow `selectedMood` is nil, we use `.okay`. The `.disabled` modifier prevents this in practice, but it's defensive coding.

### Pass the ViewModel to HistoryTab

14. Open `Views/ContentView.swift`. Find where `HistoryTab()` is used. Change it to:
    ```swift
    HistoryTab(viewModel: viewModel)
    ```

### Update HistoryTab to display entries

15. Open `Views/HistoryTab.swift`. Add this property at the top of the struct:
    ```swift
    @ObservedObject var viewModel: MoodViewModel
    ```
16. Replace the placeholder body with:
    ```swift
    NavigationStack {
        List {
            ForEach(viewModel.entries) { entry in
                HStack {
                    Text(entry.mood.emoji)
                        .font(.title)
                    VStack(alignment: .leading) {
                        Text(entry.mood.label)
                            .font(.headline)
                        if !entry.note.isEmpty {
                            Text(entry.note)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Text(entry.date, style: .date)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let entry = viewModel.entries[index]
                    viewModel.deleteEntry(id: entry.id)
                }
            }
        }
        .navigationTitle("History")
        .overlay {
            if viewModel.entries.isEmpty {
                ContentUnavailableView(
                    "No entries yet",
                    systemImage: "book.closed",
                    description: Text("Log a mood in the Today tab")
                )
            }
        }
    }
    ```
17. Update the HistoryTab preview:
    ```swift
    #Preview {
        HistoryTab(viewModel: MoodViewModel())
    }
    ```
18. **Build and Run** (Cmd+R). Verify the full flow:
    - [ ] Go to Today tab → select a mood → type a note → tap "Log Mood"
    - [ ] Selection and note text clear after logging
    - [ ] Switch to History tab → the entry you just logged appears with emoji, label, note, and date
    - [ ] Log a second entry → both appear in History (newest first)
    - [ ] Swipe left on an entry in History → delete works
    - [ ] When History is empty, the "No entries yet" message appears

---

## Architecture check

You now have the **MVVM** pattern in place:
- **Model:** `Mood` enum, `MoodEntry` struct (data)
- **ViewModel:** `MoodViewModel` class (logic + state)
- **View:** `TodayTab`, `HistoryTab`, `MoodPickerView` (UI)

The ViewModel is the single source of truth for entries. Both tabs share the same instance. This is a core iOS architecture pattern interviewers love to ask about.

---

## Hints (if you get stuck)

<details>
<summary>Hint — "Cannot find 'viewModel' in scope"</summary>
Make sure ContentView declares <code>@StateObject private var viewModel = MoodViewModel()</code> and passes it to both tabs.
</details>

<details>
<summary>Hint — changes in one tab don't appear in the other</summary>
Both tabs must receive the <strong>same</strong> ViewModel instance from ContentView. If each tab creates its own <code>MoodViewModel()</code>, they have separate data.
</details>

---

## 🎯 Interview takeaway

You just implemented the **MVVM pattern** and learned **owner vs borrower**:

- **`@StateObject`** = owner. Use it in the view that **creates** the object. Created once, survives re-renders.
- **`@ObservedObject`** = borrower. Use it in views that **receive** the object. Does not control the object's lifetime.
- **`@Published`** = makes a property observable. When it changes, all subscribed views re-render.
- **`ObservableObject`** must be a `class` (reference type), not a struct.
- If an interviewer asks *"What happens if you use @ObservedObject instead of @StateObject to create an object?"* — the object gets destroyed and recreated every time the view re-renders, losing all data.

---

## LLM Review

Copy `MoodViewModel.swift`, `ContentView.swift`, `TodayTab.swift`, and `HistoryTab.swift` plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

VIEWMODEL
- MoodViewModel is a class conforming to ObservableObject
- The entries array uses the wrapper that notifies subscribers of changes
- addEntry creates a MoodEntry and appends it
- deleteEntry removes by ID

OWNERSHIP
- ContentView creates the ViewModel with the OWNING wrapper
- TodayTab receives it with the BORROWING wrapper (not owning)
- HistoryTab receives it with the BORROWING wrapper (not owning)
- The ViewModel is NOT created inside TodayTab or HistoryTab

BEHAVIOR
- "Log Mood" in TodayTab adds an entry with the current mood + note
- After logging, mood selection and note text are cleared
- HistoryTab shows all entries in a List with date, emoji, and note
- Swipe-to-delete in HistoryTab calls deleteEntry
- Changes made in one tab appear immediately in the other

ARCHITECTURE
- MVVM separation is clear: Model (data), ViewModel (logic), View (UI)
- The ViewModel is the single source of truth for entries
- No business logic inside view body properties

QUALITY
- No @State used for the ViewModel (it's a class, not a value type)
- No @EnvironmentObject used yet (that's Step 5)
- All #Previews still compile
```
