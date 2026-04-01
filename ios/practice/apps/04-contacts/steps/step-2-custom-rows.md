# Step 2: Custom Contact Rows

**Read first:** [README — Module 2 § 2.3 SwiftUI View Lifecycle](../../../../README.md#23-swiftui-view-lifecycle) (view composition and reuse) and [swiftui-troubleshooting.md — List Issues](../../../../lessons/swiftui-troubleshooting.md#list-issues)

**Difficulty:** ★★☆ Intermediate

---

## Goal

Each contact row shows a colored initials circle, the full name, and a subtitle (company or phone). Extract the row into its own view.

## When you're done

- [ ] A new file `Views/ContactRow.swift` contains a `ContactRow` view
- [ ] ContactRow takes a `Contact` as input
- [ ] Each row shows a circle with the contact's initials in white text on their `initialsColor` background
- [ ] The initials circle has a fixed size (e.g. 40×40)
- [ ] Next to the circle, the full name is shown in a prominent font
- [ ] Below the name, a subtitle shows the company (if present) or phone (if present), in secondary style
- [ ] ContentView uses `ContactRow(contact:)` inside the ForEach
- [ ] The app compiles and the `#Preview` works

## Files to create/edit

- **Create** `Views/ContactRow.swift`
- **Edit** `Views/ContentView.swift`

## Hints

<details>
<summary>Hint 1 — initials circle</summary>
Use <code>Text(contact.initials).font(.headline).foregroundStyle(.white).frame(width: 40, height: 40).background(contact.initialsColor).clipShape(Circle())</code>. The <code>Contact</code> model already provides <code>initials</code> and <code>initialsColor</code>.
</details>

<details>
<summary>Hint 2 — subtitle with optional fallback</summary>
For the subtitle, try <code>contact.company ?? contact.phone ?? ""</code>. Only show the subtitle Text if it's non-empty. Arrange the name and subtitle in a <code>VStack(alignment: .leading, spacing: 2)</code> next to the initials circle in an <code>HStack</code>.
</details>

---

## LLM Review

Copy your `ContactRow.swift` and `ContentView.swift` plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

ROW COMPONENT
- ContactRow is a separate View struct in its own file
- It accepts a Contact parameter
- The row is used inside ForEach in ContentView

INITIALS CIRCLE
- A circle shows the contact's initials (using contact.initials)
- The circle background uses contact.initialsColor
- Initials text is white
- The circle has a fixed frame size
- .clipShape(Circle()) is applied

TEXT CONTENT
- Full name is shown in a prominent font (headline, body, or similar)
- A subtitle shows company or phone (with fallback)
- Subtitle uses a secondary/muted style
- Name and subtitle are in a VStack with leading alignment

LAYOUT
- The circle and text content are in an HStack
- Spacing between circle and text is appropriate

QUALITY
- No force-unwrapping of optional properties (phone, company)
- Subtitle gracefully handles nil values
- #Preview compiles for both ContactRow and ContentView
```
