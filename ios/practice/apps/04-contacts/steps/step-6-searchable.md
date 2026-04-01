# Step 6: Search with .searchable

**Read first:** [README — Module 6: Navigation & View Controllers](../../../../README.md#module-6-navigation--view-controllers) and [swiftui-troubleshooting.md — List Issues](../../../../lessons/swiftui-troubleshooting.md#list-issues)

**Difficulty:** ★★☆ Intermediate

---

## Goal

A search bar appears at the top of the contact list. Typing filters contacts in real time by name, company, or email.

## When you're done

- [ ] A search bar appears in the navigation bar (via `.searchable`)
- [ ] A `@State` property stores the search text
- [ ] Typing in the search bar filters the displayed contacts in real time
- [ ] Search matches against first name, last name, company, and email (case-insensitive)
- [ ] Clearing the search text shows all contacts again
- [ ] Sections still work correctly with filtered results
- [ ] Empty sections are hidden when no contacts match in that letter group
- [ ] The app compiles and the `#Preview` works

## Files to edit

- `Views/ContentView.swift`

## Hints

<details>
<summary>Hint 1 — .searchable modifier</summary>
Add <code>@State private var searchText = ""</code>. Apply <code>.searchable(text: $searchText, prompt: "Search contacts")</code> to the <code>List</code> or <code>NavigationStack</code>. SwiftUI provides the search bar UI automatically.
</details>

<details>
<summary>Hint 2 — filtering logic</summary>
Create a computed property that filters contacts: if <code>searchText.isEmpty</code>, return all contacts; otherwise filter where <code>contact.fullName.localizedCaseInsensitiveContains(searchText)</code> or similar checks on company/email. Feed the filtered array into your section-grouping logic from Step 5.
</details>

---

## LLM Review

Copy your `ContentView.swift` and this block into an LLM. Ask it to review without showing corrected code — pass/fail per item with directional hints only.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

SEARCHABLE
- .searchable modifier is applied (not a custom TextField)
- A @State property stores the search text
- The modifier uses text: binding to the search state
- A placeholder/prompt is provided

FILTERING
- A computed property filters contacts based on searchText
- Search matches against name (first or last)
- Search also matches company and/or email
- Matching is case-insensitive (localizedCaseInsensitiveContains or lowercased comparison)
- Empty searchText returns all contacts

INTEGRATION
- Filtered contacts feed into the section grouping logic
- Sections update correctly as search text changes
- Empty sections are hidden (no section header for letters with 0 matches)
- Swipe-to-delete and navigation still work with filtered results

QUALITY
- No force-unwrapping of optional properties during search
- Filtering handles nil optionals gracefully (nil company doesn't crash)
- #Preview compiles
```
