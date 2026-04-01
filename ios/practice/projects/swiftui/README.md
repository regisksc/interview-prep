# SwiftUI drill projects (isolated workspaces)

Each subfolder matches **one numbered drill** from [`../../drills/swiftui/README.md`](../../drills/swiftui/README.md) and [`../../../lessons/lesson-practice-map.md`](../../../lessons/lesson-practice-map.md).

## How to use

1. Open the folder for the drill you are on (e.g. `001-state-counter/`).
2. Create a **new Xcode project inside that folder** (iOS App, SwiftUI). Use a name like `Drill001StateCounter` so it stays obvious.
3. Implement the drill using the **starter Swift file** in `../drills/swiftui/` or the written spec in the drills README — do not mix multiple drills in one `.xcodeproj`.
4. Optional: add that folder to **local** git exclude if you use a personal ignore file; generated Xcode projects are often noisy in `git status`.

## Folders

| Folder | Drill | Starter file (if present) |
|--------|------:|---------------------------|
| `001-state-counter/` | 1 | `../drills/swiftui/001-state-counter.swift` |
| `002-binding-textfield/` | 2 | `002-binding-textfield.swift` |
| `003-stateobject-viewmodel/` | 3 | `003-stateobject-viewmodel.swift` |
| `004-appstorage-settings/` | 4 | `004-appstorage-settings.swift` |
| `005-environmentobject-app/` | 5 | `005-environmentobject-app.swift` |
| `006-derived-state/` … `010-alert-state/` | 6–10 | Spec only in drills README until starters are added |

Drills **11+**: create a new subfolder `011-…` when you start that drill, using the same naming pattern as the drills README.
