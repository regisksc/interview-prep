# Build: Live Search

**Guide:** `README.md` → Module 5 (Async & Streams)

## What to build

A search screen that filters a fruit dataset reactively. The search fires automatically as the user types, but not on every single keystroke — input must settle before a query runs, and a new query must cancel any in-flight search.

## Requirements

| Behaviour | Detail |
|-----------|--------|
| Debounce | Search fires ~300 ms after the user stops typing |
| Cancellation | A new query cancels the previous in-flight search |
| Idle state | Empty query → "Start typing to search" |
| Loading state | Between input settling and results arriving → spinner |
| Results state | Matching items in a list, or "No results" |
| Cleanup | Subject / subscription closed in `dispose` |

## Constraints

- No `Timer`-based debounce — use stream operators
- The results pipeline must be built **once** (not inside `build()`)
- Stale results from a slow previous query must never overwrite a newer one

## Approach

| Approach | Key APIs |
|----------|----------|
| RxDart | `BehaviorSubject`, `debounceTime`, `distinct`, `switchMap` |
| Vanilla streams | `StreamController`, `debounce` (manual), `Stream.switchMap` |
| Riverpod | `StreamProvider.family`, `debounce` via `ref.listenManual` |

## How to run

```bash
cd starter
flutter pub get
flutter run -d chrome
```

> The `starter/` has no reactive package pre-added. Add the one you choose to `starter/pubspec.yaml` before running.
