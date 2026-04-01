# Step 7: Adapt and Restore

**Read first:** [swiftui-state.md — @Environment](../../../../lessons/swiftui-state.md#environment--system-values) and [@SceneStorage](../../../../lessons/swiftui-state.md#scenestorage--scene-restoration)

**Difficulty:** 🟡 Intermediate | **Time:** ~20 min

> **Key interview concept — `@Environment` and `@SceneStorage`:**
> *"How does SwiftUI let you read system settings like dark mode?"*
> **Answer:** `@Environment(\.keyPath)` reads **system-provided values** — color scheme, size class, locale, accessibility settings, dismiss action, etc. It's read-only. `@SceneStorage` is like `@AppStorage` but scoped to the current **window/scene** — it restores UI state (selected tab, scroll position) when the scene is recreated, but is wiped on app uninstall.

---

## Goal

The app adapts to dark mode, uses semantic font sizes for Dynamic Type, and remembers which tab was selected using `@SceneStorage`.

## Files to edit

- **Edit** `Views/ContentView.swift` (tab persistence)
- **Edit** `Views/MoodPickerView.swift` (dark mode styling)

---

## Micro-steps

### Add tab persistence with @SceneStorage

1. Open `Views/ContentView.swift`.
2. Add this property at the top of the struct:
   ```swift
   @SceneStorage("selectedTab") private var selectedTab: String = "today"
   ```
3. **Build** (Cmd+B). Should compile. `@SceneStorage` stores the value per-scene — it survives app backgrounding and scene recreation.

### Wire the TabView to the stored selection

4. Find your `TabView`. Change it to use a `selection` binding:
   ```swift
   TabView(selection: $selectedTab) {
   ```
5. On each tab's content view, add a `.tag()` that matches the `selectedTab` type (String). For example:
   ```swift
   TodayTab(viewModel: viewModel)
       .tabItem {
           Label("Today", systemImage: "sun.max.fill")
       }
       .tag("today")

   HistoryTab(viewModel: viewModel)
       .tabItem {
           Label("History", systemImage: "clock.fill")
       }
       .tag("history")

   SettingsTab()
       .tabItem {
           Label("Settings", systemImage: "gear")
       }
       .tag("settings")
   ```
6. **Build and Run** (Cmd+R). Switch to the History tab. Background the app (Cmd+Shift+H). Reopen it → it should return to the History tab, not Today.

> **Why `.tag("history")` not `.tag(1)`?** The tag type must match the `selectedTab` type. Since `selectedTab` is a `String`, tags must also be `String`.

### Read the color scheme with @Environment

7. Open `Views/MoodPickerView.swift`. Add this property at the top of the struct:
   ```swift
   @Environment(\.colorScheme) private var colorScheme
   ```
8. **Build** (Cmd+B). Should compile. `colorScheme` will be either `.light` or `.dark`.

### Style mood buttons differently in dark mode

9. Find the `.background()` modifier on the mood buttons. Replace it with a conditional:
   ```swift
   .background(
       RoundedRectangle(cornerRadius: 12)
           .fill(selectedMood == mood
               ? (colorScheme == .dark ? Color.yellow.opacity(0.3) : Color.blue.opacity(0.2))
               : Color.clear)
   )
   ```
10. **Run in preview.** The default preview is light mode. To see dark mode, add a preview variant:
    ```swift
    #Preview("Dark Mode") {
        MoodPickerView(selectedMood: .constant(.good))
            .preferredColorScheme(.dark)
    }
    ```
11. **Build** (Cmd+B). Should compile. You should now see two previews — one light, one dark. In dark mode, the selected mood should have a yellow-ish tint instead of blue.

### Add a border or glow in dark mode (extra polish)

12. Below the `.background()` modifier, add an overlay for dark mode:
    ```swift
    .overlay(
        RoundedRectangle(cornerRadius: 12)
            .stroke(
                selectedMood == mood && colorScheme == .dark
                    ? Color.yellow.opacity(0.5)
                    : Color.clear,
                lineWidth: 2
            )
    )
    ```
13. **Run in preview** (dark mode variant). Selected mood should now have both a tinted background AND a subtle yellow border.

### Verify semantic font styles (Dynamic Type)

14. Search through all your view files. Replace any hardcoded font sizes with semantic styles:
    - Use `.title`, `.title2`, `.title3` for headings
    - Use `.body` for normal text
    - Use `.headline`, `.subheadline` for emphasis
    - Use `.caption`, `.caption2` for small text
    - The **one exception**: the large emoji in mood buttons can keep `.system(size: 48)` — emojis don't scale well with Dynamic Type
15. **Build** (Cmd+B). Should compile.
16. To test Dynamic Type in the simulator: Settings → Accessibility → Display & Text Size → Larger Text → slide to maximum. Your app's text should scale up and remain readable.

### Final full verification

17. **Build and Run** (Cmd+R). Run through the complete checklist:
    - [ ] **Tab persistence:** Switch to Settings tab → background app → reopen → still on Settings
    - [ ] **Dark mode:** Toggle appearance in simulator (Cmd+Shift+A or Settings → Developer → Dark Appearance). Mood buttons should look noticeably different.
    - [ ] **Dynamic Type:** Increase text size in Settings → Accessibility. Text scales; layout doesn't break.
    - [ ] **No regressions:** Log a mood → appears in History → stats update → settings persist → "already logged" message shows → swipe-to-delete works

---

## Architecture check

This step completes the "state wrapper tour." Notice the pattern:

| What you need | Wrapper | Scope |
|---|---|---|
| Local value-type state | `@State` | Single view |
| Two-way child connection | `@Binding` | Parent → child |
| Reference-type state (owner) | `@StateObject` | Creating view |
| Reference-type state (borrower) | `@ObservedObject` | Receiving view |
| UserDefaults persistence | `@AppStorage` | App-wide |
| Implicit shared state | `@EnvironmentObject` | View hierarchy |
| Derived data | Computed property | ViewModel |
| System-provided values | `@Environment` | Read-only |
| Scene UI restoration | `@SceneStorage` | Per window/scene |

This table is your interview cheat sheet. If you can explain when to use each one, you'll ace any SwiftUI state management question.

---

## Hints (if you get stuck)

<details>
<summary>Hint — tab persistence doesn't work</summary>
Check three things: (1) <code>TabView(selection: $selectedTab)</code> has the binding, (2) each tab has a <code>.tag()</code>, (3) the tag type matches the <code>@SceneStorage</code> type (all Strings, or all Ints — don't mix).
</details>

<details>
<summary>Hint — dark mode preview doesn't appear</summary>
Add <code>.preferredColorScheme(.dark)</code> to your preview. Each <code>#Preview</code> block is independent — you need to set the scheme explicitly.
</details>

---

## 🎯 Interview takeaway

You just completed every major SwiftUI property wrapper.

- **`@Environment(\.keyPath)`** reads system values (color scheme, locale, size class). Read-only. No injection needed — SwiftUI provides them automatically.
- **`@SceneStorage`** restores UI state per-scene. Survives backgrounding, wiped on uninstall. Use for tab selection, scroll position, draft text.
- **Dynamic Type** is a first-class citizen in SwiftUI. Use semantic font styles (`.title`, `.body`, `.caption`) and your app scales automatically.
- Common interview question: *"What's the difference between @AppStorage and @SceneStorage?"* — `@AppStorage` persists to UserDefaults (app-wide, survives uninstall of data). `@SceneStorage` is per-scene, for restoring UI state — it's lost when the app is uninstalled.
- Common interview question: *"Name five things you can read from @Environment."* — `colorScheme`, `dynamicTypeSize`, `locale`, `dismiss`, `horizontalSizeClass`, `verticalSizeClass`, `managedObjectContext`, `openURL`.

---

## You're done with Mood Tracker!

At this point the app covers every property wrapper from `swiftui-state.md`:

| Wrapper | Where you used it |
|---------|-------------------|
| `@State` | Step 1 — mood selection, Step 2 — note text |
| `@Binding` | Step 2 — MoodPickerView |
| `@StateObject` | Step 3 — ViewModel in ContentView |
| `@ObservedObject` | Step 3 — ViewModel in tabs |
| `@AppStorage` | Step 4 — name, default mood |
| `@EnvironmentObject` | Step 5 — UserSession |
| Computed properties | Step 6 — streak, stats |
| `@Environment` | Step 7 — color scheme |
| `@SceneStorage` | Step 7 — tab restoration |

---

## LLM Review

Copy `ContentView.swift` and any modified view files plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

ENVIRONMENT
- A view reads the system color scheme using @Environment
- The color scheme value is used to conditionally change appearance
- The visual difference between light and dark mode is noticeable

SCENE STORAGE
- A property stores the selected tab identifier
- The wrapper used is scene-scoped (not app-wide UserDefaults)
- TabView uses a selection binding tied to this property
- Each tab has a .tag() matching the selection type
- Tab selection persists across app relaunch

DYNAMIC TYPE
- Text uses semantic font styles (.title, .body, .caption, etc.)
- No hardcoded font sizes (no .font(.system(size: 18)) or similar)
- The UI looks reasonable at the largest accessibility text size

ARCHITECTURE
- All 9 property wrappers/patterns are correctly applied across the app
- Each wrapper is used for its intended purpose (no misuse)
- The data flow is unidirectional: source of truth → derived views

QUALITY
- The app compiles and all Steps 1–6 features still work
- No regressions — mood logging, history, settings, session, stats all intact
```

---

**Next app:** [02 — Recipe Book](../../02-recipe-book/README.md) (Layout + Modifiers)
