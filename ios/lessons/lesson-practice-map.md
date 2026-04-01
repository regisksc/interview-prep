# Lessons ↔ practice map

Practice is organized as **8 progressive apps** — you start from a pre-built starter and evolve it step-by-step. Difficulty increases across apps. Each step links to the lesson section you should read first.

Apps are in [`practice/apps/`](../practice/apps/README.md). Work in a local Xcode project (e.g. in `swift-drills/`, which is git-ignored).

---

## All apps at a glance

| # | App | Difficulty | Lesson files | Steps |
|--:|-----|-----------|-------------|------:|
| 01 | [Mood Tracker](../practice/apps/01-mood-tracker/README.md) | ★☆☆ | [swiftui-state.md](swiftui-state.md) | 7 |
| 02 | [Recipe Book](../practice/apps/02-recipe-book/README.md) | ★☆☆ | [swiftui-advanced.md](swiftui-advanced.md) (layout, modifiers) | 7 |
| 03 | [Weather Cards](../practice/apps/03-weather-cards/README.md) | ★★☆ | [swiftui-advanced.md](swiftui-advanced.md) (animation) | 6 |
| 04 | [Contacts](../practice/apps/04-contacts/README.md) | ★★☆ | Module 6, [troubleshooting](swiftui-troubleshooting.md) | 7 |
| 05 | [Habit Tracker](../practice/apps/05-habit-tracker/README.md) | ★★☆ | [state-management-comparison](state-management-comparison.md), [combine](combine-framework.md) | 6 |
| 06 | [News Reader](../practice/apps/06-news-reader/README.md) | ★★★ | [combine](combine-framework.md), Module 5, 7 | 7 |
| 07 | [Expense Tracker](../practice/apps/07-expense-tracker/README.md) | ★★★ | [swiftui-advanced.md](swiftui-advanced.md), Module 7, 9 | 6 |
| 08 | [Mini Social](../practice/apps/08-mini-social/README.md) | ★★★ | Module 4, 5, 8 | 6 |

**Total: 52 steps across 8 apps.**

---

## Lesson file → app mapping

| Lesson | Primary app(s) | Also useful for |
|--------|---------------|-----------------|
| [swiftui-state.md](swiftui-state.md) | **01 Mood Tracker** (all 7 steps) | 05 Habit Tracker (step 1) |
| [swiftui-advanced.md](swiftui-advanced.md) | **02 Recipe Book** (layout/modifiers), **03 Weather Cards** (animation) | 04, 06, 07 |
| [state-management-comparison.md](state-management-comparison.md) | **05 Habit Tracker** (step 1) | Interview prep |
| [combine-framework.md](combine-framework.md) | **05 Habit Tracker** (step 5), **06 News Reader** (step 2) | — |
| [swiftui-troubleshooting.md](swiftui-troubleshooting.md) | **04 Contacts** (list issues) | Reference for any app |
| [swiftui-interview-questions.md](swiftui-interview-questions.md) | Post-completion review | — |

---

## Course modules → apps

| Module | Apps |
|--------|------|
| 1 Swift fundamentals | Prerequisite knowledge |
| 2 UIKit & SwiftUI lifecycle | 01, 02 |
| 3 State & data flow | **01 Mood Tracker**, 05 Habit Tracker |
| 4 Architecture | **08 Mini Social** |
| 5 Concurrency | **06 News Reader**, 08 Mini Social |
| 6 Navigation | **04 Contacts** |
| 7 Performance | **06 News Reader** (step 5), **07 Expense Tracker** |
| 8 Testing | **06 News Reader** (step 6), **08 Mini Social** (step 6) |
| 9 Native features | **07 Expense Tracker** (SwiftData, Charts) |

---

## Quick-reference drills

The [drills/swiftui/](../practice/drills/swiftui/README.md) files still exist for targeted standalone reps.
