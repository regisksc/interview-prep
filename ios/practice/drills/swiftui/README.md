# SwiftUI Drills

Focused exercises for mastering specific SwiftUI concepts.

---

## State Management Drills (1-10)

### Drill 1: @State Basics

**Time:** 10 minutes

Create a view with:
1. A counter displayed as text
2. A button that increments the counter
3. A button that decrements the counter
4. Counter changes color based on value (negative=red, positive=green)

```swift
// Starter
struct CounterView: View {
    var body: some View {
        Text("Counter")
    }
}
```

---

### Drill 2: @Binding Practice

**Time:** 15 minutes

Create a parent-child view:
1. Parent has @State for a text value
2. Child has @Binding to the text
3. Child has a TextField that modifies the binding
4. Parent displays the text in real-time

```swift
struct ParentView: View {
    var body: some View {
        ChildView(text: /* pass binding */)
    }
}

struct ChildView: View {
    var body: some View {
        TextField("Enter text", text: /* binding */)
    }
}
```

---

### Drill 3: @StateObject vs @ObservedObject

**Time:** 15 minutes

Create a ViewModel and use it correctly:

```swift
class CounterViewModel: ObservableObject {
    @Published var count = 0
    func increment() { count += 1 }
}

// Create two views:
// 1. OwnerView - creates the ViewModel (@StateObject)
// 2. ChildView - receives it (@ObservedObject)
```

---

### Drill 4: @AppStorage Persistence

**Time:** 10 minutes

Create a view that:
1. Saves a username to @AppStorage
2. Loads it on app launch
3. Has a "Clear" button that resets it

```swift
struct SettingsView: View {
    var body: some View {
        VStack {
            TextField("Username", text: /* @AppStorage */)
            Button("Clear") { /* reset */ }
        }
    }
}
```

---

### Drill 5: @EnvironmentObject Setup

**Time:** 15 minutes

Create a shared state that flows through the app:

```swift
class AppState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var username = ""
}

// 1. Create at App level
// 2. Inject with .environmentObject()
// 3. Read in deeply nested view with @EnvironmentObject
```

---

### Drill 6: Computed Properties for Derived State

**Time:** 10 minutes

Given an array of items, create:
1. Computed property for filtered items (active only)
2. Computed property for sorted items (by name)
3. Computed property for total count

```swift
struct ItemList: View {
    let items: [Item]
    
    // Add computed properties here
    
    var body: some View {
        List(items) { item in
            Text(item.name)
        }
    }
}
```

---

### Drill 7: Toggle State

**Time:** 10 minutes

Create a settings view with multiple toggles:
1. Dark mode toggle
2. Notifications toggle
3. Auto-sync toggle
4. Each toggle persists with @AppStorage

---

### Drill 8: Picker State

**Time:** 10 minutes

Create a view with:
1. A Picker for font size (Small, Medium, Large)
2. A Picker for theme (Light, Dark, System)
3. Preview shows current selection

---

### Drill 9: Sheet Presentation

**Time:** 15 minutes

Create a view that:
1. Has a "Show Details" button
2. Presents a sheet when tapped
3. Sheet has a "Close" button that dismisses it
4. Use @State for isPresented

---

### Drill 10: Alert with State

**Time:** 10 minutes

Create a view that:
1. Has a "Delete" button
2. Shows confirmation alert
3. Alert has "Cancel" and "Delete" actions
4. Delete action clears some state

---

## Layout Drills (11-20)

### Drill 11: VStack Basics

**Time:** 10 minutes

Create a profile card using only VStack:
1. Image at top
2. Text for name
3. Text for title (secondary color)
4. Button at bottom

---

### Drill 12: HStack Practice

**Time:** 10 minutes

Create a row with:
1. Icon (SF Symbol) on left
2. Title text in middle
3. Chevron on right
4. Proper spacing between elements

---

### Drill 13: ZStack Layering

**Time:** 10 minutes

Create a view with:
1. Background color rectangle
2. Circular image centered on top
3. Badge overlay on image (green dot)

---

### Drill 14: Spacer Usage

**Time:** 10 minutes

Create a toolbar:
1. Logo on left
2. Title in center
3. Action button on right
4. Use Spacers for positioning

---

### Drill 15: Divider and Spacers

**Time:** 10 minutes

Create a settings list:
1. Multiple rows with text
2. Dividers between rows
3. Proper padding

---

### Drill 16: ScrollView with VStack

**Time:** 10 minutes

Create a scrollable content area:
1. ScrollView containing VStack
2. 20 text items
3. Sticky header

---

### Drill 17: LazyVStack vs VStack

**Time:** 15 minutes

Create two lists:
1. One with VStack (observe performance)
2. One with LazyVStack (observe performance)
3. Each has 1000 items

