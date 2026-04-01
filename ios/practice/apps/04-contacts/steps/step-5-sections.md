# Step 5: Alphabetical Sections

**Read first:** [README — Module 6: Navigation & View Controllers](../../../../README.md#module-6-navigation--view-controllers) and [swiftui-troubleshooting.md — List Issues](../../../../lessons/swiftui-troubleshooting.md#list-issues)

**Difficulty:** ★★☆ Intermediate

---

## Goal

Contacts are grouped alphabetically by last name into sections with letter headers (A, B, C...).

## When you're done

- [ ] Contacts are grouped by the first letter of their last name
- [ ] Each group appears as a `Section` in the List with a letter header
- [ ] Sections are sorted alphabetically (A before B, etc.)
- [ ] Contacts within each section are sorted by last name
- [ ] Swipe-to-delete still works within sections
- [ ] The section index (scroll-to-letter sidebar) appears on the right edge
- [ ] The app compiles and the `#Preview` works

## Files to edit

- `Views/ContentView.swift`

## Hints

<details>
<summary>Hint 1 — grouping contacts</summary>
Create a computed property: group contacts by the first letter of <code>lastName</code> using <code>Dictionary(grouping: contacts) { String($0.lastName.prefix(1)) }</code>. Sort the dictionary keys to get alphabetical section order. Return the sorted keys and their associated contacts.
</details>

<details>
<summary>Hint 2 — Section in List</summary>
Iterate over your sorted section keys: <code>ForEach(sectionKeys, id: \.self) { letter in Section(header: Text(letter)) { ForEach(contactsForLetter) { contact in ... } } }</code>. Keep <code>.onDelete</code> on the inner ForEach — you'll need to translate the IndexSet back to the correct contacts in the flat array for deletion.
</details>

---

## LLM Review

Copy your `ContentView.swift` and this block into an LLM. Ask it to review without showing corrected code — pass/fail per item with directional hints only.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

SECTIONS
- Contacts are grouped by the first letter of the last name
- Each group is a Section in the List
- Section headers show the letter
- Sections are in alphabetical order
- Contacts within each section are sorted

BEHAVIOR
- All contacts from the samples appear (none lost in grouping)
- Swipe-to-delete still works within sections
- Deleting a contact removes it from the correct section
- NavigationLink to detail view still works

GROUPING LOGIC
- Dictionary(grouping:by:) or similar is used (not hardcoded sections)
- The grouping is based on a computed/derived property (first letter)
- The sorted keys are derived from the data (not a hardcoded A-Z array)

QUALITY
- No force-unwrapping
- Empty sections don't appear (if all contacts in a letter are deleted)
- #Preview compiles
```
