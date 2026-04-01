# Step 6: Stats and Streaks

**Read first:** [swiftui-state.md — Performance Considerations](../../../../lessons/swiftui-state.md#performance-considerations)

**Difficulty:** 🟡 Intermediate | **Time:** ~20 min

> **Key interview concept — Computed vs stored properties:**
> *"Should you use a @Published property or a computed property for derived data?"*
> **Answer:** Use **computed properties** for data derived entirely from other `@Published` data. They recalculate automatically when the source changes — no extra storage, no sync bugs. Use `@Published` only for **independent** source-of-truth data. Storing derived data separately creates a "dual source of truth" problem — the stored value can fall out of sync.

---

## Goal

HistoryTab shows three stats — current streak, most frequent mood, weekly count — all **computed** from the entries array. Never stored separately.

## Files to edit

- **Edit** `ViewModels/MoodViewModel.swift`
- **Edit** `Views/HistoryTab.swift`

---

## Micro-steps

### Add the weeklyCount computed property

1. Open `ViewModels/MoodViewModel.swift`.
2. Below the `deleteEntry` method, add:
   ```swift
   var weeklyCount: Int {
       let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: .now)!
       return entries.filter { $0.date >= sevenDaysAgo }.count
   }
   ```
3. **Build** (Cmd+B). Should compile. This is a **computed property** (no `@Published`) — it recalculates from `entries` every time any view reads it.

### Add the mostFrequentMood computed property

4. Below `weeklyCount`, add:
   ```swift
   var mostFrequentMood: Mood? {
       let grouped = Dictionary(grouping: entries, by: \.mood)
       return grouped.max(by: { $0.value.count < $1.value.count })?.key
   }
   ```
5. **Build** (Cmd+B). Should compile.
   - `Dictionary(grouping:by:)` creates `[Mood: [MoodEntry]]`.
   - `.max(by:)` finds the key with the largest array.
   - Returns `nil` if `entries` is empty.

### Add the currentStreak computed property

6. Below `mostFrequentMood`, add:
   ```swift
   var currentStreak: Int {
       guard !entries.isEmpty else { return 0 }

       let calendar = Calendar.current
       let today = calendar.startOfDay(for: .now)
       var streak = 0
       var checkDate = today

       while true {
           let hasEntry = entries.contains { entry in
               calendar.isDate(entry.date, inSameDayAs: checkDate)
           }
           if hasEntry {
               streak += 1
               guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
               checkDate = previousDay
           } else {
               break
           }
       }

       return streak
   }
   ```
7. **Build** (Cmd+B). Should compile. The logic: start from today, check if any entry exists for that day. If yes, increment streak and check the previous day. Stop at the first day with no entries.

### Verify the computed properties are NOT @Published

8. Double-check: `weeklyCount`, `mostFrequentMood`, and `currentStreak` are all `var name: Type { ... }` — **computed properties** with a body in braces. They do **NOT** have `@Published` in front. This is critical. They derive from `entries`, which IS `@Published`. When `entries` changes, SwiftUI re-renders, and the computed properties recalculate.

### Add a stats section to HistoryTab

9. Open `Views/HistoryTab.swift`.
10. Inside the `List`, **above** the existing `ForEach`, add a stats section:
    ```swift
    Section("Stats") {
        HStack {
            Label("\(viewModel.currentStreak)", systemImage: "flame.fill")
            Text("day streak")
                .foregroundStyle(.secondary)
        }

        HStack {
            Label("\(viewModel.weeklyCount)", systemImage: "calendar")
            Text("this week")
                .foregroundStyle(.secondary)
        }

        if let topMood = viewModel.mostFrequentMood {
            HStack {
                Label(topMood.emoji, systemImage: "crown.fill")
                Text("most frequent: \(topMood.label)")
                    .foregroundStyle(.secondary)
            }
        }
    }
    ```
11. **Build** (Cmd+B). Should compile.

### Wrap the entries in their own section

12. Wrap the existing `ForEach` with its `.onDelete` in a `Section`:
    ```swift
    Section("Entries") {
        ForEach(viewModel.entries) { entry in
            // ... existing entry row code ...
        }
        .onDelete { indexSet in
            // ... existing delete code ...
        }
    }
    ```
13. **Build and Run** (Cmd+R). Full verification:
    - [ ] Log a mood in Today tab
    - [ ] Switch to History tab → stats section shows: streak = 1, weekly count = 1, most frequent mood = the one you logged
    - [ ] Log a second entry with a different mood → weekly count updates to 2
    - [ ] Delete an entry (swipe left) → stats update immediately (count decreases)
    - [ ] If no entries exist, streak = 0, weekly count = 0, most frequent mood row is hidden

### Quick test: stats auto-update

14. Go to Today tab. Log 3 entries with "Great" mood.
15. Switch to History tab. Verify:
    - [ ] Streak = 1 (all on the same day)
    - [ ] Weekly count = 3
    - [ ] Most frequent = 😄 Great
16. Delete one entry. Weekly count should drop to 2 immediately — no refresh button, no manual update.

---

## Architecture check

This step demonstrates a key MVVM principle: **the ViewModel is the right place for derived logic**, not the view. The view's `body` just reads `viewModel.currentStreak` — it doesn't calculate anything. This keeps views simple and logic testable.

If an interviewer asks: *"Where would you put business logic in SwiftUI?"* — the answer is the ViewModel (or a service layer). Never in the view's `body`.

---

## Hints (if you get stuck)

<details>
<summary>Hint — streak is always 0</summary>
Make sure you're checking <code>calendar.isDate(entry.date, inSameDayAs: checkDate)</code>. If you compare exact <code>Date</code> values, timestamps will never match.
</details>

<details>
<summary>Hint — stats don't update when I delete</summary>
Computed properties on <code>ObservableObject</code> recalculate when any <code>@Published</code> property changes. Make sure <code>entries</code> is <code>@Published</code> and your delete method modifies it.
</details>

---

## 🎯 Interview takeaway

You just used **computed (derived) state** — one of the most important patterns for avoiding bugs.

- **Computed properties** derive from `@Published` data. No extra storage, no sync bugs.
- They recalculate automatically when the source data changes.
- **Never** `@Published` a value that can be computed from other `@Published` data — that's a dual source of truth.
- Place derived logic in the ViewModel, not in the view's `body`.
- Common interview question: *"How do you avoid unnecessary re-renders in SwiftUI?"* — Keep computed properties lightweight, use `Equatable` conformance, and avoid doing heavy work in `body`. For expensive computations, consider caching with a flag or using `Combine`.

---

## LLM Review

Copy `MoodViewModel.swift` and `HistoryTab.swift` plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

DERIVED STATE
- currentStreak, mostFrequentMood, weeklyCount are COMPUTED properties (var name: Type { ... })
- They are NOT @Published (no duplicate source of truth)
- They derive entirely from the entries array
- They recalculate when entries changes (no manual refresh)

CORRECTNESS
- currentStreak counts consecutive calendar days backward from today
- mostFrequentMood returns the Mood with the highest entry count
- weeklyCount filters entries to the last 7 calendar days

UI
- HistoryTab has a visible stats section
- Stats display uses the ViewModel's computed properties
- Stats update immediately when an entry is added or deleted

ARCHITECTURE
- Derived logic lives in the ViewModel, not in the view body
- No business logic (filtering, counting, date math) inside view body properties
- The ViewModel remains the single source of truth

QUALITY
- No heavy computation directly inside any view's body property
- Date comparisons use Calendar APIs, not raw TimeInterval arithmetic
- No regressions from Steps 1–5
```
