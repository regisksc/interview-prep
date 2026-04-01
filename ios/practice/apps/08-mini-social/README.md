# App 8: Mini Social ★★★

**Covers:** Module 4 (Architecture), Module 5 (Concurrency), Module 8 (Testing) — [swiftui-advanced.md](../../../lessons/swiftui-advanced.md) [Architecture Patterns](../../../lessons/swiftui-advanced.md#architecture-patterns), [Testing SwiftUI](../../../lessons/swiftui-advanced.md#testing-swiftui).

---

## How it works

1. **Copy** the `starter/` folder into your local practice directory (e.g. `swift-drills/mini-social/`).
2. Create a **new Xcode project** (iOS App → SwiftUI) in that folder, or open the folder as a Swift Package.
3. Replace the default files with the starter files. Build and run — you'll see a tab bar with placeholder feed, search, and profile tabs.
4. Open **Step 1**, read the linked lesson section, then evolve the app to meet the requirements.
5. When you're done, use the **LLM Review** block at the bottom of the step to get feedback without spoilers.
6. Move to the next step — each one builds on your previous work.

## Steps

| Step | Concept | Lesson section | What changes in the app |
|-----:|---------|---------------|-------------------------|
| [1](steps/step-1-clean-architecture.md) | Clean Architecture layers | [Module 4](../../../../README.md#module-4-architecture--project-structure), [MVVM + Clean](../../../lessons/swiftui-advanced.md#mvvm--clean-architecture) | Presentation / Domain / Data layers with protocol boundaries |
| [2](steps/step-2-dependency-injection.md) | Protocol-based DI | [Architecture Patterns](../../../lessons/swiftui-advanced.md#architecture-patterns) | DI container resolves protocols; mock-swappable for previews |
| [3](steps/step-3-async-images.md) | `AsyncImage` | [Module 5](../../../../README.md#module-5-concurrency-asyncawait-actors--tasks) | Post images load asynchronously with placeholders |
| [4](steps/step-4-infinite-scroll.md) | Infinite scroll pagination | [Performance Optimization](../../../lessons/swiftui-advanced.md#performance-optimization) | Feed loads pages on scroll; loading indicator at bottom |
| [5](steps/step-5-optimistic-updates.md) | Optimistic updates | [Module 5](../../../../README.md#module-5-concurrency-asyncawait-actors--tasks) | Like/unlike updates UI immediately, rolls back on failure |
| [6](steps/step-6-test-suite.md) | Unit + UI testing | [Testing SwiftUI](../../../lessons/swiftui-advanced.md#testing-swiftui), [Module 8](../../../../README.md#module-8-testing-strategy) | XCTest suite for ViewModel + one UI test |

## Starter files

```
starter/
├── MiniSocialApp.swift              ← App entry point
├── Models/
│   └── Post.swift                   ← Post struct with author, imageURL, caption, likes
├── Views/
│   ├── ContentView.swift            ← Tab bar with three tabs
│   ├── FeedView.swift               ← Placeholder — you build this
│   ├── SearchView.swift             ← Placeholder — you build this
│   └── ProfileView.swift            ← Placeholder — you build this
└── Assets.xcassets/
    └── AppIcon.appiconset/
```

You'll also **create** these files during the steps:

- `Domain/PostRepository.swift` (Step 1 — protocol)
- `Data/MockPostRepository.swift` (Step 1 — mock implementation)
- `Data/RemotePostRepository.swift` (Step 1 — real implementation)
- `DI/DependencyContainer.swift` (Step 2)
- `ViewModels/FeedViewModel.swift` (Step 1)
- `Views/PostCardView.swift` (Step 3)
- `Tests/FeedViewModelTests.swift` (Step 6)

> **mockup.png** in this folder shows the finished app.

## Getting LLM feedback

Every step ends with an **LLM Review** section. Copy your code + the review prompt into any LLM. The prompt tells it to check a behavioral rubric and give hints, not solutions.

**Previous app:** [07 — Expense Tracker](../07-expense-tracker/README.md)
