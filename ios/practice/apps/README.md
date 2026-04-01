# Practice Apps

Eight **progressive apps** — start from a pre-built starter, evolve it step-by-step. Each step maps to a lesson section and adds one concept. Difficulty increases across apps: early apps hold your hand, later apps give you requirements and let you figure it out.

---

## 10-Hour Cram Path

Interview tomorrow? **[CRAM-PLAN.md](../../CRAM-PLAN.md)** cuts the 8-app curriculum down to 3 apps and 10 hours:

| Hours | App | What you learn |
|-------|-----|---------------|
| 1–3 | [01 Mood Tracker](01-mood-tracker/README.md) (Steps 1–6) | Every property wrapper: @State, @Binding, @StateObject, @ObservedObject, @EnvironmentObject |
| 4–5 | [04 Contacts](04-contacts/README.md) (Steps 1–4, 6) | Lists, custom rows, navigation, searchable |
| 6–8 | [06 News Reader](06-news-reader/README.md) (Steps 1–3) | URLSession async/await, Combine debounce search, error state modeling |
| 9–10 | [Interview questions](../../lessons/swiftui-interview-questions.md) | Verbal practice with top-asked questions |

---

## Workflow

1. **Read** the lesson section linked in the step.
2. **Open** your Xcode project (created once from the starter).
3. **Implement** the step requirements.
4. **Review** — copy your code + the LLM Review block into any LLM. It checks a rubric and gives directional hints, not the answer.
5. **Next step** — each builds on your previous work.

---

## Apps (easiest → hardest)

| # | App | Difficulty | Concepts | Lesson coverage | Steps |
|--:|-----|-----------|----------|----------------|------:|
| [01](01-mood-tracker/README.md) | **Mood Tracker** | ★☆☆ Beginner | State wrappers | [swiftui-state.md](../../lessons/swiftui-state.md) | 7 |
| [02](02-recipe-book/README.md) | **Recipe Book** | ★☆☆ Beginner | Layout + modifiers | [swiftui-advanced.md](../../lessons/swiftui-advanced.md) (layout, modifiers) | 7 |
| [03](03-weather-cards/README.md) | **Weather Cards** | ★★☆ Intermediate | Animation + gestures | [swiftui-advanced.md](../../lessons/swiftui-advanced.md) (animation) | 6 |
| [04](04-contacts/README.md) | **Contacts** | ★★☆ Intermediate | Lists + navigation | Module 6, [troubleshooting](../../lessons/swiftui-troubleshooting.md) | 7 |
| [05](05-habit-tracker/README.md) | **Habit Tracker** | ★★☆ Intermediate | @Observable, Combine | [state-management-comparison](../../lessons/state-management-comparison.md), [combine](../../lessons/combine-framework.md) | 6 |
| [06](06-news-reader/README.md) | **News Reader** | ★★★ Advanced | Async, networking, errors | [combine](../../lessons/combine-framework.md), Module 5, 7 | 7 |
| [07](07-expense-tracker/README.md) | **Expense Tracker** | ★★★ Advanced | Charts, SwiftData, UIKit | [swiftui-advanced.md](../../lessons/swiftui-advanced.md), Module 7, 9 | 6 |
| [08](08-mini-social/README.md) | **Mini Social** | ★★★ Advanced | Architecture, testing | Module 4, 5, 8 | 6 |

---

## Difficulty progression

| Level | Apps | Hints per step | What's given |
|-------|------|---------------|--------------|
| ★☆☆ Beginner | 01, 02 | 3 progressive hints | Explicit lesson links, detailed acceptance criteria, code-level nudges |
| ★★☆ Intermediate | 03, 04, 05 | 1–2 hints | Lesson links, moderate criteria, concept-level nudges |
| ★★★ Advanced | 06, 07, 08 | 0–1 hints | Lesson links, requirements only, figure out the implementation |

---

## Where to work

Copy each app's `starter/` folder into a **local** Xcode project — the [`swift-drills/`](../../../swift-drills/) directory (git-ignored) is a good place.

```bash
cp -r ios/practice/apps/01-mood-tracker/starter/ swift-drills/mood-tracker/
```

Each app has an `Assets.xcassets/` folder with an app icon. Drag it into your Xcode project.

---

## Mockups

Every app folder contains a `mockup.png` showing what the finished app looks like. Open it before you start to understand the target.

---

## How the LLM review works

Every step ends with a fenced **LLM Review** block — a behavioral checklist. Paste your source files + the block into any LLM and ask it to review without showing corrected code. Early apps get more detailed rubrics; advanced apps keep them concise.
