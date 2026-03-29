# Performance Challenges

## Challenge 1: Lazy Loading Images

**Time:** 40 minutes

### Requirements

1. Create a list of 1000 items with images
2. Load images lazily as they appear on screen
3. Cache loaded images
4. Cancel in-flight requests for scrolled-off cells

### Expected Behavior

- Scroll smoothly through 1000 items
- Images load as they come into view
- No memory growth over time

### Evaluation Criteria

- Lazy loading implementation
- Image caching
- Request cancellation

---

## Challenge 2: Expensive Computation in Body

**Time:** 20 minutes

### Requirements

1. Create a SwiftUI view with expensive computation in body
2. Identify the performance issue
3. Fix by moving computation outside body
4. Measure improvement

### Problem Code

```swift
struct SlowView: View {
    let items: [Item]
    
    var body: some View {
        // Expensive computation runs on every render
        let sorted = items.sorted { $0.name < $1.name }
            .filter { $0.isActive }
            .map { $0.transformed() }
        
        return List(sorted) { item in
            Text(item.name)
        }
    }
}
```

### Expected Fix

```swift
struct FastView: View {
    let items: [Item]
    
    private var processedItems: [Item] {
        items.sorted { $0.name < $1.name }
            .filter { $0.isActive }
            .map { $0.transformed() }
    }
    
    var body: some View {
        List(processedItems) { item in
            Text(item.name)
        }
    }
}
```

### Evaluation Criteria

- Understanding of SwiftUI body lifecycle
- Computed property usage
- Performance measurement

---

## Challenge 3: Offscreen Rendering

**Time:** 30 minutes

### Requirements

1. Create a view with shadows and rounded corners
2. Identify offscreen rendering issue
3. Apply rasterization optimization
4. Measure FPS improvement

### Problem Areas

- Multiple shadows on list items
- Complex layer combinations
- Repeated path calculations

### Expected Fix

```swift
// Enable rasterization for complex views
view.layer.shouldRasterize = true
view.layer.rasterizationScale = UIScreen.main.scale
```

### Evaluation Criteria

- Understanding of offscreen rendering
- Rasterization usage
- Instruments usage

---

## Challenge 4: Main Thread Blocking

**Time:** 25 minutes

### Requirements

1. Identify main thread blocking code
2. Move to background queue
3. Update UI on main thread
4. Verify with Time Profiler

### Problem Code

```swift
func processData() {
    // Blocking main thread
    let result = heavyComputation()
    updateUI(result)
}
```

### Expected Fix

```swift
func processData() {
    Task.detached {
        let result = heavyComputation()
        await MainActor.run {
            updateUI(result)
        }
    }
}
```

### Evaluation Criteria

- Thread awareness
- async/await usage
- MainActor for UI

---

## Challenge 5: Unnecessary Redraws

**Time:** 30 minutes

### Requirements

1. Create a view with unnecessary state updates
2. Identify what triggers redraws
3. Optimize using EquatableView
4. Reduce @State scope

### Problem Code

```swift
struct ParentView: View {
    @State private var counter = 0
    
    var body: some View {
        VStack {
            ExpensiveChildView(data: largeDataSet)
            Button("Increment") { counter += 1 }
        }
    }
}
```

### Expected Fix

```swift
struct ParentView: View {
    @State private var counter = 0
    
    var body: some View {
        VStack {
            ExpensiveChildView(data: largeDataSet)
                .equatable()  // Only redraw if data changes
            
            CounterView(counter: counter)  // Extract state to child
        }
    }
}
```

### Evaluation Criteria

- Understanding of SwiftUI redraw triggers
- State scope optimization
- EquatableView usage

---

## Challenge 6: Memory Leak Detection

**Time:** 35 minutes

### Requirements

1. Create a view model with a retain cycle
2. Use Memory Graph to identify leak
3. Fix with weak/unowned capture
4. Verify fix

### Problem Code

```swift
class ViewModel: ObservableObject {
    var callback: (() -> Void)?
    
    init() {
        callback = { [self] in
            // Strong self capture → retain cycle
            doSomething()
        }
    }
}
```

### Expected Fix

```swift
callback = { [weak self] in
    self?.doSomething()
}
```

### Evaluation Criteria

- Memory Graph usage
- Retain cycle identification
- Weak capture pattern

---

## Solutions

Reference solutions are in the `solutions/` directory.