---

### Drill 18: Grid with LazyVGrid

**Time:** 15 minutes

Create a photo grid:
1. 3 columns
2. Flexible column widths
3. 20 items

```swift
let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible())
]
```

---

### Drill 19: GeometryReader for Responsive

**Time:** 15 minutes

Create a view that:
1. Uses GeometryReader
2. Shows different layouts based on width
3. Single column if narrow, 3 columns if wide

---

### Drill 20: SafeArea and Padding

**Time:** 10 minutes

Create a view that:
1. Respects safe area
2. Has consistent padding
3. Full-width background with padded content

---

## Modifier Drills (21-30)

### Drill 21: Font Modifiers

**Time:** 10 minutes

Apply different fonts to text:
1. .font(.largeTitle)
2. .font(.headline)
3. .font(.caption)
4. Custom font with .font(.custom())

---

### Drill 22: Color and Opacity

**Time:** 10 minutes

Create views with:
1. Solid background color
2. Semi-transparent overlay
3. Gradient background

---

### Drill 23: Corner Radius and Clipping

**Time:** 10 minutes

Create shapes:
1. Rounded rectangle
2. Circle (clipped)
3. Custom corner radius

---

### Drill 24: Shadow and Overlay

**Time:** 10 minutes

Create a card with:
1. White background
2. Rounded corners
3. Shadow
4. Border overlay

---

### Drill 25: Rotation and Scale

**Time:** 10 minutes

Create an icon that:
1. Rotates 45 degrees
2. Scales to 1.2x
3. Both with animation

---

### Drill 26: Offset and Position

**Time:** 10 minutes

Position elements:
1. Using .offset(x:y:)
2. Using .position(x:y:)
3. Compare the difference

---

### Drill 27: Padding Variations

**Time:** 10 minutes

Apply padding:
1. Uniform padding
2. Horizontal only
3. Vertical only
4. Different per edge

---

### Drill 28: Frame Constraints

**Time:** 10 minutes

Create views with:
1. Fixed width and height
2. Min/max width
3. Frame with alignment

---

### Drill 29: Custom ViewModifier

**Time:** 15 minutes

Create a reusable modifier:

```swift
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 4)
    }
}

// Add extension for easy use
```

---

### Drill 30: Conditional Modifiers

**Time:** 15 minutes

Create a view that:
1. Has bold font if highlighted
2. Has yellow background if selected
3. Uses conditional modifiers

---

## Animation Drills (31-40)

### Drill 31: Basic withAnimation

**Time:** 10 minutes

Create a button that:
1. Changes background color on tap
2. Animates the change
3. Use withAnimation

---

### Drill 32: Implicit Animation

**Time:** 10 minutes

Add animation modifier:
1. .animation(.easeInOut, value: state)
2. State change triggers animation
3. No withAnimation wrapper needed

---

### Drill 33: Spring Animation

**Time:** 10 minutes

Create a bouncing effect:
1. Scale animation
2. Use .spring()
3. Adjust damping

---

### Drill 34: Transition - Opacity

**Time:** 10 minutes

Create a view that:
1. Fades in when appears
2. Fades out when disappears
3. Use .transition(.opacity)

---

### Drill 35: Transition - Move

**Time:** 10 minutes

Create a sliding effect:
1. Slide in from leading
2. Slide out to trailing
3. Use .transition(.move)

---

### Drill 36: Combined Transitions

**Time:** 15 minutes

Create a transition that:
1. Scales and fades together
2. Use .transition(.scale.combined(with: .opacity))

---

### Drill 37: Explicit Animation

**Time:** 15 minutes

Create an Animation struct:
1. Custom duration
2. Custom curve
3. Apply with .animation(animation, value:)

---

### Drill 38: Repeating Animation

**Time:** 15 minutes

Create a pulsing effect:
1. Scale up and down
2. Repeat forever
3. Autoreverse

---

### Drill 39: Gesture Animation

**Time:** 20 minutes

Create a draggable view:
1. DragGesture
2. Updates position
3. Springs back on release

---

### Drill 40: Matched Geometry

**Time:** 25 minutes

Create a hero animation:
1. Small image in list
2. Tap to expand
3. Image animates to new position
4. Use @Namespace

---

## List Drills (41-50)

### Drill 41: Basic List

**Time:** 10 minutes

Create a list that:
1. Displays array of strings
2. Uses ForEach
3. Has item count in navigation

---

### Drill 42: List with Identifiable

**Time:** 10 minutes

Create a list with custom objects:
1. Item struct with id
2. ForEach with id: \.id
3. Display item properties

---

### Drill 43: Swipe to Delete

**Time:** 15 minutes

Add to a list:
1. .onDelete modifier
2. Delete function
3. Animate removal

---

