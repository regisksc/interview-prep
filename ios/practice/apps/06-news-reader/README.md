# App 6: News Reader ★★★

**Covers:** [combine-framework.md](../../../lessons/combine-framework.md) — [Real-World Patterns](../../../lessons/combine-framework.md#real-world-patterns), Module 5 (Concurrency), Module 7 (Performance), and [swiftui-advanced.md](../../../lessons/swiftui-advanced.md) — [UIKit Interop](../../../lessons/swiftui-advanced.md#interop-with-uikit), [Testing](../../../lessons/swiftui-advanced.md#testing-swiftui).

---

## How it works

1. **Copy** the `starter/` folder into your local practice directory (e.g. `swift-drills/news-reader/`).
2. Create a **new Xcode project** (iOS App → SwiftUI) in that folder, or open the folder as a Swift Package.
3. Replace the default files with the starter files. Build and run — you'll see a tab bar with placeholder feed, search, and saved tabs.
4. Open **Step 1**, read the linked lesson section, then evolve the app to meet the requirements.
5. When you're done, use the **LLM Review** block at the bottom of the step to get feedback without spoilers.
6. Move to the next step — each one builds on your previous work.

## Steps

| Step | Concept | Lesson section | What changes in the app |
|-----:|---------|---------------|-------------------------|
| [1](steps/step-1-async-loading.md) | `async/await` + `.task` | [Module 5](../../../../README.md#module-5-concurrency-asyncawait-actors--tasks) | Articles load asynchronously; loading indicator shown |
| [2](steps/step-2-combine-search.md) | Combine debounced search | [Real-World Patterns](../../../lessons/combine-framework.md#real-world-patterns) | Search bar with debounce + removeDuplicates pipeline |
| [3](steps/step-3-error-states.md) | Loading / error / content enum | [Module 5](../../../../README.md#module-5-concurrency-asyncawait-actors--tasks) | State enum replaces booleans; retry button on errors |
| [4](steps/step-4-webview-bridge.md) | `UIViewRepresentable` | [UIViewRepresentable](../../../lessons/swiftui-advanced.md#uiviewrepresentable) | Article detail renders URL in WKWebView |
| [5](steps/step-5-performance.md) | Performance optimization | [Performance Optimization](../../../lessons/swiftui-advanced.md#performance-optimization) | Lazy images, caching, EquatableView |
| [6](steps/step-6-unit-tests.md) | Unit testing ViewModel | [Testing SwiftUI](../../../lessons/swiftui-advanced.md#testing-swiftui), [Module 8](../../../../README.md#module-8-testing-strategy) | XCTest suite with mock repository |
| [7](steps/step-7-custom-environment.md) | Custom EnvironmentKey + PreferenceKey | [Environment & Preferences](../../../lessons/swiftui-advanced.md#environment--preferences) | Font size via EnvironmentKey; scroll offset via PreferenceKey |

## Starter files

```
starter/
├── NewsReaderApp.swift              ← App entry point
├── Models/
│   └── Article.swift                ← Article struct with title, summary, imageURL, sourceURL
├── Views/
│   ├── ContentView.swift            ← Tab bar with three tabs
│   ├── FeedView.swift               ← Placeholder — you build this
│   ├── SearchView.swift             ← Placeholder — you build this
│   └── SavedView.swift              ← Placeholder — you build this
└── Assets.xcassets/
    └── AppIcon.appiconset/
```

You'll also **create** these files during the steps:

- `ViewModels/FeedViewModel.swift` (Step 1)
- `Services/ArticleRepository.swift` (Step 1)
- `Views/ArticleRowView.swift` (Step 1)
- `Views/ArticleDetailView.swift` (Step 4)
- `Tests/FeedViewModelTests.swift` (Step 6)

> **mockup.png** in this folder shows the finished app.

## Getting LLM feedback

Every step ends with an **LLM Review** section. Copy your code + the review prompt into any LLM. The prompt tells it to check a behavioral rubric and give hints, not solutions.

**Previous app:** [05 — Habit Tracker](../05-habit-tracker/README.md) · **Next app:** [07 — Expense Tracker](../07-expense-tracker/README.md)
