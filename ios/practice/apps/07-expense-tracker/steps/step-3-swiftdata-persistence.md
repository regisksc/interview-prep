# Step 3: SwiftData Persistence

**Read first:** [README — Module 9 (Native Features & Frameworks)](../../../../README.md#module-9-native-features--frameworks) — SwiftData replaces Core Data for iOS 17+

**Difficulty:** ★★★ Advanced

---

## Goal

Persist expenses using SwiftData's `@Model` macro. The model container is configured at the app level and queries use `@Query` in views.

## When you're done

- [ ] `Expense` is annotated with `@Model` (SwiftData, not Core Data)
- [ ] The app's `WindowGroup` is wrapped with `.modelContainer(for: Expense.self)`
- [ ] Views use `@Query` to fetch expenses (sorted by date descending)
- [ ] Adding an expense inserts into the model context and appears immediately
- [ ] Deleting an expense removes it from the context and the list
- [ ] Data survives app restart

## Files to edit

- **Edit** `Models/Expense.swift` (convert to @Model)
- **Edit** `App/ExpenseTrackerApp.swift` (add model container)
- **Edit** views that display or create expenses

## Hints

<details>
<summary>Hint — @Model basics</summary>
Annotate the class with <code>@Model</code>. SwiftData auto-generates the schema. Use <code>@Query(sort: \Expense.date, order: .reverse)</code> in views to fetch, and <code>modelContext.insert(expense)</code> / <code>modelContext.delete(expense)</code> to mutate.
</details>

---

## LLM Review

Copy your `Expense.swift`, app entry point, and one view using `@Query` plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

SWIFTDATA MODEL
- Expense is a class annotated with @Model
- Properties are standard Swift types (String, Double/Decimal, Date, etc.)
- The model does NOT use NSManagedObject or Core Data APIs

CONTAINER SETUP
- .modelContainer(for:) is applied at the App or WindowGroup level
- The container includes Expense.self (and any related models)

QUERY & MUTATION
- Views use @Query to fetch expenses (not manual fetch requests)
- @Query includes a sort descriptor (by date)
- Insert uses modelContext.insert()
- Delete uses modelContext.delete()
- Changes appear in the UI immediately after mutation

QUALITY
- No Core Data stack or NSPersistentContainer present
- @Environment(\.modelContext) is used to access the context in views
- The app does not crash on first launch with an empty store
- Minimum deployment target is iOS 17
```
