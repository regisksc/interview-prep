# App 3: Weather Cards ★★☆

**Covers:** animation techniques in [swiftui-advanced.md](../../../lessons/swiftui-advanced.md) — [Advanced Animations](../../../lessons/swiftui-advanced.md#advanced-animations), [Matched Geometry Effect](../../../lessons/swiftui-advanced.md#matched-geometry-effect), [Custom Animations](../../../lessons/swiftui-advanced.md#custom-animations).

---

## How it works

1. **Copy** the `starter/` folder into your local practice directory (e.g. `swift-drills/weather-cards/`).
2. Create a **new Xcode project** (iOS App → SwiftUI) in that folder, or open the folder as a Swift Package.
3. Replace the default files with the starter files. Build and run — you'll see static day cards with no animation.
4. Open **Step 1**, read the linked lesson section, then evolve the app to meet the requirements.
5. When you're done, use the **LLM Review** block at the bottom of the step to get feedback without spoilers.
6. Move to the next step — each one builds on your previous work.

## Steps

| Step | Concept | Lesson section | What changes in the app |
|-----:|---------|---------------|-------------------------|
| [1](steps/step-1-with-animation.md) | `withAnimation` | [Advanced Animations](../../../lessons/swiftui-advanced.md#advanced-animations) | Tapping a card selects it with animated expansion |
| [2](steps/step-2-implicit-animation.md) | Implicit `.animation()` | [Advanced Animations](../../../lessons/swiftui-advanced.md#advanced-animations), [Animation Issues](../../../lessons/swiftui-troubleshooting.md#animation-issues) | Background gradient shifts with temperature |
| [3](steps/step-3-spring-animation.md) | Spring animations | [Custom Animations](../../../lessons/swiftui-advanced.md#custom-animations) | Cards bounce in with staggered spring on appear |
| [4](steps/step-4-transitions.md) | Transitions | [Advanced Animations](../../../lessons/swiftui-advanced.md#advanced-animations), [Transition Issues](../../../lessons/swiftui-troubleshooting.md#problem-transition-not-animating) | Detail panel slides in/out on selection |
| [5](steps/step-5-matched-geometry.md) | `matchedGeometryEffect` | [Matched Geometry Effect](../../../lessons/swiftui-advanced.md#matched-geometry-effect) | Tap card → hero animation to full-screen detail |
| [6](steps/step-6-drag-gesture.md) | Drag gesture + spring | [Custom Animations](../../../lessons/swiftui-advanced.md#custom-animations) | Drag expanded card down to dismiss |

## Starter files

```
starter/
├── WeatherCardsApp.swift            ← App entry point
├── Models/
│   └── Weather.swift                ← WeatherDay struct with temp, condition, icon
├── Views/
│   └── ContentView.swift            ← Static day cards — you animate these
└── Assets.xcassets/
    └── AppIcon.appiconset/
```

You'll also **create** these files during the steps:

- `Views/DayCardView.swift` (Step 1)
- `Views/WeatherDetailView.swift` (Step 4)

> **mockup.png** in this folder shows the finished app.

## Getting LLM feedback

Every step ends with an **LLM Review** section. Copy your code + the review prompt into any LLM. The prompt tells it to check a behavioral rubric and give hints, not solutions.

**Previous app:** [02 — Recipe Book](../02-recipe-book/README.md) · **Next app:** [04 — Contacts](../04-contacts/README.md)
