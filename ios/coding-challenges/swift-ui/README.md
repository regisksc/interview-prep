# SwiftUI Challenges

Comprehensive SwiftUI exercises from basics to advanced patterns.

---

## Beginner (1-10)

### Challenge 1: Counter with Persistence

**Time:** 20 minutes | **Concepts:** @State, @AppStorage, basic layout

### Requirements

Build a counter app that:
1. Displays current count in large font
2. Has increment (+) and decrement (-) buttons
3. Persists count across app launches using @AppStorage
4. Shows different colors based on count value:
   - Negative: red
   - Zero: gray
   - Positive: green
5. Reset button to return to zero

### Starter Code

```swift
import SwiftUI

@main
struct CounterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
    }
}
```

### Expected Output

```
┌─────────────────────┐
│                     │
│         5           │  (green)
│                     │
│   [-]   [0]   [+]   │
│                     │
└─────────────────────┘
```

### Bonus
- Add haptic feedback on button tap
- Animate count changes

---

### Challenge 2: Profile Card

**Time:** 25 minutes | **Concepts:** VStack, HStack, Image, Text styling

### Requirements

Create a profile card component:
1. Circular profile image (use SF Symbol or placeholder)
2. Name in bold, large font
3. Job title in secondary color
4. Location with SF Symbol
5. Follow/Following button that toggles state
6. Stats row (Posts, Followers, Following)

### Expected Output

```
┌─────────────────────┐
│      (  👤  )       │  ← circular
│                     │
│   John Doe          │  ← bold
│   Software Engineer │  ← secondary
│   📍 San Francisco  │
│                     │
│   [  Following  ]   │  ← toggle
│                     │
│  42    1.2K   350   │  ← stats
│ Posts Followers Fng │
└─────────────────────┘
```

### Bonus
- Make it a reusable component with @Binding for follow state
- Add gradient background

---

### Challenge 3: Todo List Basics

**Time:** 30 minutes | **Concepts:** List, ForEach, @State array

### Requirements

Build a simple todo list:
1. Display list of todo items
2. Each item shows title and completion status
3. Tap to toggle completion (strikethrough when done)
4. Swipe to delete
5. Add new item with text field at bottom
6. Show item count in navigation title

### Expected Output

```
┌─────────────────────┐
│ Todos (3)           │
├─────────────────────┤
│ ☐ Buy milk          │
│ ☑️ Call mom         │  ← strikethrough
│ ☐ Finish project    │
├─────────────────────┤
│ [Add new item...] + │
└─────────────────────┘
```

### Bonus
- Add due dates
- Filter by All/Active/Completed

---

### Challenge 4: Form Validation

**Time:** 30 minutes | **Concepts:** @State, computed properties, validation

### Requirements

Build a registration form:
1. Email field with validation (must contain @)
2. Password field (min 8 characters)
3. Confirm password field (must match)
4. Show error messages below each invalid field
5. Register button enabled only when all valid
6. Show success alert on valid submission

### Expected Output

```
┌─────────────────────┐
│ Email:              │
│ [test@example.com]  │
│                     │
│ Password:           │
│ [********]          │
│ ⚠️ Min 8 characters │  ← error
│                     │
│ Confirm:            │
│ [********]          │
│                     │
│   [Register]        │  ← disabled
└─────────────────────┘
```

### Bonus
- Add password strength indicator
- Real-time validation feedback

---

### Challenge 5: Tab Navigation

**Time:** 25 minutes | **Concepts:** TabView, @State for selection

### Requirements

Create an app with 3 tabs:
1. Home tab with a list of items
2. Search tab with search functionality
3. Settings tab with toggles
4. Each tab has its own navigation
5. Badge notifications on tabs

### Expected Output

```
┌─────────────────────┐
│ Home                │
│ ┌─────────────────┐ │
│ │ Item 1          │ │
│ │ Item 2          │ │
│ └─────────────────┘ │
│                     │
│ 🏠    🔍    ⚙️     │  ← tabs
│ Home Search Settings│
└─────────────────────┘
```

### Bonus
- Deep link to specific tab
- Custom tab bar icons

---

## Intermediate (6-15)

### Challenge 6: API Fetch with States

**Time:** 45 minutes | **Concepts:** async/await, @MainActor, state management

### Requirements

Build a user list app that:
1. Fetches users from JSONPlaceholder API
2. Shows loading state with skeleton/progress
3. Shows error state with retry button
4. Displays user list when successful
5. Pull-to-refresh functionality
6. Tap user to see details in new view

### API Endpoint

```
https://jsonplaceholder.typicode.com/users
```

### Expected States

```
Loading:    Error:          Success:
┌────────┐  ┌──────────┐    ┌──────────┐
│  ⏳    │  │  ❌      │    │ 👤 John  │
│Loading │  │ Try Again│    │ 👤 Jane  │
└────────┘  └──────────┘    │ 👤 Bob   │
                            └──────────┘
                            ↻ Pull to refresh
```

