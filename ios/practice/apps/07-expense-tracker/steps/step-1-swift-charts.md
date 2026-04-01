# Step 1: Weekly Spending Bar Chart

**Read first:** [README — Module 7 (Performance & Optimization)](../../../../README.md#module-7-performance--optimization) + Apple's [Swift Charts documentation](https://developer.apple.com/documentation/charts)

**Difficulty:** ★★★ Advanced

---

## Goal

Display a bar chart of weekly spending using Swift Charts (iOS 16+). Each bar represents one day of the current week with the total amount spent that day.

## When you're done

- [ ] A `Chart` view from the Charts framework renders vertical bars
- [ ] Each bar represents a day (Mon–Sun) with the summed expense amount
- [ ] Days with no expenses show a zero-height bar or are omitted gracefully
- [ ] The chart has labeled axes (day abbreviation on X, currency on Y)
- [ ] The chart updates when expenses change

## Files to edit

- **Create** `Models/Expense.swift`
- **Create** `Views/WeeklyChartView.swift`
- **Edit** `Views/DashboardView.swift` (or main view to host the chart)

## Hints

<details>
<summary>Hint — Swift Charts basics</summary>
Import <code>Charts</code>, then use <code>Chart { ForEach(data) { BarMark(x: .value("Day", $0.day), y: .value("Amount", $0.total)) } }</code>. Group expenses by day of week before passing to the chart.
</details>

---

## LLM Review

Copy your `Expense.swift`, `WeeklyChartView.swift`, and host view plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

SWIFT CHARTS
- Imports the Charts framework
- Uses Chart { } with BarMark (not a custom drawn bar)
- X axis represents days of the week
- Y axis represents currency amounts
- Axis labels are present and readable

DATA PREPARATION
- Expenses are grouped/summed by day of week
- The grouping uses Calendar APIs (not string comparison)
- Days with zero expenses are handled (not missing from the axis)

BEHAVIOR
- The chart reflects current data (reactive to changes)
- The chart renders correctly for a week with no expenses

QUALITY
- Expense model conforms to Identifiable
- No hardcoded day names — derived from Calendar or DateFormatter
- Minimum deployment target is iOS 16
```
