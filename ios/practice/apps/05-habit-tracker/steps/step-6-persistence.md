# Step 6: Persistence with @AppStorage + Codable

**Difficulty:** ★★☆ Intermediate

---

## Goal

Persist the habits array (with all completion records) to UserDefaults via `@AppStorage` and `Codable` encoding, so data survives app restarts.

## When you're done

- [ ] Habits and their completion dates survive a full app kill and relaunch
- [ ] Adding, removing, or toggling a habit persists automatically
- [ ] The store encodes its data to JSON via Codable
- [ ] `@AppStorage` (or a RawRepresentable wrapper) bridges the store to UserDefaults
- [ ] Launching with no saved data starts with an empty habit list (no crash)

## Files to edit

- **Edit** `Models/Habit.swift` (add Codable conformance)
- **Edit** `Models/HabitStore.swift` (add persistence logic)

## Hints

<details>
<summary>Hint — AppStorage with custom types</summary>
<code>@AppStorage</code> only supports primitive types natively. To store an array of Codable structs, make the array conform to <code>RawRepresentable</code> where <code>RawValue == String</code>, encoding/decoding with JSONEncoder/JSONDecoder. Alternatively, encode manually in a <code>didSet</code> observer and decode in <code>init</code>.
</details>

---

## LLM Review

Copy your updated `Habit.swift` and `HabitStore.swift` plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

CODABLE
- Habit conforms to Codable
- DateComponents (or the completion set) encodes/decodes correctly
- The encoder/decoder is JSONEncoder/JSONDecoder (not a custom format)

PERSISTENCE
- The habits array is written to UserDefaults whenever it changes
- On init, the store loads from UserDefaults (or defaults to empty)
- @AppStorage or a manual UserDefaults read/write cycle is used
- No data loss: toggling a completion and restarting preserves the toggle

ERROR HANDLING
- Decoding failure falls back to an empty array (no crash)
- Missing key on first launch returns empty data gracefully

QUALITY
- No redundant encoding (only writes when data actually changes, or at least only on mutation)
- The persistence key is a constant (not a magic string repeated in multiple places)
- The store still works correctly with @Observable from Step 1
```
