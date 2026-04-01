# Step 1: Observable Habit Store

**Read first:** [state-management-comparison.md — ObservableObject + @Published](../../../../lessons/state-management-comparison.md#observableobject--published) (then note: iOS 17's `@Observable` macro replaces this pattern)

**Difficulty:** ★★☆ Intermediate

---

## Goal

Create a `HabitStore` using the `@Observable` macro (iOS 17+) that holds an array of habits. Each habit has a name, icon, and a set of completion dates. The store is the single source of truth for the app.

## When you're done

- [ ] `HabitStore` uses `@Observable` (not `ObservableObject` / `@Published`)
- [ ] A `Habit` model has id, name, icon (String emoji), and a `Set<DateComponents>` for completed days
- [ ] The store exposes `add(habit:)` and `remove(id:)` methods
- [ ] A simple list view shows all habits with name and icon
- [ ] Adding a habit updates the list immediately
- [ ] The app compiles targeting iOS 17+

## Files to create/edit

- **Create** `Models/Habit.swift`
- **Create** `Models/HabitStore.swift`
- **Edit** `Views/ContentView.swift`

## Hints

<details>
<summary>Hint 1 — @Observable vs ObservableObject</summary>
The <code>@Observable</code> macro generates observation tracking automatically — you don't need <code>@Published</code> on each property. Views that reference the store just work without <code>@ObservedObject</code> or <code>@StateObject</code>.
</details>

<details>
<summary>Hint 2 — injecting the store</summary>
With <code>@Observable</code>, you can pass the store via the environment using <code>.environment(store)</code> and read it with <code>@Environment(HabitStore.self)</code> — or simply pass it as a parameter.
</details>

---

## LLM Review

Copy your `Habit.swift`, `HabitStore.swift`, and `ContentView.swift` plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

MODEL
- Habit is a struct with id (UUID), name, icon, and a set of completed date components
- Habit conforms to Identifiable
- HabitStore uses the @Observable macro (NOT ObservableObject)
- No @Published wrappers are present on HabitStore properties

OBSERVATION
- The view accesses HabitStore without @ObservedObject or @StateObject
- Mutations to the habits array trigger UI updates automatically
- The store is either passed as a parameter or injected via .environment()

BEHAVIOR
- A list displays all habits with icon and name
- add(habit:) appends to the array
- remove(id:) deletes by ID
- The UI reflects changes immediately after add/remove

QUALITY
- No ObservableObject, @Published, @StateObject, or @ObservedObject used
- Habit uses value types (struct, not class)
- Minimum deployment target is iOS 17
```