### Bonus
- Cache images
- Implement pagination
- Search/filter users

---

### Challenge 7: Custom View Modifiers

**Time:** 30 minutes | **Concepts:** ViewModifier, Environment

### Requirements

Create reusable view modifiers:
1. `cardStyle()` - rounded corners, shadow, padding
2. `headingStyle()` - custom font, color, spacing
3. `loadingOverlay(isLoading:)` - shows loading indicator
4. `errorOverlay(error:retry:)` - shows error message
5. Use Environment for theme (light/dark)

### Expected Usage

```swift
Text("Title")
    .headingStyle()

VStack {
    // content
}
.cardStyle()
.loadingOverlay(isLoading: isLoading)
```

### Bonus
- Create custom EnvironmentKey for app-wide settings
- Animate modifier changes

---

### Challenge 8: Master-Detail with Navigation

**Time:** 35 minutes | **Concepts:** NavigationStack, NavigationPath, data passing

### Requirements

Build a product catalog:
1. List of products with images and prices
2. Tap product to see details
3. Detail view has "Add to Cart" button
4. Cart view shows selected items
5. Navigate to checkout from cart
6. Pass data back (update quantity)

### Expected Flow

```
Products → Product Detail → Cart → Checkout
   ↑           ↑              ↓
   └───────────┴──────────────┘
```

### Bonus
- Programmatic navigation
- Deep linking support

---

### Challenge 9: Gesture-Driven UI

**Time:** 40 minutes | **Concepts:** DragGesture, gestures, animations

### Requirements

Create an interactive card:
1. Card can be dragged left/right
2. Dragging rotates and moves card
3. Swipe right = "Like" (green indicator)
4. Swipe left = "Nope" (red indicator)
5. Card flies off screen on release
6. Next card appears

### Expected Behavior

```
Drag right →     Drag left →
┌────────┐       ┌────────┐
│  💚    │       │    ❤️  │
│   👤   │       │   👤   │
└────────┘       └────────┘
  LIKE             NOPE
```

### Bonus
- Haptic feedback on like/nope
- Undo last action

---

### Challenge 10: Complex Animation

**Time:** 45 minutes | **Concepts:** Animation, withAnimation, transitions

### Requirements

Build an animated loading sequence:
1. Three dots that pulse in sequence
2. Each dot animates with delay
3. Smooth continuous animation
4. Configurable colors and timing
5. Start/stop control

### Expected Output

```
Loading:  ●○○  →  ○●○  →  ○○●  →  ●○○
```

### Bonus
- Custom animation curves
- Sync with network activity

---

### Challenge 11: Settings with Persistence

**Time:** 35 minutes | **Concepts:** @AppStorage, Picker, Toggle

### Requirements

Build a settings screen:
1. Dark mode toggle (persists)
2. Font size picker (Small, Medium, Large)
3. Notification toggle
4. Language picker
5. Reset to defaults button
6. Settings affect entire app via Environment

### Expected Output

```
┌─────────────────────┐
│ Settings            │
├─────────────────────┤
│ Dark Mode      [ON] │
│ Font Size   [Medium]│
│ Notifications  [ON] │
│ Language     [English]│
├─────────────────────┤
│ [Reset to Defaults] │
└─────────────────────┘
```

### Bonus
- Export/import settings
- iCloud sync

---

### Challenge 12: Search with Debounce

**Time:** 40 minutes | **Concepts:** Combine, debounce, async

### Requirements

Build a search interface:
1. Search bar at top
2. Results update as user types
3. Debounce input (300ms)
4. Show loading indicator during search
5. Show "no results" state
6. Recent searches saved

### Expected Output

```
┌─────────────────────┐
│ [🔍 Search...]      │
├─────────────────────┤
│ Recent:             │
│ • iPhone            │
│ • MacBook           │
├─────────────────────┤
│ Results:            │
│ 📱 iPhone 15        │
│ 💻 MacBook Pro      │
└─────────────────────┘
```

### Bonus
- Highlight matching text
- Search history management

---

## Advanced (13-20)

### Challenge 13: Custom Layout

**Time:** 50 minutes | **Concepts:** LayoutProtocol, GeometryReader

### Requirements

Create a custom layout:
1. Masonry/grid layout (like Pinterest)
2. Items of varying heights
3. Efficient filling of gaps
4. Support for different column counts
5. Animate on insert/remove

### Expected Output

```
┌─────────────────────┐
│ ┌─┐ ┌───┐ ┌─┐       │
│ │ │ │   │ │ │       │
│ │ │ │   │ └─┘       │
│ └─┘ │   │ ┌───┐     │
│ ┌───┘ │   │   │     │
│ │   ┌─┘   └───┘     │
│ └───┘               │
└─────────────────────┘
```

### Bonus
- Drag to reorder
- Infinite scroll

---

### Challenge 14: Drawing with Canvas

**Time:** 45 minutes | **Concepts:** Canvas, GraphicsContext, paths

