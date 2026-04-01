# Step 1: Replace VStack with List

**Read first:** [README — Module 6: Navigation & View Controllers](../../../../README.md#module-6-navigation--view-controllers) and [swiftui-troubleshooting.md — List Issues](../../../../lessons/swiftui-troubleshooting.md#list-issues)

**Difficulty:** ★★☆ Intermediate

---

## Goal

The contacts display in a proper SwiftUI `List` with `ForEach`, replacing any plain VStack/ScrollView approach. The Contact model is already `Identifiable`.

## When you're done

- [ ] A `ContentView.swift` exists in `Views/` with a `@State` array of contacts initialized from `Contact.samples`
- [ ] Contacts display in a `List` (not VStack or ScrollView)
- [ ] `ForEach` iterates the contacts array using `Identifiable` conformance (no manual `id:` parameter)
- [ ] Each row shows the contact's full name
- [ ] The list has a navigation title ("Contacts")
- [ ] The list is inside a `NavigationStack`
- [ ] The app compiles and the `#Preview` works

## Files to create/edit

- **Create** `Views/ContentView.swift`

## Hints

<details>
<summary>Hint 1 — List + ForEach pattern</summary>
Use <code>List { ForEach(contacts) { contact in Text(contact.fullName) } }</code>. Since <code>Contact</code> already conforms to <code>Identifiable</code>, you don't need <code>id: \.id</code>. Wrap the List in a <code>NavigationStack</code> and add <code>.navigationTitle("Contacts")</code>.
</details>

<details>
<summary>Hint 2 — mutable state for the array</summary>
Declare <code>@State private var contacts = Contact.samples</code>. Using <code>@State</code> with the array means later steps can add/remove contacts and the List will update. Don't use <code>let</code> — you'll need mutability for swipe-to-delete.
</details>

---

## LLM Review

Copy your `ContentView.swift` and this block into an LLM. Ask it to review without showing corrected code — pass/fail per item with directional hints only.

```
Review my SwiftUI code against this checklist.
Do NOT show corrected code — only pass/fail per item and a short hint for failures.

LIST
- A List is used (not VStack, ScrollView, or LazyVStack)
- ForEach is inside the List
- ForEach uses Contact's Identifiable conformance (no explicit id: parameter)
- Each row displays the contact's fullName

STATE
- The contacts array is stored in @State (mutable, not let)
- Initialized from Contact.samples

NAVIGATION
- The List is inside a NavigationStack
- .navigationTitle("Contacts") is applied
- The title displays correctly

QUALITY
- No hardcoded contact names in the view
- No List(contacts) shorthand without ForEach (won't work with onDelete later)
- #Preview compiles
```
