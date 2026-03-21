# Build: Todo List

**Guide:** `FLUTTER_INTERVIEW_PREP.md` → Module 3 (State Management) + Module 5 (Async)

## What to build

A todo list that loads asynchronously on startup. Every mutation updates the UI reactively without a manual rebuild trigger. A filter bar narrows the visible list without re-fetching data.

## Requirements

| Behaviour | Detail |
|-----------|--------|
| Async load | 600 ms simulated delay on startup; spinner during load |
| Add | FAB opens a dialog; new todo appears immediately |
| Toggle | Tapping an item flips its `done` state |
| Delete | Swipe or button removes an item |
| Filter | All / Active / Done — computed outside `build()` |
| Reactivity | Filter change and list mutation both update the UI without calling `setState` in the list widget |

## Seed data

Pre-populate with at least 3 todos (mix of done and active) after the simulated load.

## Constraints

- The filtered list must be derived state — not re-computed inside `build()`
- Mutations must not cause a loading indicator to flash (the list stays visible while mutating)
- `Todo` is immutable; use `copyWith` for updates

## Approach

| Approach | Key APIs |
|----------|----------|
| Riverpod | `AsyncNotifierProvider`, `StateProvider`, derived `Provider`, `AsyncValue.when` |
| Streams + setState | `StreamController<List<Todo>>`, `StreamBuilder`, filter in a derived stream |
| Bloc / Cubit | `Cubit<TodoState>`, `BlocBuilder`, sealed state classes |

## How to run

```bash
cd starter
flutter pub get
flutter run -d chrome
```

> The `starter/` uses only Flutter — add your chosen state package to `starter/pubspec.yaml` before running.
