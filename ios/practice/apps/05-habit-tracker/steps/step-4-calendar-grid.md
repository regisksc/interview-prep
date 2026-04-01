# Step 4: Calendar Completion Grid

**Difficulty:** ★★☆ Intermediate

---

## Goal

A calendar view for a selected habit showing which days were completed. Use `LazyVGrid` to lay out day cells in a 7-column grid for the current month.

## When you're done

- [ ] A 7-column grid shows all days of the current month
- [ ] Column headers display weekday abbreviations (S, M, T, W, T, F, S)
- [ ] Days when the habit was completed show a filled dot or highlight
- [ ] The first day of the month starts in the correct weekday column
- [ ] Tapping a past day toggles its completion status
- [ ] The current day is visually distinct

## Files to edit

- **Create** `Views/CalendarGrid.swift`
- Wire it into a detail view or sheet for a selected habit

## Hints

<details>
<summary>Hint — aligning the first day</summary>
Use <code>Calendar.current.component(.weekday, from:)</code> on the first day of the month to determine how many blank spacer cells to prepend in the grid.
</details>

---

## LLM Review

Copy your `CalendarGrid.swift` plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

GRID LAYOUT
- Uses LazyVGrid with 7 fixed or flexible columns
- Weekday headers are displayed above the grid
- The first day of the month is offset to the correct weekday column
- Empty cells (before day 1 and after last day) don't show numbers

COMPLETION DISPLAY
- Days with a completion record are visually marked (dot, fill, or highlight)
- Days without completion are visually distinct from completed days
- Today's date has a unique visual treatment

INTERACTION
- Tapping a day cell toggles that day's completion in the store
- Future dates are either disabled or not tappable

DATA
- The grid derives days from Calendar APIs (not hardcoded 1–30)
- Month and year are determined dynamically
- Completion lookup matches year/month/day components correctly

QUALITY
- CalendarGrid accepts a Habit (or habit ID + binding) — not coupled to a specific store property
- No force-unwrapping of date math
- The grid doesn't break for months with 28, 29, 30, or 31 days
```
