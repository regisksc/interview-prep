# App 2: Recipe Book ★☆☆

**Covers:** layout, grids, and custom modifiers in [swiftui-advanced.md](../../../lessons/swiftui-advanced.md) — [Custom Layout](../../../lessons/swiftui-advanced.md#custom-layout), [Custom ViewModifiers](../../../lessons/swiftui-advanced.md#custom-viewmodifiers), [GeometryReader](../../../lessons/swiftui-advanced.md#geometryreader-for-custom-layouts).

---

## How it works

1. **Copy** the `starter/` folder into your local practice directory (e.g. `swift-drills/recipe-book/`).
2. Create a **new Xcode project** (iOS App → SwiftUI) in that folder, or open the folder as a Swift Package.
3. Replace the default files with the starter files. Build and run — you'll see a plain list of recipe names.
4. Open **Step 1**, read the linked lesson section, then evolve the app to meet the requirements.
5. When you're done, use the **LLM Review** block at the bottom of the step to get feedback without spoilers.
6. Move to the next step — each one builds on your previous work.

## Steps

| Step | Concept | Lesson section | What changes in the app |
|-----:|---------|---------------|-------------------------|
| [1](steps/step-1-layout-basics.md) | VStack / HStack | [Layout Systems](../../../../README.md#25-auto-layout--layout-systems) | Recipe rows show image, title, and cook time |
| [2](steps/step-2-zstack-overlays.md) | ZStack overlays | [Custom ViewModifiers](../../../lessons/swiftui-advanced.md#custom-viewmodifiers) | Difficulty badge + favorite heart overlaid on cards |
| [3](steps/step-3-scrollview-lazy.md) | ScrollView + LazyVStack | [Lazy Loading](../../../lessons/swiftui-advanced.md#lazy-loading) | Scrollable list with lazy-loaded rows |
| [4](steps/step-4-grid-layout.md) | LazyVGrid | [Custom Layout](../../../lessons/swiftui-advanced.md#custom-layout) | Two-column card grid replaces the list |
| [5](steps/step-5-custom-modifier.md) | Custom ViewModifier | [Creating Reusable Modifiers](../../../lessons/swiftui-advanced.md#creating-reusable-modifiers) | `.cardStyle()` modifier extracts shared styling |
| [6](steps/step-6-geometry-reader.md) | GeometryReader | [GeometryReader](../../../lessons/swiftui-advanced.md#geometryreader-for-custom-layouts) | Grid adapts column count to screen width |
| [7](steps/step-7-conditional-modifiers.md) | Conditional modifiers | [Conditional Modifiers](../../../lessons/swiftui-advanced.md#conditional-modifiers) | Favorites highlighted; category filter pills |

## Starter files

```
starter/
├── RecipeBookApp.swift              ← App entry point
├── Models/
│   └── Recipe.swift                 ← Recipe struct with name, time, category, isFavorite
├── Views/
│   └── ContentView.swift            ← Plain text list — you evolve this
└── Assets.xcassets/
    └── AppIcon.appiconset/
```

You'll also **create** these files during the steps:

- `Views/RecipeRowView.swift` (Step 1)
- `Views/RecipeCardView.swift` (Step 2)
- `ViewModifiers/CardStyle.swift` (Step 5)

> **mockup.png** in this folder shows the finished app.

## Getting LLM feedback

Every step ends with an **LLM Review** section. Copy your code + the review prompt into any LLM. The prompt tells it to check a behavioral rubric and give hints, not solutions.

**Previous app:** [01 — Mood Tracker](../01-mood-tracker/README.md) · **Next app:** [03 — Weather Cards](../03-weather-cards/README.md)
