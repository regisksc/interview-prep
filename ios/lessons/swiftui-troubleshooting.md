# SwiftUI Troubleshooting Guide

Common issues and their solutions.

---

## State Issues

### Problem: View doesn't update when data changes

**Cause:** Using regular properties instead of @State

```swift
// ❌ WRONG
struct CounterView: View {
    var count = 0  // Regular property, never changes
    
    var body: some View {
        Text("Count: \(count)")
    }
}

// ✅ CORRECT
struct CounterView: View {
    @State private var count = 0  // @State triggers updates
    
    var body: some View {
        Text("Count: \(count)")
    }
}
```

---

### Problem: @ObservedObject recreates on every render

**Cause:** Using @ObservedObject instead of @StateObject

```swift
// ❌ WRONG
struct ProfileView: View {
    @ObservedObject var viewModel = ProfileViewModel()
    // Creates new viewModel every time body runs!
    
    var body: some View { }
}

// ✅ CORRECT
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    // Creates once, keeps alive
    
    var body: some View { }
}
```

---

### Problem: Can't modify @State in child view

**Cause:** Need @Binding for two-way connection

```swift
// ❌ WRONG
struct ParentView: View {
    @State private var count = 0
    
    var body: some View {
        ChildView(count: count)  // Passes copy, not binding
    }
}

struct ChildView: View {
    let count: Int  // Can't modify
    
    var body: some View {
        Button("Increment") {
            // count += 1  // Error: Cannot modify
        }
    }
}

// ✅ CORRECT
struct ParentView: View {
    @State private var count = 0
    
    var body: some View {
        ChildView(count: $count)  // $ creates binding
    }
}

struct ChildView: View {
    @Binding var count: Int  // Can modify parent's state
    
    var body: some View {
        Button("Increment") {
            count += 1  // Modifies parent's state
        }
    }
}
```

---

### Problem: EnvironmentObject crash at runtime

**Cause:** Forgot to inject with .environmentObject()

```swift
// ❌ WRONG - Runtime crash
@main
struct MyApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            // Missing: .environmentObject(appState)
        }
    }
}

// ✅ CORRECT
@main
struct MyApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
```

**Error message:** "No ObservableObject of type AppState found in environment"

---

## Layout Issues

### Problem: Views not appearing

**Cause:** Frame constraints too restrictive

```swift
// ❌ WRONG - Zero width
Text("Hello")
    .frame(width: 0)

// ✅ CORRECT
Text("Hello")
    .frame(minWidth: 0, maxWidth: .infinity)
```

---

### Problem: ScrollView not scrolling

**Cause:** Content doesn't have defined size

```swift
// ❌ WRONG
ScrollView {
    Text("Long content...")
        // No constraints
}

// ✅ CORRECT
ScrollView {
    VStack {
        Text("Long content...")
    }
    .frame(maxWidth: .infinity, alignment: .leading)
}
```

---

### Problem: ZStack layers not visible

**Cause:** Background covering content

```swift
// ❌ WRONG
ZStack {
    Color.red  // Opaque, covers everything
    Text("Hello")
}

// ✅ CORRECT
ZStack {
    Color.red.opacity(0.2)  // Semi-transparent
    Text("Hello")
}
```

---

## Animation Issues

### Problem: Animation not working

**Cause:** Missing withAnimation or animation modifier

```swift
// ❌ WRONG - No animation
@State private var scale = 1.0

Button("Scale") {
    scale = 1.5  // Instant change
}

// ✅ CORRECT - Option 1
Button("Scale") {
    withAnimation {
        scale = 1.5  // Animated
    }
}

// ✅ CORRECT - Option 2
Text("Hello")
    .scaleEffect(scale)
    .animation(.easeInOut, value: scale)
```

---

### Problem: Animation on wrong view

**Cause:** Animation modifier on parent instead of animated view

```swift
// ❌ WRONG
VStack {
    Image("icon")
}
.animation(.easeInOut, value: isLoading)  // Animates VStack

// ✅ CORRECT
VStack {
    Image("icon")
        .rotationEffect(.degrees(isLoading ? 360 : 0))
        .animation(.easeInOut, value: isLoading)  // Animates Image
}
```

---

### Problem: Transition not animating

**Cause:** Insertion/removal not in same view hierarchy

```swift
// ❌ WRONG
if showView {
    Text("Hello")
        .transition(.opacity)  // Won't animate
}

// ✅ CORRECT
Group {
    if showView {
        Text("Hello")
            .transition(.opacity)  // Will animate
    } else {
        EmptyView()
    }
}
```

---

## List Issues

### Problem: List items not updating

**Cause:** Missing Identifiable or wrong id

```swift
// ❌ WRONG
struct Item {  // Not Identifiable
    let name: String
}

List(items, id: \.name) { item in  // Using non-unique id
    Text(item.name)
}

// ✅ CORRECT
struct Item: Identifiable {
    let id = UUID()
    let name: String
}

List(items) { item in  // Uses id from Identifiable
    Text(item.name)
}
```

---

### Problem: Swipe to delete not working

**Cause:** Missing onDelete modifier implementation

