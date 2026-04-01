# App 1: Mood Tracker

**Covers:** every property wrapper in [swiftui-state.md](../../../lessons/swiftui-state.md) — `@State`, `@Binding`, `@StateObject`, `@ObservedObject`, `@AppStorage`, `@EnvironmentObject`, `@Environment`, `@SceneStorage`, and computed/derived state.

---

## How it works

1. **Copy** the `starter/` folder into your local practice directory (e.g. `swift-drills/mood-tracker/`).
2. Create a **new Xcode project** (iOS App → SwiftUI) in that folder, or open the folder as a Swift Package.
3. Replace the default files with the starter files. Build and run — you'll see a tab bar with three mostly-empty tabs.
4. Open **Step 1**, read the linked lesson section, then evolve the app to meet the requirements.
5. When you're done, use the **LLM Review** block at the bottom of the step to get feedback without spoilers.
6. Move to the next step — each one builds on your previous work.

## Steps

| Step | Concept | Lesson section | What changes in the app |
|-----:|---------|---------------|-------------------------|
| [1](steps/step-1-local-state.md) | `@State` | [@State](../../../lessons/swiftui-state.md#state--local-view-storage) | Mood buttons appear, tapping selects one |
| [2](steps/step-2-extract-binding.md) | `@Binding` | [@Binding](../../../lessons/swiftui-state.md#binding--two-way-connection) | Mood picker extracted to reusable child view; note field added |
| [3](steps/step-3-viewmodel.md) | `@StateObject` / `@ObservedObject` | [@StateObject](../../../lessons/swiftui-state.md#stateobject--owned-observableobject) | ViewModel manages mood entries; History tab shows the log |
| [4](steps/step-4-persistence.md) | `@AppStorage` | [@AppStorage](../../../lessons/swiftui-state.md#appstorage--userdefaults-wrapper) | Settings tab persists name + default mood across launches |
| [5](steps/step-5-environment.md) | `@EnvironmentObject` | [@EnvironmentObject](../../../lessons/swiftui-state.md#environmentobject--shared-across-hierarchy) | UserSession injected app-wide; "already logged today" awareness |
| [6](steps/step-6-derived-state.md) | Computed / derived state | [Performance](../../../lessons/swiftui-state.md#performance-considerations) | Stats: streak, most frequent mood, weekly count |
| [7](steps/step-7-adapt-restore.md) | `@Environment` / `@SceneStorage` | [@Environment](../../../lessons/swiftui-state.md#environment--system-values), [@SceneStorage](../../../lessons/swiftui-state.md#scenestorage--scene-restoration) | Dark mode adaptation, tab restoration, Dynamic Type |

## Starter files

```
starter/
├── MoodTrackerApp.swift          ← App entry point
├── Models/
│   └── Mood.swift                ← Mood enum + MoodEntry struct (given)
├── Views/
│   ├── ContentView.swift         ← Tab bar with three tabs
│   ├── TodayTab.swift            ← Title only — you build this
│   ├── HistoryTab.swift          ← Placeholder with empty-state art
│   └── SettingsTab.swift         ← Placeholder
└── Assets.xcassets/
    ├── AppIcon.appiconset/       ← App icon (lavender-to-coral gradient face)
    ├── mood-great.imageset/      ← Golden beaming face
    ├── mood-good.imageset/       ← Green content face
    ├── mood-okay.imageset/       ← Blue-gray neutral face
    ├── mood-bad.imageset/        ← Mauve sad face
    ├── mood-awful.imageset/      ← Indigo crying face
    └── empty-history.imageset/   ← Journal illustration for empty state
```

Use `Image(mood.imageName)` to load any mood's illustration (the `imageName` property is on the `Mood` enum). Drag the entire `Assets.xcassets` folder into your Xcode project to import everything at once.

You'll also **create** these files during the steps:

- `Views/MoodPickerView.swift` (Step 2)
- `ViewModels/MoodViewModel.swift` (Step 3)
- `Models/UserSession.swift` (Step 5)

## Getting LLM feedback

Every step ends with an **LLM Review** section. Copy your code + the review prompt into any LLM. The prompt tells it to check a behavioral rubric and give hints, not solutions.

**Next app:** [02 — Recipe Book](../02-recipe-book/README.md)
