# Step 3: Swipe-to-Delete and EditButton

**Read first:** [swiftui-troubleshooting.md — List Issues § Swipe to delete not working](../../../../lessons/swiftui-troubleshooting.md#problem-swipe-to-delete-not-working)

**Difficulty:** ★★☆ Intermediate

---

## Goal

Contacts can be deleted by swiping a row left. An EditButton in the toolbar toggles edit mode for multi-row deletion.

## When you're done

- [ ] Swiping a contact row left reveals a red "Delete" action
- [ ] Completing the swipe removes the contact from the list
- [ ] An `EditButton` appears in the navigation bar toolbar
- [ ] Tapping EditButton toggles the list into edit mode (red circles appear)
- [ ] In edit mode, tapping the red circle and confirming deletes the contact
- [ ] The `@State` contacts array actually removes the deleted items (not just hiding them)
- [ ] The app compiles and the `#Preview` works

## Files to edit

- `Views/ContentView.swift`

## Hints

<details>
<summary>Hint 1 — .onDelete modifier</summary>
Add <code>.onDelete(perform: deleteContacts)</code> to the <code>ForEach</code> (not the <code>List</code>). Then implement: <code>func deleteContacts(at offsets: IndexSet) { contacts.remove(atOffsets: offsets) }</code>. The <code>.onDelete</code> modifier must be on ForEach, not List.
</details>

<details>
<summary>Hint 2 — EditButton in toolbar</summary>
Add <code>.toolbar { EditButton() }</code> to the <code>List</code> or <code>NavigationStack</code>. SwiftUI's built-in <code>EditButton</code> automatically toggles the list's edit mode. No custom <code>@State</code> needed for edit mode — it's managed by the environment.
</details>

---

## LLM Review

Copy your `ContentView.swift` and this block into an LLM. Ask it to review without showing corrected code — pass/fail per item with directional hints only.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

DELETE
- .onDelete is applied to ForEach (not List)
- The delete handler receives IndexSet and removes items from the contacts array
- contacts.remove(atOffsets:) or equivalent is used
- The @State contacts array is mutated (not a copy)

EDIT MODE
- EditButton() is in the toolbar
- EditButton toggles the list into/out of edit mode
- No custom @State var editMode is used (unless specifically needed)

BEHAVIOR
- Swiping a row left reveals the delete action
- Completing a swipe-to-delete removes the contact
- In edit mode, the red delete circles appear
- The list updates immediately when a contact is deleted

QUALITY
- The delete function is a named method (not a huge inline closure)
- ForEach still uses Identifiable (not index-based)
- #Preview compiles
```
