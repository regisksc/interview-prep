# iOS Practice

Companion practice material for [`../README.md`](../README.md).

## Setup

```bash
xcode-select --install
```

---

## apps/ — Progressive projects (primary practice path)

Each app starts from a **pre-built starter** and evolves through **step-by-step exercises**. One concept per step, each linked to a lesson section. Every step includes an **LLM Review** rubric so you can get feedback without spoilers.

| App | Concepts | Steps |
|-----|----------|------:|
| [01 — Mood Tracker](apps/01-mood-tracker/README.md) | All SwiftUI state wrappers | 7 |
| [02 — Recipe Book](apps/02-recipe-book/README.md) | Layout + modifiers | 7 |
| [03 — Weather Cards](apps/03-weather-cards/README.md) | Animation + gestures | 6 |
| [04 — Contacts](apps/04-contacts/README.md) | Lists + navigation | 7 |
| [05 — News Reader](apps/05-news-reader/README.md) | Async, Combine, UIKit interop, testing | 7 |

**Full map:** [lessons/lesson-practice-map.md](../lessons/lesson-practice-map.md)

**Where to work:** copy starter files into a local Xcode project under [`swift-drills/`](../../swift-drills/) (git-ignored).

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

---

## build/ — Implement from Scratch

Each exercise provides a domain, required behaviors, and a minimal UI shell.

| Exercise | Domain | Key Behaviors |
|----------|--------|---------------|
| `counter/` | Counter app | Increment, decrement, reset, persist |
| `live_search/` | Fruit search | Debounce, query cancellation, 3 UI states |
| `todos/` | Todo list | Async load, add, toggle, delete, filter |
| `timer/` | Stopwatch | Reactive tick, pause/resume, no leaks |

---

## drills/ — Quick standalone exercises

Short exercises targeting one concept each. Useful for targeted reps alongside the apps.

| Category | Count | Format |
|----------|-------|--------|
| `extensions/` | 20 | Swift file |
| `swift-files/` | 20 | Swift file |
| `uikit/` | 20 | Xcode project |
| `swiftui/` | Starters 1–5 + specs 6–60 | [drills README](drills/swiftui/README.md) |
| `multiple-choice/` | 50 questions | Read & answer |

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
