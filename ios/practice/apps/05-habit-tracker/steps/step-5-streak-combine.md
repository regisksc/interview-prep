# Step 5: Streak Calculation with Combine

**Read first:** [combine-framework.md — Key Operators](../../../../lessons/combine-framework.md#key-operators)

**Difficulty:** ★★☆ Intermediate

---

## Goal

Calculate and display the current streak (consecutive days completed up to today) for each habit using a Combine pipeline. Show the streak count on each habit row.

## When you're done

- [ ] Each habit row displays a streak count (e.g., "🔥 5 days")
- [ ] The streak counts consecutive completed days ending at today (or yesterday if today is incomplete)
- [ ] Breaking a day in the middle resets the streak from that point
- [ ] The streak updates reactively when completions change
- [ ] A habit with no completions shows streak 0

## Files to edit

- **Edit** `Models/HabitStore.swift` (add streak publisher or computed pipeline)
- **Edit** `Views/HabitRow.swift`

## Hints

<details>
<summary>Hint — building the pipeline</summary>
Sort the completion dates descending, then use a Combine operator chain (or a computed property that processes the sorted set) to count consecutive days backward from today. If you use Combine, a publisher derived from the habit's completions that emits the streak count works well.
</details>

---

## LLM Review

Copy your updated `HabitStore.swift` and `HabitRow.swift` plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

STREAK LOGIC
- Streak counts consecutive completed days backward from today (or yesterday)
- A gap of one or more days breaks the streak
- Streak is 0 when no recent consecutive completions exist
- The algorithm handles month/year boundaries correctly

COMBINE / REACTIVITY
- The streak recalculates when the completion set changes
- Uses Combine operators, a publisher, or a reactive computed property
- The streak value flows to the UI without manual refresh calls

DISPLAY
- Each habit row shows the streak count
- Zero streaks either show "0 days" or are hidden gracefully
- The streak label does not flash or re-render excessively

QUALITY
- Date iteration uses Calendar.date(byAdding:) — not raw TimeInterval math
- No retain cycles if using Combine sink with self
- Edge case: habit created today with no completions → streak 0
```
