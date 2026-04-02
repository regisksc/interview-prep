# Challenge 05: Todo Manager

## Description

A todo app that fetches tasks from an API and lets the user toggle completion and filter by status. Each todo has: todo text, completed flag, userId.

**API:** `https://dummyjson.com/todos?limit=30`

### Key Classes

- `main.dart` — everything in one file.

## Goal

Refactor to a testable architecture with proper state management.

### Tasks

1. **Refactor** — Extract Model, Repository (abstract + concrete), and ViewModel/Controller. Use ChangeNotifier or any state management. Separate widgets: TodoListScreen, TodoTile. Add tests for the ViewModel.

2. **Algorithm** — Implement a stable partition: split todos into "do now" (completed=false, userId <= 5) and "do later" (everything else), preserving original order within each group. The `stablePartition()` function currently returns the list unchanged.

3. **Feature** — Add a segmented control (All / Active / Completed) that filters the list. Add a counter badge showing active count.

### Discussion

- How would you persist toggle state locally between app launches?
- What's the difference between optimistic and pessimistic UI updates?
- How would you add undo for toggling a todo?
