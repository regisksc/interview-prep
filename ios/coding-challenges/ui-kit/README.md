# UIKit Challenges

## Challenge 1: Basic ViewController

**Time:** 20 minutes

### Requirements

Create a ViewController that:
1. Has a UILabel displaying "Hello, World!"
2. Has a UIButton that changes the label text when tapped
3. Label and button are centered using Auto Layout
4. Button counter tracks number of taps

### Starter Code

```swift
import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        // Add your setup here
    }
}
```

### Expected Output

```
┌─────────────────────┐
│                     │
│   Hello, World!     │
│   (Count: 0)        │
│                     │
│   [Tap Me]          │
│                     │
└─────────────────────┘
```

### Evaluation Criteria

- Programmatic Auto Layout
- Proper constraint activation
- Target-action pattern

---

## Challenge 2: TableView with Data

**Time:** 30 minutes

### Requirements

Create a ViewController with:
1. UITableView displaying a list of names
2. Data source is an array of strings
3. Tapping a row prints the selected name to console
4. Swipe-to-delete functionality
5. Update data source after deletion

### Expected Behavior

```
┌─────────────────────┐
│ Names               │
├─────────────────────┤
│ Alice          ›    │
│ Bob            ›    │
│ Charlie        ›    │
└─────────────────────┘
```

### Evaluation Criteria

- UITableViewDataSource implementation
- UITableViewDelegate for selection
- Proper cell reuse
- Data source mutation

---

## Challenge 3: Multiple ViewControllers

**Time:** 35 minutes

### Requirements

Create a navigation flow:
1. Root ViewController with a list of items
2. Tapping an item pushes to DetailViewController
3. DetailViewController shows item details
4. DetailViewController has an "Edit" button
5. Edit navigates to EditViewController (modal)
6. EditViewController passes data back via delegate

### Expected Flow

```
ListVC → DetailVC → EditVC (modal)
  ↑                    ↓
  └──── (delegate) ────┘
```

### Evaluation Criteria

- Programmatic navigation
- Modal presentation
- Delegate pattern for data return
- Proper data passing

---

## Challenge 4: Custom UIView

**Time:** 40 minutes

### Requirements

Create a custom UIView that:
1. Draws a circular progress indicator
2. Accepts `progress` property (0.0 to 1.0)
3. Animates progress changes
4. Configurable stroke color and width
5. Works with Auto Layout

### Expected Output

```
┌─────────────────────┐
│                     │
│       ╭───╮         │
│      ╱     ╲        │
│     │  75%  │       │
│      ╲     ╱        │
│       ╰───╯         │
│                     │
└─────────────────────┘
```

### Evaluation Criteria

- Custom drawing with Core Graphics
- Proper use of draw(_:)
- Animation with UIView.animate
- IBDesignable (bonus)

---

## Challenge 5: API Integration

**Time:** 50 minutes

### Requirements

Create a user list app that:
1. Fetches users from JSONPlaceholder API
2. Displays in UITableView with custom cells
3. Shows activity indicator while loading
4. Handles errors with alert
5. Pull-to-refresh functionality
6. Tap to show user details in new ViewController

### API Endpoint

```
https://jsonplaceholder.typicode.com/users
```

### Evaluation Criteria

- URLSession usage
- JSON decoding with Codable
- Activity indicator management
- Error handling with UIAlertController
- Delegate pattern for refresh

---

## Solutions

Reference solutions are in the `solutions/` directory of each challenge.
