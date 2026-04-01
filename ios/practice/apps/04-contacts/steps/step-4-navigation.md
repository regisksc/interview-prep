# Step 4: Navigation to Detail View

**Read first:** [README — Module 6 § 6.2 SwiftUI Navigation](../../../../README.md#62-swiftui-navigation)

**Difficulty:** ★★☆ Intermediate

---

## Goal

Tapping a contact row navigates to a detail view showing all the contact's information. Uses NavigationStack + NavigationLink.

## When you're done

- [ ] Tapping a contact row pushes a detail view onto the navigation stack
- [ ] A new `Views/ContactDetailView.swift` shows all contact properties (name, phone, email, company)
- [ ] Optional properties (phone, email, company) only display when non-nil
- [ ] A back button in the navigation bar returns to the list
- [ ] The detail view shows the contact's initials circle prominently at the top
- [ ] The detail view has the contact's full name as the navigation title
- [ ] The app compiles and the `#Preview` works for both views

## Files to create/edit

- **Create** `Views/ContactDetailView.swift`
- **Edit** `Views/ContentView.swift`

## Hints

<details>
<summary>Hint 1 — NavigationLink wrapping each row</summary>
Wrap <code>ContactRow(contact: contact)</code> in <code>NavigationLink { ContactDetailView(contact: contact) } label: { ContactRow(contact: contact) }</code>. The <code>NavigationStack</code> from Step 1 handles the push/pop. Alternatively, use the value-based <code>NavigationLink(value: contact)</code> with <code>.navigationDestination(for:)</code>.
</details>

<details>
<summary>Hint 2 — detail view layout</summary>
In <code>ContactDetailView</code>, use a VStack or List with sections. Show the large initials circle at the top, then rows for phone, email, and company. Use <code>if let</code> to conditionally show optional fields. Apply <code>.navigationTitle(contact.fullName)</code> and <code>.navigationBarTitleDisplayMode(.inline)</code>.
</details>

---

## LLM Review

Copy your `ContactDetailView.swift` and `ContentView.swift` plus this block.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

NAVIGATION
- NavigationLink wraps each contact row in the list
- Tapping a row navigates to ContactDetailView
- ContactDetailView receives a Contact parameter
- A back button is automatically provided by NavigationStack

DETAIL VIEW
- The detail view shows the contact's full name
- Phone is displayed only when non-nil
- Email is displayed only when non-nil
- Company is displayed only when non-nil
- The initials circle is shown prominently (larger than in the row)
- .navigationTitle uses the contact's name

BEHAVIOR
- Navigation push animation occurs on tap
- Back button returns to the contact list
- Swipe-to-delete from Step 3 still works on the list

QUALITY
- Optional properties use if-let or similar safe unwrapping (no force-unwrap)
- ContactDetailView has its own #Preview
- ContactRow is still used in the list (not replaced by NavigationLink label)
- #Preview compiles for both views
```
