# Challenge 09: Todo Planner

**API:** `https://dummyjson.com/todos?limit=30`
**Time:** 45 minutes
**Framework:** SwiftUI

## Starting point

A working SwiftUI app that fetches todos, shows them with a completion toggle, and supports filtering by status (all / done / pending). All state, networking, filtering, and toggle logic live in one `ContentView`.

## Files

| File | What it does |
|------|-------------|
| `TodoItem.swift` | Codable model + response wrapper |
| `ContentView.swift` | State, networking, filter, toggle — everything (the mess) |

## Tasks

### 1. Refactor to MVVM (20 min)

Extract a `TodoViewModel` with `@Published` state. Move the filter enum, filtering logic, and toggle logic into the ViewModel. Create a `TodoServiceProtocol` for networking.

### 2. Test the ViewModel (10 min)

Create a `MockTodoService`. Test that toggling a todo flips its `completed` state. Test that filtering returns the correct subset.

### 3. Implement the algorithm (15 min)

`partitionByPriority(_:)` — Partition todos into "do now" (not completed) and "do later" (completed), maintaining the original relative order within each group (stable partition). Currently returns empty arrays.

## Discussion topics

- How does `@State` differ from `@Published` in an `ObservableObject`?
- How would you persist toggle state across app launches?
- Picker styles in SwiftUI — `.segmented` vs `.menu` vs `.wheel`?
