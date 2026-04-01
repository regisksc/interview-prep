# Step 4: Persist User Settings

**Read first:** [swiftui-state.md — @AppStorage](../../../../lessons/swiftui-state.md#appstorage--userdefaults-wrapper)

**Difficulty:** 🟢 Beginner | **Time:** ~15 min

> **Key interview concept — `@AppStorage`:**
> *"How does `@AppStorage` work and what are its limitations?"*
> **Answer:** `@AppStorage` is a property wrapper that reads from and writes to `UserDefaults` automatically. When the value changes, the view re-renders. It only supports **property-list types**: `String`, `Int`, `Double`, `Bool`, `Data`, `URL`. For enums, you store the `rawValue`. It's **not** for large or sensitive data — use Keychain for secrets, Core Data for complex models.

---

## Goal

The Settings tab lets the user set their name and a default mood. These survive app kill + relaunch. TodayTab uses the name for a greeting and the default mood as a fallback.

## Files to edit

- **Edit** `Views/SettingsTab.swift`
- **Edit** `Views/TodayTab.swift`

---

## Micro-steps

### Add @AppStorage properties to SettingsTab

1. Open `Views/SettingsTab.swift`.
2. At the top of the struct, add these two properties:
   ```swift
   @AppStorage("userName") private var userName: String = ""
   @AppStorage("defaultMood") private var defaultMoodRaw: String = Mood.okay.rawValue
   ```
3. **Build** (Cmd+B). Should compile. Key points:
   - `"userName"` and `"defaultMood"` are UserDefaults keys — just strings.
   - We store the mood as its `rawValue` (a `String`), not the enum directly, because `@AppStorage` only supports property-list types.

### Add a computed property for the mood enum

4. Below the `@AppStorage` properties, add a convenience computed property:
   ```swift
   private var defaultMood: Mood {
       get { Mood(rawValue: defaultMoodRaw) ?? .okay }
       set { defaultMoodRaw = newValue.rawValue }
   }
   ```
5. **Build** (Cmd+B). Should compile. This converts between the stored `String` and the `Mood` enum.

### Build the Settings UI

6. Replace the body of `SettingsTab` with:
   ```swift
   NavigationStack {
       Form {
           Section("Profile") {
               TextField("Your name", text: $userName)
           }

           Section("Defaults") {
               Picker("Default mood", selection: $defaultMoodRaw) {
                   ForEach(Mood.allCases) { mood in
                       Text("\(mood.emoji) \(mood.label)")
                           .tag(mood.rawValue)
                   }
               }
           }

           Section {
               Button("Reset to Defaults", role: .destructive) {
                   userName = ""
                   defaultMoodRaw = Mood.okay.rawValue
               }
           }
       }
       .navigationTitle("Settings")
   }
   ```
7. **Run in preview.** You should see:
   - A text field for the name
   - A picker showing all 5 moods
   - A red "Reset to Defaults" button
8. **Build and Run** (Cmd+R) on a simulator. Type a name, pick a mood, then **kill the app** (swipe up in the app switcher or Cmd+Shift+H twice and swipe). Relaunch — your name and mood selection should still be there.

> **Why `.tag(mood.rawValue)`?** The `Picker`'s `selection` is bound to `defaultMoodRaw` (a `String`). Each row's `.tag()` must match that type. Since we're storing `rawValue`, the tag must also be the `rawValue`.

### Read the settings in TodayTab

9. Open `Views/TodayTab.swift`. Add these `@AppStorage` properties (use the **exact same keys**):
   ```swift
   @AppStorage("userName") private var userName: String = ""
   @AppStorage("defaultMood") private var defaultMoodRaw: String = Mood.okay.rawValue
   ```
10. **Build** (Cmd+B). Should compile. Two views reading the same `@AppStorage` keys share the same UserDefaults values — they stay in sync automatically.

### Personalize the TodayTab greeting

11. Find the "How are you feeling?" text in your header. Replace it with:
    ```swift
    Text(userName.isEmpty ? "How are you feeling?" : "How are you feeling, \(userName)?")
        .font(.title2)
        .foregroundStyle(.secondary)
    ```
12. **Run in preview** or **Build and Run.** If you set a name in Settings, the Today tab should greet you by name.

### Use the default mood as fallback when logging

13. Find your "Log Mood" button action. Update the fallback to use the stored default mood:
    ```swift
    let fallbackMood = Mood(rawValue: defaultMoodRaw) ?? .okay
    let moodToLog = selectedMood ?? fallbackMood
    ```
14. **Build and Run** (Cmd+R). Full verification:
    - [ ] Go to Settings → type "Alex" → pick "Great" as default mood
    - [ ] Go to Today tab → greeting says "How are you feeling, Alex?"
    - [ ] Kill and relaunch the app → settings are preserved
    - [ ] Tap "Reset to Defaults" in Settings → name clears, mood goes back to Okay
    - [ ] The `#Preview` for SettingsTab compiles and works

---

## Architecture check

Notice that `@AppStorage` creates **implicit data sharing** — two views read the same UserDefaults key without passing data through parameters. This is convenient but can be fragile (typos in keys = silent bugs). In a larger app, you'd centralize key names in constants. For this small app, it's fine.

---

## Hints (if you get stuck)

<details>
<summary>Hint — Picker doesn't update the stored value</summary>
Make sure the Picker's <code>selection</code> binding matches the type of each row's <code>.tag()</code>. If selection is a <code>String</code>, the tag must also be a <code>String</code>.
</details>

<details>
<summary>Hint — value doesn't persist after kill</summary>
Make sure you're using <code>@AppStorage</code>, not <code>@State</code>. <code>@State</code> only survives re-renders, not app termination.
</details>

---

## 🎯 Interview takeaway

You just used `@AppStorage` — SwiftUI's built-in `UserDefaults` wrapper.

- `@AppStorage` reads/writes `UserDefaults` and triggers view updates.
- Only supports property-list types: `String`, `Int`, `Double`, `Bool`, `Data`, `URL`.
- For enums, store the `rawValue` (a String) and convert back.
- Two independent views can use the **same key** to share data without parameters.
- **Not** for sensitive data (use Keychain) or large datasets (use Core Data / SwiftData).
- Common interview question: *"What's the difference between @AppStorage and @SceneStorage?"* — `@AppStorage` is app-wide (UserDefaults), `@SceneStorage` is per-window/scene and used for UI state restoration (Step 7).

---

## LLM Review

Copy `SettingsTab.swift` and `TodayTab.swift` plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

PERSISTENCE
- Username uses a SwiftUI wrapper backed by UserDefaults
- Default mood uses the same kind of wrapper
- Both specify a string key for storage
- Values survive app relaunch (not just in-memory state)

SETTINGS UI
- TextField for name
- Picker (any style) for default mood showing all Mood cases
- Reset button clears both to defined defaults

CROSS-VIEW READING
- TodayTab reads the persisted name to personalize the greeting
- TodayTab reads the default mood as fallback when nothing is selected
- Both views use the SAME storage keys

ARCHITECTURE
- No new ObservableObject or class needed for this step
- AppStorage keys are consistent between SettingsTab and TodayTab
- Mood is stored as its rawValue (String), not the enum directly

QUALITY
- Reset writes default values to storage, not just clears local variables
- No force-unwrapping
- All #Previews still compile
```
