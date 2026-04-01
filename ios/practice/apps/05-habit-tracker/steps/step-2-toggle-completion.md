# Step 2: Toggle Today's Completion

**Read first:** [swiftui-advanced.md — Advanced Animations](../../../../lessons/swiftui-advanced.md#advanced-animations)

**Difficulty:** ★★☆ Intermediate

---

## Goal

Each habit row has a tappable checkmark that toggles completion for today. The toggle animates smoothly.

## When you're done

- [ ] Each habit row shows a circle (incomplete) or filled checkmark (complete) for today
- [ ] Tapping the indicator toggles today's date in the habit's completion set
- [ ] The toggle animates (scale, opacity, or symbol effect)
- [ ] The completion state persists across tab switches
- [ ] Multiple habits can be toggled independently

## Files to edit

- `Views/HabitRow.swift` (create)
- `Models/HabitStore.swift`

## Hints

<details>
<summary>Hint — animating the toggle</summary>
Wrap the state mutation in <code>withAnimation</code>. Use <code>.symbolEffect</code> (iOS 17) or a <code>.transition</code> between the two states of the checkmark.
</details>

---

## LLM Review

Copy your `HabitRow.swift` and `HabitStore.swift` plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

TOGGLE LOGIC
- HabitStore has a method that toggles a specific date for a specific habit
- The method adds the date if absent, removes it if present
- Today's date is normalized to year/month/day components (no time)

ANIMATION
- The toggle triggers an animation (withAnimation, .symbolEffect, or transition)
- The visual state clearly distinguishes complete vs incomplete
- The animation is not instant — there is a visible transition

VIEW STRUCTURE
- HabitRow is a separate view (not inlined in the list)
- The row displays habit icon, name, and toggle indicator
- Tapping the indicator area triggers the toggle (not the entire row)

QUALITY
- No force-unwrapping
- Date comparison uses calendar components, not raw Date equality
- The animation does not cause layout jumps
```
