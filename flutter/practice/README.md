# Flutter Interview Practice

Two types of exercises: bug challenges and a build-from-scratch app.

---

## Bug Challenges

Each folder under `challenges/` is a runnable Flutter app with 3 intentional
bugs. The bugs compile cleanly and look like normal code — they only surface
as wrong runtime behavior. Find and fix them before reading `SOLUTIONS.md`.

| Folder | Topic | What breaks |
|---|---|---|
| `dart_fundamentals/` | Dart basics | Duplicate check, immutability, list iteration |
| `widget_lifecycle/` | Lifecycle | Timer leak, async context, resource disposal |
| `state_management/` | Riverpod | State mutation, ref.watch in callback, derived provider |
| `async_streams/` | Async | Stream leak, missing await, sequential vs parallel |
| `performance/` | Performance | Build-time computation, list virtualization, unnecessary rebuild |

### How to run a challenge

```bash
cd challenges/dart_fundamentals
flutter run
```

Interact with the app until you observe the broken behavior, then hunt the
bug in `lib/main.dart`. Solutions are in `SOLUTIONS.md` — only look after
you've made a genuine attempt.

---

## Riverpod Starter

`riverpod_starter/` is a blank slate with `ProviderScope` and `flutter_riverpod`
already configured. Follow the steps in its `README.md` to build a Notes app
from scratch using only Riverpod — no StatefulWidget, no setState.

```bash
cd riverpod_starter
flutter run
```
