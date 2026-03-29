# iOS Practice

Companion practice material for `../README.md`.

## Setup

```bash
# No dependencies needed for most exercises
# Some challenges may require Xcode Command Line Tools
xcode-select --install
```

---

## challenges/ — Find the Bugs

Each challenge has **3 intentional runtime bugs**. The code compiles and looks normal — the bugs only surface as wrong behavior.

| Challenge | Concepts | Guide Module |
|-----------|----------|-------------|
| `swift_fundamentals/` | Optionals, value vs reference, closures | Module 1 |
| `viewmodel_lifecycle/` | @StateObject vs @ObservedObject, Task cancellation | Module 3 |
| `concurrency/` | Actor isolation, MainActor, async/await | Module 5 |
| `combine_memory/` | Cancellable storage, retain cycles | Module 3, 5 |
| `performance/` | Work in body, unnecessary updates | Module 7 |

```bash
# Open in Xcode and run
open challenges/swift_fundamentals/SwiftFundamentals.xcodeproj
```

---

## build/ — Implement from Scratch

Each exercise provides a domain, required behaviors, and a minimal UI shell. Pick your own state management approach.

| Exercise | Domain | Key Behaviors |
|----------|--------|---------------|
| `counter/` | Counter app | Increment, decrement, reset, persist |
| `live_search/` | Fruit search | Debounce, query cancellation, 3 UI states |
| `todos/` | Todo list | Async load, add, toggle, delete, filter |
| `timer/` | Stopwatch | Reactive tick, pause/resume, no leaks |

```bash
# Start from template
open build/todos/starter/Todos.xcodeproj
```

---

## drills/ — Small Focused Exercises

Short exercises each targeting one Swift or iOS concept.

| Category | Done / Planned | Format |
|----------|----------------|--------|
| `extensions/` | 20 / 80 | Swift file |
| `swift-files/` | 0 / 80 | Swift file |
| `uikit/` | 0 / 80 | Xcode project |
| `swiftui/` | 0 / 80 | Xcode project |
| `multiple-choice/` | 50 questions | Read & answer |

```bash
# Run Swift drills
cd drills/extensions/001-string-extension && swift run
```

---

## State Management Comparison

See [../lessons/state-management-comparison.md](../lessons/state-management-comparison.md) for detailed comparison of:

- @State / @Binding
- ObservableObject + @Published
- Combine
- Redux
- Actor

---

## How to Use This

1. **Read the module** in the main README first
2. **Run the drills** for that topic
3. **Try a challenge** to test your debugging skills
4. **Build an exercise** to practice implementation

---

## Contributing

Found a bug in a challenge? Have a better solution? Open an issue or PR.
