# Flutter Practice

Companion practice material for `../README.md`.

## Setup

```bash
flutter pub get   # resolves all workspace packages at once
```

---

## challenges/ — Find the bugs

Each is a runnable Flutter app with **3 intentional runtime bugs**. The app compiles and looks normal — the bugs only surface as wrong behaviour.

| Challenge | Concepts | Guide module |
|-----------|----------|-------------|
| `dart_fundamentals/` | Value equality, copyWith, collection mutation | Module 1 |
| `widget_lifecycle/` | initState/dispose, Timer, async + BuildContext | Module 2 |
| `riverpod/` | Notifier immutability, ref.watch vs ref.read, derived providers | Module 3 |
| `async_streams/` | StreamSubscription lifecycle, await, parallel futures | Module 5 |
| `performance/` | Work in build(), lazy lists, conditional setState | Module 7 |

```bash
cd challenges/dart_fundamentals && flutter run
```

---

## build/ — Implement from scratch

Each exercise provides a domain, required behaviours, and a minimal UI shell. Pick your own state management approach — the starter has no package pre-added.

| Exercise | Domain | Key behaviours |
|----------|--------|----------------|
| `stopwatch/` | Stopwatch | Reactive tick, pause/resume, no leaks |
| `live_search/` | Fruit search | Debounce, query cancellation, 3 UI states |
| `todos/` | Todo list | Async load, mutations, derived filter |

```bash
cd build/todos/starter
# add your chosen package to pubspec.yaml, then:
flutter pub get && flutter run -d chrome
```

---

## drills/ — Small focused exercises

Short exercises each targeting one Dart or Flutter concept.

| Category | Done / Planned | Format |
|----------|----------------|--------|
| `extensions/` | 20 / 80 | `dart run` |
| `dart-files/` | 0 / 80 | `dart run` |
| `widgets/` | 0 / 80 | `flutter run` |
| `multiple-choice/` | 50 questions | Read & answer |

```bash
cd drills/extensions/001-movie-length && dart run
```
