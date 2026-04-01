# App 4: Contacts ★★☆

**Covers:** Module 6 (Navigation) and list troubleshooting in [swiftui-troubleshooting.md](../../../lessons/swiftui-troubleshooting.md) — [List Issues](../../../lessons/swiftui-troubleshooting.md#list-issues).

---

## How it works

1. **Copy** the `starter/` folder into your local practice directory (e.g. `swift-drills/contacts/`).
2. Create a **new Xcode project** (iOS App → SwiftUI) in that folder, or open the folder as a Swift Package.
3. Replace the default files with the starter files. Build and run — you'll see a plain VStack of contact names.
4. Open **Step 1**, read the linked lesson section, then evolve the app to meet the requirements.
5. When you're done, use the **LLM Review** block at the bottom of the step to get feedback without spoilers.
6. Move to the next step — each one builds on your previous work.

## Steps

| Step | Concept | Lesson section | What changes in the app |
|-----:|---------|---------------|-------------------------|
| [1](steps/step-1-list-basics.md) | `List` + `ForEach` | [Module 6](../../../../README.md#module-6-navigation--view-controllers), [List Issues](../../../lessons/swiftui-troubleshooting.md#list-issues) | VStack replaced with proper List |
| [2](steps/step-2-custom-rows.md) | Custom list rows | [View Lifecycle](../../../../README.md#23-swiftui-view-lifecycle), [List Issues](../../../lessons/swiftui-troubleshooting.md#list-issues) | Initials circle, name, subtitle in each row |
| [3](steps/step-3-swipe-delete.md) | Swipe-to-delete | [Swipe-to-Delete Issues](../../../lessons/swiftui-troubleshooting.md#problem-swipe-to-delete-not-working) | Swipe to remove; EditButton for multi-delete |
| [4](steps/step-4-navigation.md) | NavigationStack | [SwiftUI Navigation](../../../../README.md#62-swiftui-navigation) | Tap a contact → detail view |
| [5](steps/step-5-sections.md) | Sections + headers | [Module 6](../../../../README.md#module-6-navigation--view-controllers), [List Issues](../../../lessons/swiftui-troubleshooting.md#list-issues) | Alphabetical sections with letter headers |
| [6](steps/step-6-searchable.md) | `.searchable` | [Module 6](../../../../README.md#module-6-navigation--view-controllers), [List Issues](../../../lessons/swiftui-troubleshooting.md#list-issues) | Search bar filters contacts in real time |
| [7](steps/step-7-sheets-alerts.md) | Sheets + alerts | [Module 6](../../../../README.md#module-6-navigation--view-controllers), [State Issues](../../../lessons/swiftui-troubleshooting.md#state-issues) | Add-contact sheet, delete alert, pull to refresh |

## Starter files

```
starter/
├── ContactsApp.swift                ← App entry point
├── Models/
│   └── Contact.swift                ← Contact struct (Identifiable, name, company, phone, email)
├── Views/
│   └── ContentView.swift            ← Plain VStack of names — you evolve this
└── Assets.xcassets/
    └── AppIcon.appiconset/
```

You'll also **create** these files during the steps:

- `Views/ContactRowView.swift` (Step 2)
- `Views/ContactDetailView.swift` (Step 4)
- `Views/AddContactSheet.swift` (Step 7)

> **mockup.png** in this folder shows the finished app.

## Getting LLM feedback

Every step ends with an **LLM Review** section. Copy your code + the review prompt into any LLM. The prompt tells it to check a behavioral rubric and give hints, not solutions.

**Previous app:** [03 — Weather Cards](../03-weather-cards/README.md) · **Next app:** [05 — Habit Tracker](../05-habit-tracker/README.md)
