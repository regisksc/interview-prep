# Navigation Challenges

## Challenge 1: Basic NavigationStack

**Time:** 20 minutes

### Requirements

1. Create a list of items
2. Tapping an item navigates to detail view
3. Detail view shows item name and description
4. Navigation bar shows proper titles

### Starter Code

```swift
import SwiftUI

struct Item: Identifiable {
    let id = UUID()
    let name: String
    let description: String
}

struct ContentView: View {
    let items = [
        Item(name: "Item 1", description: "First item"),
        Item(name: "Item 2", description: "Second item"),
        Item(name: "Item 3", description: "Third item")
    ]
    
    var body: some View {
        Text("Hello")
    }
}
```

### Expected Output

```
┌─────────────────┐
│ Items           │
├─────────────────┤
│ Item 1      ›   │
│ Item 2      ›   │
│ Item 3      ›   │
└─────────────────┘
```

### Evaluation Criteria

- NavigationStack setup
- NavigationLink usage
- Proper navigationDestination

---

## Challenge 2: Passing Data Between Views

**Time:** 25 minutes

### Requirements

1. Create a list of users
2. Tap user to navigate to profile
3. Profile view can edit user name
4. Changes persist when navigating back

### Expected Behavior

```
Users List → Profile (Edit) → Back to List (updated)
```

### Evaluation Criteria

- Data passing to detail view
- @Binding or @EnvironmentObject usage
- Two-way data flow

---

## Challenge 3: Programmatic Navigation

**Time:** 30 minutes

### Requirements

1. Create a list with a "Next" button
2. Button navigates to next screen
3. Each screen has "Back" and "Next" buttons
4. Last screen has "Complete" that pops to root

### Expected Flow

```
Screen 1 → Screen 2 → Screen 3 → Root
   ↓         ↓         ↓
 Complete  Back      Back
```

### Evaluation Criteria

- NavigationPath usage
- Programmatic push/pop
- Path manipulation

---

## Challenge 4: Modal Presentation

**Time:** 25 minutes

### Requirements

1. Create a view with "Show Modal" button
2. Modal presents as sheet
3. Modal has "Save" and "Cancel" buttons
4. Save passes data back to parent
5. Cancel dismisses without changes

### Expected Behavior

```
Parent View
     ↓
  ┌─────────┐
  │  Sheet  │
  │ Save │ Cancel │
  └─────────┘
```

### Evaluation Criteria

- .sheet() usage
- @Environment(\.dismiss)
- Data passing back via callback

---

## Challenge 5: Navigation with State

**Time:** 35 minutes

### Requirements

1. Create a master-detail flow
2. Master view has search functionality
3. Search filters the list
4. Detail view allows deleting item
5. Deleted item removes from list and pops back

### Evaluation Criteria

- Search with navigation
- State management across views
- Delete with navigation handling

---

## Challenge 6: Tab + Navigation

**Time:** 40 minutes

### Requirements

1. Create app with 3 tabs
2. Each tab has its own navigation stack
3. Tabs maintain independent navigation state
4. Can navigate deep in multiple tabs
5. Switching tabs preserves navigation state

### Expected Structure

```
┌─────────────────────────────┐
│  Tab 1 │ Tab 2 │ Tab 3      │
├─────────────────────────────┤
│  Navigation Content         │
│  (independent per tab)      │
└─────────────────────────────┘
```

### Evaluation Criteria

- TabView with NavigationStack
- Independent path per tab
- State preservation

---

## Solutions

Reference solutions are in the `solutions/` directory.
