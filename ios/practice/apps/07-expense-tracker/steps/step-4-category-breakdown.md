# Step 4: Category Breakdown Cards

**Difficulty:** ★★★ Advanced

---

## Goal

Display a horizontal scrolling row of category cards. Each card shows the category icon, name, total amount, and percentage of overall spending.

## When you're done

- [ ] Categories are defined as an enum (e.g., food, transport, entertainment, bills, other)
- [ ] A horizontal `ScrollView` with category cards sits above or below the chart
- [ ] Each card displays: category icon (SF Symbol or emoji), name, total amount (formatted), and percentage of total
- [ ] Percentages sum to ~100% across all categories with expenses
- [ ] Categories with no expenses are either hidden or show $0 / 0%
- [ ] The cards update reactively when expenses change

## Files to edit

- **Create** `Models/ExpenseCategory.swift` (if not already defined)
- **Create** `Views/CategoryCard.swift`
- **Edit** `Views/DashboardView.swift`

---

## LLM Review

Copy your `ExpenseCategory.swift`, `CategoryCard.swift`, and `DashboardView.swift` plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

CATEGORY MODEL
- Categories are an enum (CaseIterable for iteration)
- Each case has an associated icon and display name
- The enum is used as the Expense model's category field

CARD LAYOUT
- Cards scroll horizontally in a ScrollView(.horizontal)
- Each card shows icon, name, amount, and percentage
- Cards have consistent sizing and spacing
- The amount uses the currency formatter from the environment (Step 2)

PERCENTAGE CALCULATION
- Each category's percentage = category total / grand total * 100
- Division by zero is handled (no expenses → no crash)
- Percentages are rounded and approximately sum to 100%

QUALITY
- CategoryCard is a reusable, self-contained view
- No hardcoded category lists — derived from the enum
- The layout does not clip or overflow on small screens
```
