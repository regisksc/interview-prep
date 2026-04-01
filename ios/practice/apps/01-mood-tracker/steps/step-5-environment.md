# Step 5: Shared User Session

**Read first:** [swiftui-state.md — @EnvironmentObject](../../../../lessons/swiftui-state.md#environmentobject--shared-across-hierarchy)

**Difficulty:** 🟡 Intermediate | **Time:** ~20 min

> **Key interview concept — `@EnvironmentObject`:**
> *"What is `@EnvironmentObject` and how does it differ from `@ObservedObject`?"*
> **Answer:** `@EnvironmentObject` reads an `ObservableObject` from the SwiftUI **environment** — it flows implicitly through the entire view hierarchy. You don't pass it through init parameters. The parent injects it with `.environmentObject()`, and any descendant can read it. If you forget to inject it, the app **crashes at runtime** (not a compile error).

---

## Goal

A `UserSession` object tracks whether a mood has been logged today. It's injected at the app level and accessible from any view — **without** passing it through init parameters.

## Files

- **Create** `Models/UserSession.swift`
- **Edit** `MoodTrackerApp.swift`
- **Edit** `Views/TodayTab.swift`
- **Edit** `Views/HistoryTab.swift`

---

## Micro-steps

### Create the UserSession model

1. In the `Models` folder, create a new Swift file: `UserSession.swift`.
2. Add this code:
   ```swift
   import Foundation

   class UserSession: ObservableObject {
       @Published var hasLoggedToday: Bool = false
       @Published var lastLogDate: Date? = nil

       func markLogged() {
           hasLoggedToday = true
           lastLogDate = .now
       }

       func isToday(_ date: Date) -> Bool {
           Calendar.current.isDateInToday(date)
       }
   }
   ```
3. **Build** (Cmd+B). Should compile. This is a simple `ObservableObject` with two published properties and a helper method.

### Inject UserSession at the app level

4. Open `MoodTrackerApp.swift`. Add this property to the struct:
   ```swift
   @StateObject private var session = UserSession()
   ```
5. Find the root view (probably `ContentView()`). Add the `.environmentObject()` modifier:
   ```swift
   ContentView()
       .environmentObject(session)
   ```
6. **Build** (Cmd+B). Should compile. Now `session` is available to **every view** inside ContentView — without passing it as a parameter.

### Read UserSession in TodayTab

7. Open `Views/TodayTab.swift`. Add this property:
   ```swift
   @EnvironmentObject var session: UserSession
   ```
   Note: **no** `private`, **no** default value, **no** initialization. It comes from the environment.
8. **Build** (Cmd+B). The TodayTab `#Preview` will crash. Fix it by injecting a session:
   ```swift
   #Preview {
       TodayTab(viewModel: MoodViewModel())
           .environmentObject(UserSession())
   }
   ```
9. **Build** (Cmd+B). Should compile now.

### Show "already logged" message in TodayTab

10. In TodayTab's `body`, above the `MoodPickerView`, add a conditional:
    ```swift
    if session.hasLoggedToday {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text("Already logged today — log again?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 4)
    }
    ```
11. **Run in preview.** You won't see the message yet (nothing logged). That's correct.

### Update the Log Mood action to mark the session

12. Find the "Log Mood" button action. **After** the line `viewModel.addEntry(...)`, add:
    ```swift
    session.markLogged()
    ```
13. **Build and Run** (Cmd+R). Log a mood → the "Already logged today" message should appear above the mood picker.

### Read UserSession in HistoryTab

14. Open `Views/HistoryTab.swift`. Add:
    ```swift
    @EnvironmentObject var session: UserSession
    ```
15. Update the HistoryTab `#Preview`:
    ```swift
    #Preview {
        HistoryTab(viewModel: MoodViewModel())
            .environmentObject(UserSession())
    }
    ```
16. **Build** (Cmd+B). Should compile.

### Highlight today's entries in HistoryTab

17. In the HistoryTab `ForEach`, add a visual indicator for today's entries. After the `VStack` containing mood label/note/date, add:
    ```swift
    Spacer()
    if session.isToday(entry.date) {
        Image(systemName: "star.fill")
            .foregroundStyle(.yellow)
            .font(.caption)
    }
    ```
18. **Build and Run** (Cmd+R). Full verification:
    - [ ] Log a mood in Today tab → "Already logged today" message appears
    - [ ] Switch to History tab → the entry you just logged has a yellow star
    - [ ] The star only appears on entries from today, not older ones
    - [ ] ContentView does **NOT** pass `UserSession` as an init parameter — it flows through the environment

### Verify environment injection is required (important!)

19. Temporarily **comment out** the `.environmentObject(session)` line in `MoodTrackerApp.swift`.
20. **Build and Run** (Cmd+R). Navigate to the Today tab → the app **crashes** with a fatal error about a missing environment object. This is expected!
21. **Uncomment** the line and build again. This proves that `@EnvironmentObject` requires injection — it's a runtime contract, not compile-time.

---

## Architecture check

You now have two `ObservableObject` classes with **different concerns**:
- **`MoodViewModel`** — manages the list of mood entries (data CRUD)
- **`UserSession`** — tracks session-level state (has the user logged today?)

They're injected differently:
- `MoodViewModel` is passed via **init parameters** (`@ObservedObject`)
- `UserSession` is passed via **environment** (`@EnvironmentObject`)

Both patterns are valid. Environment is better for data that many distant views need. Init parameters are better for data that flows to specific children. In an interview, showing you understand both approaches (and their tradeoffs) is strong.

---

## Hints (if you get stuck)

<details>
<summary>Hint — "No ObservableObject of type UserSession found"</summary>
You forgot to add <code>.environmentObject(session)</code> in MoodTrackerApp. Every view that uses <code>@EnvironmentObject</code> must have an ancestor that injects it.
</details>

<details>
<summary>Hint — Preview crashes</summary>
Previews don't inherit the app's environment. You must add <code>.environmentObject(UserSession())</code> to every preview that uses a view reading <code>@EnvironmentObject</code>.
</details>

---

## 🎯 Interview takeaway

You just used `@EnvironmentObject` — SwiftUI's way to share data **implicitly** across the view hierarchy.

- Injected once with `.environmentObject()`, readable anywhere below with `@EnvironmentObject`.
- No init parameter needed — great for app-wide data (auth state, theme, session).
- **Runtime crash** if you forget to inject — this is the #1 pitfall interviewers test.
- For previews, you must manually inject the environment object.
- Common interview question: *"When would you use @EnvironmentObject vs just passing an @ObservedObject through init?"* — Use environment for data needed by many views at different levels. Use init parameters when data flows to specific, known children (more explicit, easier to trace).

---

## LLM Review

Copy `UserSession.swift`, `MoodTrackerApp.swift`, `TodayTab.swift`, `HistoryTab.swift` plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

ENVIRONMENT OBJECT
- UserSession is a class conforming to ObservableObject
- hasLoggedToday and lastLogDate are @Published
- MoodTrackerApp creates UserSession with the OWNING lifecycle wrapper
- MoodTrackerApp injects it using .environmentObject()
- TodayTab and HistoryTab read it with the ENVIRONMENT wrapper
- No view passes UserSession as an init parameter

BEHAVIOR
- After logging a mood, hasLoggedToday becomes true and lastLogDate updates
- TodayTab shows different UI when hasLoggedToday is true
- HistoryTab can distinguish today's entries (using lastLogDate or Calendar)

ARCHITECTURE
- UserSession is a SEPARATE class from MoodViewModel (different concerns)
- MoodViewModel uses parameter-based injection (@ObservedObject)
- UserSession uses environment-based injection (@EnvironmentObject)
- The separation of concerns between the two classes is clear

QUALITY
- The environment wrapper property has no default value
- #Preview for TodayTab and HistoryTab inject a UserSession via .environmentObject()
- No regressions — all Step 1–4 features still work
```
