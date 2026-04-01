# App 7: Expense Tracker ★★★

**Covers:** [swiftui-advanced.md](../../../lessons/swiftui-advanced.md) — [Environment & Preferences](../../../lessons/swiftui-advanced.md#environment--preferences), [UIKit Interop](../../../lessons/swiftui-advanced.md#interop-with-uikit), Module 7 (Performance), Module 9 (Native Features — SwiftData, Swift Charts).

---

## How it works

1. **Copy** the `starter/` folder into your local practice directory (e.g. `swift-drills/expense-tracker/`).
2. Create a **new Xcode project** (iOS App → SwiftUI) in that folder, or open the folder as a Swift Package.
3. Replace the default files with the starter files. Build and run — you'll see a tab bar with placeholder dashboard, list, and add tabs.
4. Open **Step 1**, read the linked lesson section, then evolve the app to meet the requirements.
5. When you're done, use the **LLM Review** block at the bottom of the step to get feedback without spoilers.
6. Move to the next step — each one builds on your previous work.

## Steps

| Step | Concept | Lesson section | What changes in the app |
|-----:|---------|---------------|-------------------------|
| [1](steps/step-1-swift-charts.md) | Swift Charts | [Module 7](../../../../README.md#module-7-performance--optimization), [Apple Charts docs](https://developer.apple.com/documentation/charts) | Weekly spending bar chart on the dashboard |
| [2](steps/step-2-custom-environment.md) | Custom EnvironmentKey | [Custom Environment Values](../../../lessons/swiftui-advanced.md#custom-environment-values) | Currency formatter injected via environment |
| [3](steps/step-3-swiftdata-persistence.md) | SwiftData `@Model` + `@Query` | [Module 9](../../../../README.md#module-9-native-features--frameworks) | Expenses persist with SwiftData |
| [4](steps/step-4-category-breakdown.md) | Derived state + layout | [Custom Layout](../../../lessons/swiftui-advanced.md#custom-layout) | Horizontal category cards with totals and percentages |
| [5](steps/step-5-add-expense-form.md) | Form + validation | [Module 9](../../../../README.md#module-9-native-features--frameworks) | Modal sheet to add expense with validation |
| [6](steps/step-6-export-share.md) | `UIViewControllerRepresentable` | [UIViewControllerRepresentable](../../../lessons/swiftui-advanced.md#uiviewcontrollerrepresentable) | CSV export via UIActivityViewController |

## Starter files

```
starter/
├── ExpenseTrackerApp.swift          ← App entry point
├── Models/
│   └── Expense.swift                ← Expense struct with amount, category, date, note
├── Views/
│   ├── ContentView.swift            ← Tab bar with three tabs
│   ├── DashboardView.swift          ← Placeholder — you build this
│   ├── ExpenseListView.swift        ← Placeholder — you build this
│   └── AddExpenseView.swift         ← Placeholder — you build this
└── Assets.xcassets/
    └── AppIcon.appiconset/
```

You'll also **create** these files during the steps:

- `Views/WeeklyChartView.swift` (Step 1)
- `Views/CategoryCardView.swift` (Step 4)
- `Utilities/CurrencyEnvironmentKey.swift` (Step 2)
- `Utilities/CSVExporter.swift` (Step 6)

> **mockup.png** in this folder shows the finished app.

## Getting LLM feedback

Every step ends with an **LLM Review** section. Copy your code + the review prompt into any LLM. The prompt tells it to check a behavioral rubric and give hints, not solutions.

**Previous app:** [06 — News Reader](../06-news-reader/README.md) · **Next app:** [08 — Mini Social](../08-mini-social/README.md)
