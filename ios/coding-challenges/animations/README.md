# Animation Challenges

## Challenge 1: Implicit Animation

**Time:** 15 minutes

### Requirements

1. Create a view with a colored square
2. Tap the square to change its color
3. Animate the color change
4. Use withAnimation for implicit animation

### Starter Code

```swift
struct ContentView: View {
    @State private var isRed = true
    
    var body: some View {
        Rectangle()
            .fill(isRed ? Color.red : Color.blue)
            .frame(width: 100, height: 100)
            .onTapGesture {
                isRed.toggle()
            }
    }
}
```

### Expected Behavior

- Tap square → smooth color transition

### Evaluation Criteria

- withAnimation usage
- State change triggering animation

---

## Challenge 2: Explicit Animation

**Time:** 20 minutes

### Requirements

1. Create a view with a moving circle
2. Button tap moves circle from left to right
3. Use Animation for explicit control
4. Add spring effect

### Expected Output

```
┌─────────────────────┐
│  ○                  │  →  │              ○  │
│                     │     │                 │
│   [Move]            │     │   [Move]        │
└─────────────────────┘     └─────────────────┘
```

### Evaluation Criteria

- Animation modifier
- Spring animation
- Position state management

---

## Challenge 3: Multiple Animations

**Time:** 30 minutes

### Requirements

1. Create a view with scale and rotation
2. Animate both properties simultaneously
3. Use different timing for each
4. Add repeat and autoreverse

### Expected Behavior

- Square scales up while rotating
- Scale uses easeInOut
- Rotation uses linear with repeat

### Evaluation Criteria

- Multiple simultaneous animations
- Different timing curves
- Repeat and autoreverse

---

## Challenge 4: Transition Animations

**Time:** 25 minutes

### Requirements

1. Create a view that shows/hides content
2. Animate insertion and removal
3. Use .transition() with different effects
4. Combine withAnimation

### Expected Output

```
┌─────────────────────┐
│ [Toggle]            │
│                     │
│   → fades in →      │
│   Hello World       │
│   ← fades out ←     │
└─────────────────────┘
```

### Evaluation Criteria

- .transition() usage
- Insertion/removal animations
- Transition types (opacity, move, scale)

---

## Challenge 5: Gesture-Driven Animation

**Time:** 35 minutes

### Requirements

1. Create a draggable circle
2. Circle follows finger during drag
3. Spring back to original position on release
4. Add gesture animation

### Expected Behavior

```
Touch & drag → follows finger
Release → springs back to center
```

### Evaluation Criteria

- DragGesture usage
- Animation with gesture
- Spring back on release

---

## Challenge 6: Custom Animation

**Time:** 40 minutes

### Requirements

1. Create a pulsing circle (like recording indicator)
2. Circle grows and shrinks continuously
3. Custom timing curve
4. Infinite repeat

### Expected Output

```
    ○         ○○○       ○
  (small) → (large) → (small)
```

### Evaluation Criteria

- Custom animation timing
- Infinite repeat
- Smooth continuous animation

---

## Challenge 7: Hero Animation

**Time:** 30 minutes

### Requirements

1. Create a list of items with images
2. Tap item to navigate to detail
3. Image animates (hero animation) between views
4. Use matched modifier

### Expected Behavior

```
List: [🖼️ Item 1]  →  Detail:
                          ┌────────┐
                          │  🖼️    │
                          │ Large  │
                          │ Image  │
                          └────────┘
```

### Evaluation Criteria

- matched() modifier
- Hero animation setup
- Navigation integration

---

## Solutions

Reference solutions are in the `solutions/` directory.
