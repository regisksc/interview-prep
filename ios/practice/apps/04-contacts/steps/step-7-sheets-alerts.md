# Step 7: Sheets, Alerts, and Pull to Refresh

**Read first:** [README — Module 6: Navigation & View Controllers](../../../../README.md#module-6-navigation--view-controllers) and [swiftui-troubleshooting.md — State Issues](../../../../lessons/swiftui-troubleshooting.md#state-issues)

**Difficulty:** ★★☆ Intermediate

---

## Goal

Add an "Add Contact" sheet for creating new contacts, a delete confirmation alert, and pull-to-refresh that simulates reloading contacts.

## When you're done

- [ ] A "+" button in the toolbar opens a sheet for adding a new contact
- [ ] The sheet has text fields for first name, last name, phone, email, and company
- [ ] A "Save" button in the sheet creates a new `Contact` and adds it to the array
- [ ] A "Cancel" button dismisses the sheet without saving
- [ ] Save is disabled when first name or last name is empty
- [ ] Swipe-to-delete now shows a confirmation alert before actually deleting
- [ ] The alert says which contact will be deleted and has "Delete" (destructive) and "Cancel" buttons
- [ ] Pull-to-refresh on the list triggers a simulated reload (e.g. 1-second delay, then restore original data)
- [ ] The app compiles and the `#Preview` works

## Files to create/edit

- **Create** `Views/AddContactSheet.swift`
- **Edit** `Views/ContentView.swift`

## Hints

<details>
<summary>Hint 1 — sheet presentation</summary>
Add <code>@State private var showingAddSheet = false</code>. In the toolbar, add a <code>Button(action: { showingAddSheet = true }) { Image(systemName: "plus") }</code>. Apply <code>.sheet(isPresented: $showingAddSheet) { AddContactSheet(onSave: { contact in contacts.append(contact) }) }</code> to the List.
</details>

<details>
<summary>Hint 2 — delete confirmation alert</summary>
Instead of deleting immediately in <code>.onDelete</code>, store the contact to delete: <code>@State private var contactToDelete: Contact?</code>. In the delete handler, set <code>contactToDelete</code> and show an alert: <code>.alert("Delete Contact?", isPresented: .init(get: { contactToDelete != nil }, set: { if !$0 { contactToDelete = nil } }))</code>. In the alert's destructive button action, actually remove the contact.
</details>

---

## LLM Review

Copy your `AddContactSheet.swift` and `ContentView.swift` plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

ADD SHEET
- A sheet is presented via .sheet(isPresented:) or .sheet(item:)
- The sheet contains text fields for first name, last name, phone, email, company
- A Save button creates a Contact and passes it back to ContentView
- A Cancel button dismisses without saving
- Save is disabled when required fields (firstName, lastName) are empty
- The sheet uses @Environment(\.dismiss) or a binding to close itself

ALERT
- Swipe-to-delete triggers a confirmation alert (not immediate deletion)
- The alert identifies which contact will be deleted
- The alert has a destructive "Delete" action and a "Cancel" action
- Confirming delete actually removes the contact from the array
- Canceling returns to the list without changes

PULL TO REFRESH
- .refreshable modifier is applied to the List
- The refresh action has an async delay (simulating network)
- The list updates after the refresh completes

BEHAVIOR
- New contacts appear in the correct alphabetical section
- Search still works with newly added contacts
- All previous features (sections, search, navigation, edit mode) still function

QUALITY
- No force-unwrapping
- @Environment(\.dismiss) is used (not presentationMode for modern SwiftUI)
- #Preview compiles for both AddContactSheet and ContentView
```
