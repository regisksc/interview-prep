# Step 5: Add Expense Form

**Difficulty:** ★★★ Advanced

---

## Goal

A modal sheet with a form to add a new expense: category picker, amount text field with currency keyboard, date picker, and optional note. Validate before saving.

## When you're done

- [ ] A "+" button presents a sheet with the add expense form
- [ ] The form includes: category picker (Picker or segmented), amount field (decimal pad), date picker, optional note field
- [ ] The Save button is disabled when amount is empty or zero
- [ ] Saving inserts the expense into SwiftData and dismisses the sheet
- [ ] Cancel dismisses without saving
- [ ] The amount field accepts decimal input and validates it as a number

## Files to edit

- **Create** `Views/AddExpenseView.swift`
- **Edit** the view that presents the sheet (e.g., `DashboardView.swift`)

---

## LLM Review

Copy your `AddExpenseView.swift` and the presenting view plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

FORM FIELDS
- Category picker uses Picker (wheel, segmented, or menu style)
- Amount field uses TextField with .keyboardType(.decimalPad)
- Date picker uses DatePicker
- An optional note field is present

VALIDATION
- Save button is disabled when amount is invalid (empty, zero, or non-numeric)
- The amount string is parsed to a numeric type before saving
- No negative amounts are allowed (or they are handled intentionally)

SHEET LIFECYCLE
- The form is presented in a .sheet modifier
- Cancel dismisses via @Environment(\.dismiss)
- Save inserts into modelContext then dismisses
- Form fields reset on next presentation (no stale data)

QUALITY
- @Environment(\.modelContext) is used to insert
- The form uses Form { } or grouped sections for clean layout
- No force-unwrapping of the parsed amount
- The keyboard does not obscure the active field
```