### Drill 44: List Navigation

**Time:** 15 minutes

Create master-detail:
1. List of items
2. NavigationLink for each
3. Detail view shows full info

---

### Drill 45: Searchable List

**Time:** 20 minutes

Add search to a list:
1. .searchable modifier
2. Filter items based on query
3. Show search results

---

### Drill 46: Sectioned List

**Time:** 15 minutes

Create a list with:
1. Multiple sections
2. Section headers
3. Section footers

---

### Drill 47: Custom List Row

**Time:** 15 minutes

Create a custom row:
1. Image on left
2. Title and subtitle
3. Disclosure indicator

---

### Drill 48: List with Toggle

**Time:** 10 minutes

Create a settings list:
1. Toggle in each row
2. State per item
3. Persists changes

---

### Drill 49: Pull to Refresh

**Time:** 15 minutes

Add refresh to a list:
1. .refreshable modifier
2. Async refresh function
3. Loading indicator

---

### Drill 50: Dynamic List Height

**Time:** 15 minutes

Create a list that:
1. Expands to content
2. No scrolling within scroll
3. Uses IntrinsicContentSize

---

## Advanced Drills (51-60)

### Drill 51: Custom Environment

**Time:** 20 minutes

Create custom environment:
1. Define EnvironmentKey
2. Extend EnvironmentValues
3. Inject and read value

---

### Drill 52: PreferenceKey

**Time:** 20 minutes

Create child-to-parent communication:
1. Child sets preference
2. Parent reads with onPreferenceChange
3. Use for dynamic sizing

---

### Drill 53: UIViewRepresentable

**Time:** 25 minutes

Wrap a UIKit view:
1. Create UIViewRepresentable
2. Implement makeUIView
3. Implement updateUIView
4. Add coordinator for delegate

---

### Drill 54: AsyncImage

**Time:** 15 minutes

Load remote image:
1. AsyncImage with URL
2. Placeholder while loading
3. Error state

---

### Drill 55: PhaseAnimator (iOS 17)

**Time:** 20 minutes

Create multi-phase animation:
1. PhaseAnimator with states
2. Different animation per phase
3. Automatic cycling

---

### Drill 56: Canvas Drawing

**Time:** 25 minutes

Draw custom graphics:
1. Canvas view
2. Draw shapes with GraphicsContext
3. Add text

---

### Drill 57: Chart (iOS 16)

**Time:** 25 minutes

Create a bar chart:
1. Chart view
2. BarMark for data
3. Axis labels

---

### Drill 58: FocusState

**Time:** 15 minutes

Manage text field focus:
1. @FocusState property
2. Programmatic focus
3. Focus on appear

---

### Drill 59: SceneStorage

**Time:** 15 minutes

Preserve state across launches:
1. @SceneStorage property
2. Save scroll position
3. Restore on return

---

### Drill 60: Accessibility

**Time:** 20 minutes

Add accessibility:
1. accessibilityLabel
2. accessibilityHint
3. accessibilityTraits
4. Test with VoiceOver

---

## How to Use These Drills

1. **Set a timer** - Stick to the suggested time
2. **No copying** - Type everything from memory/understanding
3. **Run it** - Make sure it compiles and works
4. **Review** - Compare with reference solution
5. **Repeat** - Come back to drills you struggled with

---

## Tracking Progress

Copy this checklist and mark off completed drills:

```
State Management:
□ Drill 1  □ Drill 2  □ Drill 3  □ Drill 4  □ Drill 5
□ Drill 6  □ Drill 7  □ Drill 8  □ Drill 9  □ Drill 10

Layout:
□ Drill 11 □ Drill 12 □ Drill 13 □ Drill 14 □ Drill 15
□ Drill 16 □ Drill 17 □ Drill 18 □ Drill 19 □ Drill 20

Modifiers:
□ Drill 21 □ Drill 22 □ Drill 23 □ Drill 24 □ Drill 25
□ Drill 26 □ Drill 27 □ Drill 28 □ Drill 29 □ Drill 30

Animation:
□ Drill 31 □ Drill 32 □ Drill 33 □ Drill 34 □ Drill 35
□ Drill 36 □ Drill 37 □ Drill 38 □ Drill 39 □ Drill 40

Lists:
□ Drill 41 □ Drill 42 □ Drill 43 □ Drill 44 □ Drill 45
□ Drill 46 □ Drill 47 □ Drill 48 □ Drill 49 □ Drill 50

Advanced:
□ Drill 51 □ Drill 52 □ Drill 53 □ Drill 54 □ Drill 55
□ Drill 56 □ Drill 57 □ Drill 58 □ Drill 59 □ Drill 60
```

---

## Reference Solutions

Solutions for all drills are in the `solutions/` directory, organized by category.