### Requirements

Build a simple drawing app:
1. Canvas for drawing
2. Multiple brush colors
3. Brush size slider
4. Clear canvas button
5. Undo functionality
6. Save as image

### Expected Output

```
┌─────────────────────┐
│ 🎨 🖊️ ✏️ 🖌️  [Clear]│  ← tools
├─────────────────────┤
│                     │
│    (drawing area)   │
│                     │
│                     │
├─────────────────────┤
│ Size: [━━━━●━━━━]   │
│ [Undo]    [Save]    │
└─────────────────────┘
```

### Bonus
- Different brush types
- Layers support

---

### Challenge 15: Chart Visualization

**Time:** 50 minutes | **Concepts:** Canvas, paths, animations

### Requirements

Create data visualizations:
1. Bar chart component
2. Line chart component
3. Pie chart component
4. Animated transitions
5. Tooltips on tap

### Expected Output

```
┌─────────────────────┐
│ Sales Report        │
│ ┌─┐   ┌─┐           │
│ │ │ ┌─┘ │ ┌─┐       │
│ │ │ │   │ │ │       │
│ └─┴─┴───┴─┴─┘       │
│ J  F  M  A  M       │
└─────────────────────┘
```

### Bonus
- Zoom and pan
- Export as image

---

### Challenge 16: Video Player

**Time:** 45 minutes | **Concepts:** UIViewRepresentable, AVPlayer

### Requirements

Build a video player:
1. Wrap AVPlayer in SwiftUI
2. Play/pause controls
3. Seek bar with scrubbing
4. Volume control
5. Fullscreen toggle

### Expected Output

```
┌─────────────────────┐
│                     │
│   (video content)   │
│                     │
│ ━━━━━━━●━━━━━━━━━   │  ← seek
│ ⏮️ ⏯️ ⏭️ 🔊 ────    │  ← controls
└─────────────────────┘
```

### Bonus
- Picture in picture
- Playback speed control

---

### Challenge 17: Map Integration

**Time:** 45 minutes | **Concepts:** MapKit, annotations

### Requirements

Build a map view:
1. Show user's location
2. Display custom annotations
3. Tap annotation for details
4. Search for locations
5. Draw route between points

### Bonus
- Custom annotation views
- Clustering for many points

---

### Challenge 18: Camera Integration

**Time:** 45 minutes | **Concepts:** AVFoundation, UIViewRepresentable

### Requirements

Build a camera interface:
1. Live camera preview
2. Capture photo button
3. Switch front/back camera
4. Flash toggle
5. Photo gallery preview

### Bonus
- Filters on captured photos
- Video recording

---

### Challenge 19: Real-time Chat UI

**Time:** 60 minutes | **Concepts:** ScrollView, ScrollViewReader, state

### Requirements

Build a chat interface:
1. Message bubbles (sent/received)
2. Auto-scroll to bottom on new message
3. Text input with send button
4. Message timestamps
5. Read receipts
6. Typing indicator

### Expected Output

```
┌─────────────────────┐
│ Chat with John      │
├─────────────────────┤
│            Hey! 👋  │  ← received
│ Hi there!       👉  │  ← sent
│            How are  │
│            you?     │
│                     │
├─────────────────────┤
│ [Type message...] 📤│
└─────────────────────┘
```

### Bonus
- Image attachments
- Message reactions

---

### Challenge 20: Complete E-commerce Flow

**Time:** 90 minutes | **Concepts:** All of the above

### Requirements

Build a mini e-commerce app:
1. Product listing with categories
2. Product detail with image carousel
3. Shopping cart (add/remove/update)
4. Checkout flow with form validation
5. Order confirmation
6. Order history
7. User profile
8. Settings

### Features Required

- NavigationStack with multiple levels
- State management (@State, @StateObject, Environment)
- API integration (mock or real)
- Form validation
- Animations
- Persistence
- Search and filter

### Bonus
- Payment integration (Stripe)
- Push notifications
- Offline support

---

## Evaluation Rubric

| Criteria | Beginner | Intermediate | Advanced |
|----------|----------|--------------|----------|
| **Functionality** | Works as expected | Handles edge cases | Production-ready |
| **Code Quality** | Clean, readable | Well-structured | Optimized, reusable |
| **SwiftUI Idioms** | Basic usage | Proper patterns | Advanced techniques |
| **State Management** | @State only | Multiple tools | Custom solutions |
| **Performance** | Acceptable | Good | Optimized |
| **Accessibility** | Basic labels | Full support | Enhanced |

---

## Tips for Success

1. **Start simple** - Get it working, then improve
2. **Use previews** - Leverage SwiftUI previews heavily
3. **Think declaratively** - Describe what, not how
4. **Extract views** - Break into small components
5. **Test on devices** - Check different screen sizes
6. **Consider accessibility** - Add labels and traits
7. **Profile early** - Use Instruments for performance

---

## Solutions

Reference solutions with multiple approaches are in the `solutions/` directory.
