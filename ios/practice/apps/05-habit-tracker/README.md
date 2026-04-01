# App 5: Habit Tracker ★★☆

**Covers:** [state-management-comparison.md](../../../lessons/state-management-comparison.md) — [ObservableObject + @Published](../../../lessons/state-management-comparison.md#observableobject--published) and [combine-framework.md](../../../lessons/combine-framework.md) — [Key Operators](../../../lessons/combine-framework.md#key-operators), [SwiftUI Integration](../../../lessons/combine-framework.md#swiftui-integration).

---

## How it works

1. **Copy** the `starter/` folder into your local practice directory (e.g. `swift-drills/habit-tracker/`).
2. Create a **new Xcode project** (iOS App → SwiftUI) in that folder, or open the folder as a Swift Package.
3. Replace the default files with the starter files. Build and run — you'll see tab bar with placeholder tabs.
4. Open **Step 1**, read the linked lesson section, then evolve the app to meet the requirements.
5. When you're done, use the **LLM Review** block at the bottom of the step to get feedback without spoilers.
6. Move to the next step — each one builds on your previous work.

## Steps

| Step | Concept | Lesson section | What changes in the app |
|-----:|---------|---------------|-------------------------|
| [1](steps/step-1-observable-model.md) | `@Observable` / `ObservableObject` | [ObservableObject + @Published](../../../lessons/state-management-comparison.md#observableobject--published) | HabitStore holds habits; Today tab shows the list |
| [2](steps/step-2-toggle-completion.md) | Animated state toggle | [Advanced Animations](../../../lessons/swiftui-advanced.md#advanced-animations) | Tap checkmark to toggle today's completion |
| [3](steps/step-3-progress-ring.md) | Custom Shape / Canvas | [Custom Layout](../../../lessons/swiftui-advanced.md#custom-layout) | Circular progress ring at the top of the list |
| [4](steps/step-4-calendar-grid.md) | LazyVGrid calendar | [Custom Layout](../../../lessons/swiftui-advanced.md#custom-layout) | Calendar tab: 7-column grid showing completion days |
| [5](steps/step-5-streak-combine.md) | Combine pipeline | [Key Operators](../../../lessons/combine-framework.md#key-operators) | Streak count calculated via Combine, shown per habit |
| [6](steps/step-6-persistence.md) | `@AppStorage` + Codable | [SwiftUI Integration](../../../lessons/combine-framework.md#swiftui-integration) | Habits persist across app restarts |

## Starter files

```
starter/
├── HabitTrackerApp.swift            ← App entry point
├── Models/
│   └── Habit.swift                  ← Habit struct with name, icon, completionDates
├── Views/
│   ├── ContentView.swift            ← Tab bar with three tabs
│   ├── TodayView.swift              ← Placeholder — you build this
│   ├── CalendarView.swift           ← Placeholder — you build this
│   └── StatsView.swift              ← Placeholder — you build this
└── Assets.xcassets/
    └── AppIcon.appiconset/
```

You'll also **create** these files during the steps:

- `ViewModels/HabitStore.swift` (Step 1)
- `Views/HabitRowView.swift` (Step 2)
- `Views/ProgressRingView.swift` (Step 3)

> **mockup.png** in this folder shows the finished app.

## Getting LLM feedback

Every step ends with an **LLM Review** section. Copy your code + the review prompt into any LLM. The prompt tells it to check a behavioral rubric and give hints, not solutions.

**Previous app:** [04 — Contacts](../04-contacts/README.md) · **Next app:** [06 — News Reader](../06-news-reader/README.md)
