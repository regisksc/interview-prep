# Step 3: Daily Progress Ring

**Read first:** [swiftui-advanced.md — Custom Layout](../../../../lessons/swiftui-advanced.md#custom-layout) (see also: Canvas drawing and Shape)

**Difficulty:** ★★☆ Intermediate

---

## Goal

Build a circular progress view that shows what fraction of today's habits are complete. Display it prominently at the top of the habit list.

## When you're done

- [ ] A circular ring fills proportionally to (completed today / total habits)
- [ ] The ring animates when the fill ratio changes
- [ ] The percentage or fraction is displayed in the center of the ring
- [ ] An empty state shows 0% gracefully (not a broken ring)
- [ ] The ring updates immediately when a habit is toggled

## Files to edit

- **Create** `Views/ProgressRing.swift`
- **Edit** main list view to include the ring

## Hints

<details>
<summary>Hint — drawing the ring</summary>
Use a <code>Circle().trim(from:to:)</code> with <code>.stroke</code> for the track and the fill. Animate changes to the <code>to:</code> parameter with <code>.animation</code>.
</details>

---

## LLM Review

Copy your `ProgressRing.swift` and the view that hosts it, plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

DRAWING
- The ring uses Shape (Circle, Arc, or Path) — not just an Image
- A background track ring is visible at all times
- A foreground fill ring represents the completion ratio
- The stroke uses .lineCap(.round) or similar for polished ends

ANIMATION
- The fill ring animates when the ratio changes
- The animation uses .animation or withAnimation (not instant snap)

DATA
- The ratio is derived from store data (completed count / total count)
- Division by zero is handled (0 habits → 0% or empty state)
- The center label shows the current percentage or fraction

QUALITY
- ProgressRing accepts its ratio as a parameter (reusable, not coupled to store)
- No hardcoded habit count
- The ring looks correct at 0%, partial, and 100%
```