```swift
// ❌ WRONG
List(items) { item in
    Text(item.name)
}
// No .onDelete

// ✅ CORRECT
List(items) { item in
    Text(item.name)
}
.onDelete { indexSet in
    items.remove(atOffsets: indexSet)
}
```

---

### Problem: NavigationLink not navigating

**Cause:** NavigationLink not in NavigationStack

```swift
// ❌ WRONG
NavigationView {  // Old API
    List {
        NavigationLink("Detail", destination: DetailView())
    }
}

// ✅ CORRECT (iOS 16+)
NavigationStack {
    List {
        NavigationLink("Detail", destination: DetailView())
    }
}

// ✅ CORRECT (iOS 13-15)
NavigationView {
    List {
        NavigationLink("Detail", destination: DetailView())
    }
}
```

---

## Performance Issues

### Problem: Slow list scrolling

**Cause:** Expensive work in body or row creation

```swift
// ❌ WRONG
struct RowView: View {
    let item: Item
    
    var body: some View {
        // Expensive computation on every render
        let processed = item.data.map { expensiveTransform($0) }
        Text(processed.description)
    }
}

// ✅ CORRECT
struct RowView: View {
    let item: Item
    
    private var processed: String {
        item.data.map { expensiveTransform($0) }.description
    }
    
    var body: some View {
        Text(processed)
    }
}
```

---

### Problem: Images causing memory issues

**Cause:** Loading large images without resizing

```swift
// ❌ WRONG
Image(uiImage: largeImage)  // Full resolution

// ✅ CORRECT
Image(uiImage: largeImage)
    .resizable()
    .aspectRatio(contentMode: .fill)
    .frame(width: 100, height: 100)
    .clipped()
```

---

## Async/await Issues

### Problem: UI updates on background thread

**Cause:** Not using @MainActor or MainActor.run

```swift
// ❌ WRONG
@MainActor
class ViewModel: ObservableObject {
    @Published var data: String = ""
    
    func fetchData() async {
        let result = await apiCall()
        data = result  // May be on background thread
    }
}

// ✅ CORRECT
@MainActor
class ViewModel: ObservableObject {
    @Published var data: String = ""
    
    func fetchData() async {
        let result = await apiCall()
        await MainActor.run {
            data = result  // Guaranteed main thread
        }
    }
}
```

---

### Problem: Task not cancelled

**Cause:** Not checking cancellation or using weak self

```swift
// ❌ WRONG
Task {
    let result = await fetchData()
    self.data = result  // May run after view dismissed
}

// ✅ CORRECT
Task {
    let result = await fetchData()
    guard !Task.isCancelled else { return }
    await MainActor.run {
        self.data = result
    }
}

// Or use weak self
Task { [weak self] in
    let result = await fetchData()
    await MainActor.run {
        self?.data = result
    }
}
```

---

## Common Error Messages

### "Value of type X has no member Y"

**Cause:** Type mismatch or missing import

```swift
// Check:
// 1. Import SwiftUI
// 2. Correct type for property wrapper
// 3. Accessing @Published property correctly
```

---

### "Cannot convert value of type X to expected argument type Y"

**Cause:** Usually binding vs value issue

```swift
// Check if you need $ for binding
TextField("Name", text: $name)  // $ for Binding<String>
```

---

### "Extra argument in call"

**Cause:** Wrong closure syntax or missing @escaping

```swift
// Check closure syntax
Button(action: {
    // action
}) {
    // label
}
```

---

### "Accessing state from background thread"

**Cause:** @State accessed off main thread

```swift
// Fix: Ensure main thread access
@MainActor
func updateState() {
    state = newValue  // Safe
}
```

---

## Debugging Tips

### 1. Use .onAppear for debugging

```swift
Text("Debug")
    .onAppear {
        print("View appeared")
    }
```

---

### 2. Track state changes

```swift
struct DebugView: View {
    @State private var count = 0
    
    var body: some View {
        Text("Count: \(count)")
            .onChange(of: count) { newValue in
                print("Count changed to: \(newValue)")
            }
    }
}
```

---

### 3. Use SwiftUI View Debugger

In Xcode:
1. Run app
2. Debug → View Debugging → Capture View Hierarchy
3. Inspect view tree

---

### 4. Check for retain cycles

```swift
// Look for:
closure = { [self] in  // Strong capture
    // May cause cycle
}

// Fix:
closure = { [weak self] in
    self?.doSomething()
}
```

---

## Quick Fixes Reference

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| View doesn't update | Missing @State | Add @State property wrapper |
| ViewModel resets | @ObservedObject | Change to @StateObject |
| Can't modify in child | Value not binding | Use @Binding |
| Crash: no environment object | Missing injection | Add .environmentObject() |
| Animation instant | Missing withAnimation | Wrap in withAnimation {} |
| List doesn't update | Not Identifiable | Conform to Identifiable |
| Scroll not working | No size constraints | Add frame to content |
| Memory growing | Not cancelling Task | Check Task.isCancelled |
| UI updates late | Background thread | Use @MainActor |

---

## Getting Help

1. **Xcode Previews** - Often shows errors before running
2. **Console logs** - Check for warnings
3. **SwiftUI documentation** - Apple's docs are comprehensive
4. **WWDC videos** - Search for specific topics
5. **Stack Overflow** - Common issues well documented
