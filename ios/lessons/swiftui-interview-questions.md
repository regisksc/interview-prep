# SwiftUI Interview Questions

Comprehensive questions from basics to advanced.

---

## Beginner Questions

### Q1: What is SwiftUI?

**A:** SwiftUI is Apple's declarative framework for building user interfaces across all Apple platforms. Instead of imperatively creating and configuring UI elements, you describe what the UI should look like for a given state, and SwiftUI handles the rendering.

**Key concepts:**
- Declarative syntax
- State-driven UI
- Cross-platform (iOS, macOS, watchOS, tvOS)
- Live previews in Xcode

---

### Q2: What's the difference between SwiftUI and UIKit?

| SwiftUI | UIKit |
|---------|-------|
| Declarative | Imperative |
| State-driven | Manual updates |
| Automatic animations | Manual animation code |
| Cross-platform by default | iOS-focused |
| iOS 13+ | All iOS versions |
| Less boilerplate | More verbose |

---

### Q3: Explain @State

**A:** @State is a property wrapper for local view state in SwiftUI. It stores value types outside the view struct, allowing the view to persist values across renders. When @State changes, SwiftUI automatically recomputes the view body.

```swift
struct CounterView: View {
    @State private var count = 0
    
    var body: some View {
        Text("Count: \(count)")
            .onTapGesture { count += 1 }  // Triggers redraw
    }
}
```

**Key points:**
- Only use in struct views
- For value types (Int, String, Bool)
- SwiftUI manages storage
- Triggers view updates on change

---

### Q4: What is @Binding?

**A:** @Binding creates a two-way connection between a child view and its parent's state. It doesn't store data itself but references a @State value from a parent, allowing the child to read and modify it.

```swift
struct ParentView: View {
    @State private var text = ""
    
    var body: some View {
        ChildView(text: $text)  // $ passes binding
    }
}

struct ChildView: View {
    @Binding var text: String  // Can modify parent's state
    
    var body: some View {
        TextField("Enter", text: $text)
    }
}
```

---

### Q5: When do you use @StateObject vs @ObservedObject?

**A:** Both work with ObservableObject, but differ in ownership:

- **@StateObject**: You create and own the object's lifecycle. SwiftUI creates it once and keeps it alive while the view exists.
- **@ObservedObject**: You borrow a reference. Someone else owns the lifecycle.

```swift
// Owner - creates the ViewModel
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        DetailView(viewModel: viewModel)  // Pass to child
    }
}

// Borrower - receives the ViewModel
struct DetailView: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        Text(viewModel.name)
    }
}
```

**Common mistake:** Using @ObservedObject with inline initialization causes recreation on every render, losing state.

---

### Q6: What is @EnvironmentObject?

**A:** @EnvironmentObject is a dependency injection mechanism that allows you to share data across the entire view hierarchy without passing it through every level.

```swift
// Inject at top
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

// Access anywhere
struct AnyView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Text(appState.username)
    }
}
```

**Warning:** Missing environment objects cause runtime crashes.

---

### Q7: What are the basic layout containers?

**A:**
- **VStack** - Vertical arrangement
- **HStack** - Horizontal arrangement
- **ZStack** - Layered (depth) arrangement
- **ScrollView** - Scrollable content
- **LazyVStack/LazyVGrid** - Lazy-loading containers

```swift
VStack {
    Text("Top")
    Text("Bottom")
}

HStack {
    Text("Left")
    Text("Right")
}

ZStack {
    Color.blue  // Back
    Text("Front")  // Front
}
```

---

### Q8: How do you handle user input?

**A:** Common patterns:

```swift
// Button
Button("Tap me") {
    // Action
}

// TextField
@State private var text = ""
TextField("Placeholder", text: $text)

// Toggle
@State private var isOn = false
Toggle("Enable", isOn: $isOn)

// Picker
@State private var selection = 0
Picker("Option", selection: $selection) {
    Text("Option 1").tag(0)
    Text("Option 2").tag(1)
}

// Gesture
Text("Swipe me")
    .onTapGesture { }
    .onLongPressGesture { }
    .gesture(DragGesture().onChanged { })
```

---

## Intermediate Questions

### Q9: Explain the SwiftUI view lifecycle

**A:** SwiftUI views are value types (structs) that get recreated frequently:

1. **Initial render** - View struct created, body computed
2. **State change** - @State/@Published change triggers recomputation
3. **Reconciliation** - SwiftUI diffs old vs new view hierarchy
4. **Update** - Only changed RenderObjects updated

**Key insight:** Views are cheap configs. Elements and RenderObjects are expensive and preserved.

```swift
struct MyView: View {
    @State private var count = 0
    
    var body: some View {
        // This runs every time count changes
        Text("Count: \(count)")
    }
}
```

---

### Q10: How does SwiftUI detect state changes?

**A:** Different mechanisms for different property wrappers:

- **@State**: SwiftUI monitors the stored value
- **@Published**: ObservableObject sends objectWillChange before changes
- **@Environment**: System notifications
- **@EnvironmentObject**: Same as @Published + environment propagation

```swift
class ViewModel: ObservableObject {
    @Published var data: String = "" {
        willSet {
            objectWillChange.send()  // Automatic with @Published
        }
    }
}
```

---

### Q11: What's the difference between .task and .onAppear?

**A:**

| .onAppear | .task |
|-----------|-------|
| iOS 13+ | iOS 15+ |
| Fires on appear | Fires on appear |
| No async support | Supports async/await |
| Fire-and-forget | Auto-cancels on disappear |
| Manual cleanup | Automatic cancellation |

```swift
// Old way
.onAppear {
    Task {
        await loadData()
    }
}

// New way
.task {
    await loadData()  // Auto-cancels on disappear
}
```

---

### Q12: How do you make API calls in SwiftUI?

**A:** Common patterns:

```swift
// In ViewModel
@MainActor
class ViewModel: ObservableObject {
    @Published var data: String?
    @Published var isLoading = false
    
    func loadData() async {
        isLoading = true
        do {
            data = try await apiClient.fetch()
        } catch {
            // Handle error
        }
        isLoading = false
    }
}

// In View
struct MyView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else {
                Text(viewModel.data ?? "No data")
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
}
```

---

### Q13: Explain .onChange modifier

**A:** .onChange executes code when a specific value changes.

```swift
struct MyView: View {
    @State private var count = 0
    
    var body: some View {
        Text(count.description)
            .onChange(of: count) { newValue in
                print("Count changed to: \(newValue)")
            }
            // iOS 17+ with old value
            .onChange(of: count) { oldValue, newValue in
                print("Changed from \(oldValue) to \(newValue)")
            }
    }
}
```

**Use cases:**
- Side effects on state change
- Validation
- Analytics tracking
- Derived state updates

---

### Q14: How do you create custom view modifiers?

**A:**

```swift
// Define modifier
struct CardStyle: ViewModifier {
    var shadowColor: Color = .black
    
    func body(content: Content) -> some View {
        content
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: shadowColor, radius: 4)
            .padding(16)
    }
}

// Extension for easy use
extension View {
    func cardStyle(shadowColor: Color = .black) -> some View {
        modifier(CardStyle(shadowColor: shadowColor))
    }
}

// Usage
Text("Hello")
    .cardStyle()
```

---

### Q15: What is @AppStorage?

**A:** @AppStorage is a property wrapper that persists simple values to UserDefaults and automatically updates the view when the value changes.

```swift
struct SettingsView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("username") private var username: String = ""
    
    var body: some View {
        VStack {
            Toggle("Seen Onboarding", isOn: $hasSeenOnboarding)
            TextField("Username", text: $username)
        }
    }
}
```

**Limitations:**
- Only property list types (String, Int, Bool, Data, URL)
- Not for complex objects
- Limited storage (~100KB recommended)

---

### Q16: How do you handle navigation in SwiftUI?

**A:** iOS 16+ uses NavigationStack:

```swift
NavigationStack {
    List(items) { item in
        NavigationLink(item.name, destination: DetailView(item: item))
    }
    .navigationTitle("Items")
}

// Programmatic navigation
struct MyView: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            Button("Go to Detail") {
                path.append(itemId)
            }
            .navigationDestination(for: String.self) { id in
                DetailView(id: id)
            }
        }
    }
}
```

---

### Q17: Explain animation in SwiftUI

**A:** Two types of animations:

**Implicit:**
```swift
Text("Hello")
    .scaleEffect(isSelected ? 1.2 : 1.0)
    .animation(.easeInOut, value: isSelected)
```

**Explicit:**
```swift
withAnimation(.spring()) {
    scale = 1.2
}
```

**Animation types:**
- `.easeInOut` - Default, smooth
- `.spring` - Bouncy
- `.linear` - Constant speed
- `.interactiveSpring` - For gestures

---

### Q18: How do you create a custom view?

**A:**

```swift
struct CustomButton: View {
    let title: String
    let action: () -> Void
    var color: Color = .blue
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(color)
                .cornerRadius(8)
        }
    }
}

// Usage
CustomButton(title: "Submit", action: submit)
```

---

## Advanced Questions

### Q19: Explain SwiftUI's render pipeline

**A:** SwiftUI maintains three trees:

1. **View Tree** - Your SwiftUI view structs (cheap, recreated often)
2. **Element Tree** - Persistent identity (preserved across updates)
3. **RenderObject Tree** - Actual rendering (expensive, updated minimally)

**Process:**
```
State Change
    ↓
View Rebuild (body computed)
    ↓
Element Diffing (compare old vs new)
    ↓
RenderObject Update (minimal changes)
    ↓
Display Refresh
```

**Optimization:** Keep views small, extract subviews to limit redraw scope.

---

### Q20: How do you optimize SwiftUI performance?

**A:** Key strategies:

1. **Move computations out of body:**
```swift
private var processedItems: [Item] {
    items.filter { $0.isActive }.sorted { $0.name < $1.name }
}
```

2. **Use lazy containers:**
```swift
ScrollView {
    LazyVStack { /* 1000 items */ }
}
```

3. **Use EquatableView:**
```swift
struct RowView: View, Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.item.id == rhs.item.id
    }
}
```

4. **Use @State at lowest level:**
```swift
// Extract state to child, not parent
```

5. **Profile with Instruments:**
- Time Profiler
- Core Animation
- Allocations

---

### Q21: What are PreferenceKeys?

**A:** PreferenceKeys allow child-to-parent communication in SwiftUI.

```swift
// Define key
struct HeaderHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// Child sets preference
struct HeaderView: View {
    var body: some View {
        Text("Header")
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(key: HeaderHeightKey.self, 
                                   value: geo.size.height)
                }
            )
    }
}

// Parent reads
struct ParentView: View {
    @State private var height: CGFloat = 0
    
    var body: some View {
        VStack {
            HeaderView()
            Content()
        }
        .onPreferenceChange(HeaderHeightKey.self) { newHeight in
            height = newHeight
        }
    }
}
```

---

### Q22: How do you integrate UIKit views?

**A:** Use UIViewRepresentable:

```swift
struct MapView: UIViewRepresentable {
    let coordinate: CLLocationCoordinate2D
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setCenter(coordinate, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        init(_ parent: MapView) { self.parent = parent }
    }
}
```

---

### Q23: Explain @MainActor

**A:** @MainActor ensures code runs on the main thread, critical for UI updates.

```swift
@MainActor
class ViewModel: ObservableObject {
    @Published var data: String = ""
    
    func fetchData() async {
        let result = await apiCall()  // Background thread
        await MainActor.run {
            data = result  // Main thread
        }
    }
}
```

**Why it matters:** UIKit and SwiftUI require main thread for UI operations. @MainActor provides compile-time safety.

---

### Q24: How do you test SwiftUI views?

**A:** Several approaches:

**1. ViewInspector (third-party):**
```swift
func test_title() throws {
    let view = ContentView(title: "Test")
    let text = try view.inspect().find(text: "Test")
    XCTAssertEqual(try text.string(), "Test")
}
```

**2. Snapshot Testing:**
```swift
func test_snapshot() {
    let view = ContentView()
    assertSnapshot(matching: view, as: .image)
}
```

**3. UI Testing:**
```swift
func test_navigation() {
    app.buttons["Details"].tap()
    XCTAssertTrue(app.staticTexts["Detail View"].exists)
}
```

---

### Q25: What is the difference between @State and StateObject?

**A:**

| @State | @StateObject |
|--------|--------------|
| Value types (structs) | Reference types (classes) |
| Simple storage | ObservableObject lifecycle |
| Local view state | Complex state with logic |
| No methods | Can have methods |
| Copied on assignment | Shared reference |

```swift
// @State for simple
@State private var count = 0

// @StateObject for complex
@StateObject private var viewModel = ViewModel()
```

---

### Q26: How do you handle errors in SwiftUI?

**A:** Multiple approaches:

```swift
// In ViewModel
@MainActor
class ViewModel: ObservableObject {
    @Published var error: Error?
    @Published var data: String?
    
    func loadData() async {
        do {
            data = try await apiCall()
            error = nil
        } catch {
            self.error = error
        }
    }
}

// In View
struct MyView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        Group {
            if let error = viewModel.error {
                ErrorView(error: error, retry: viewModel.loadData)
            } else {
                Content(data: viewModel.data)
            }
        }
    }
}
```

---

### Q27: Explain Combine integration with SwiftUI

**A:** Combine publishers integrate with SwiftUI:

```swift
class ViewModel: ObservableObject {
    @Published var query = ""
    @Published var results: [String] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $query
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap { query in
                self.search(query)
            }
            .assign(to: &$results)
    }
}
```

**Integration points:**
- @Published → SwiftUI auto-updates
- .assign(to:) → @Published properties
- .sink → Manual handling
- Future → async/await alternative

---

### Q28: How do you create custom layouts?

**A:** iOS 16+ Layout protocol:

```swift
struct FlexLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, 
                      subviews: Subviews, 
                      cache: inout ()) -> CGSize {
        // Calculate size
    }
    
    func placeSubviews(in bounds: CGRect, 
                       proposal: ProposedViewSize, 
                       subviews: Subviews, 
                       cache: inout ()) {
        // Position subviews
    }
}

// Usage
FlexLayout {
    ForEach(items) { item in
        ItemView(item: item)
    }
}
```

---

### Q29: What are some common SwiftUI anti-patterns?

**A:**

1. ** Massive view bodies:**
```swift
// ❌ Too much in body
var body: some View {
    // 200 lines of UI
}

// ✅ Extract subviews
var body: some View {
    HeaderView()
    ContentSection()
    FooterView()
}
```

2. **State at wrong level:**
```swift
// ❌ Parent owns all state
struct ParentView: View {
    @State private var text1 = ""
    @State private var text2 = ""
    @State private var text3 = ""
}

// ✅ State in relevant child
struct TextFieldView: View {
    @State private var text = ""
}
```

3. **Work in body:**
```swift
// ❌ Expensive in body
var body: some View {
    let sorted = items.sorted { ... }
}

// ✅ Computed property
private var sortedItems: [Item] {
    items.sorted { ... }
}
```

---

### Q30: How would you architect a large SwiftUI app?

**A:** Recommended approach:

```
// Clean Architecture + MVVM

// Domain Layer
protocol UserRepository {
    func getUser(id: String) async throws -> User
}

// Data Layer
class UserRepositoryImpl: UserRepository {
    // Implementation
}

// Presentation Layer
@MainActor
class UserViewModel: ObservableObject {
    private let repository: UserRepository
    
    @Published var user: User?
    @Published var isLoading = false
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func load(id: String) async {
        isLoading = true
        user = try? await repository.getUser(id: id)
        isLoading = false
    }
}

// View Layer
struct UserView: View {
    @StateObject private var viewModel: UserViewModel
    
    init(userId: String, viewModel: UserViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        Task { await viewModel.load(id: userId) }
    }
    
    var body: some View {
        // UI
    }
}
```

**Key principles:**
- Dependency injection
- Protocol-oriented
- Testable ViewModels
- Separation of concerns

---

## Scenario Questions

### Q31: How would you implement a search feature with debounce?

**A:**

```swift
class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var results: [Item] = []
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $query
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { $0.count >= 2 }
            .flatMap { [weak self] query -> AnyPublisher<[Item], Never> in
                self?.search(query) ?? Just([]).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$results)
    }
    
    private func search(_ query: String) -> AnyPublisher<[Item], Never> {
        Future { promise in
            // API call
            promise(.success([]))
        }
        .catch { _ in Just([]) }
        .eraseToAnyPublisher()
    }
}
```

---

### Q32: How would you handle offline mode?

**A:**

```swift
class DataViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var isOnline = true
    
    private let repository: ItemRepository
    private let networkMonitor: NetworkMonitor
    
    init(repository: ItemRepository, networkMonitor: NetworkMonitor) {
        self.repository = repository
        self.networkMonitor = networkMonitor
        
        // Monitor connectivity
        networkMonitor.$isOnline
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isOnline in
                self?.isOnline = isOnline
                if isOnline {
                    self?.syncData()
                }
            }
            .store(in: &cancellables)
    }
    
    func loadData() async {
        if isOnline {
            items = try? await repository.fetchRemote()
            try? repository.cache(items)
        } else {
            items = try? repository.getCached()
        }
    }
}
```

---

### Q33: How would you implement pull-to-refresh?

**A:**

```swift
struct ItemList: View {
    @StateObject private var viewModel = ItemListViewModel()
    
    var body: some View {
        List(viewModel.items) { item in
            ItemRow(item: item)
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}

@MainActor
class ItemListViewModel: ObservableObject {
    @Published var items: [Item] = []
    
    func refresh() async {
        items = try? await repository.fetch()
    }
}
```

---

## Quick Reference

### Property Wrappers

| Wrapper | Use For | Type |
|---------|---------|------|
| @State | Local view state | Value |
| @Binding | Two-way connection | Value |
| @StateObject | Owned ViewModel | Reference |
| @ObservedObject | Borrowed ViewModel | Reference |
| @EnvironmentObject | Shared across hierarchy | Reference |
| @Environment | System values | Any |
| @AppStorage | UserDefaults persistence | Value |

### Common Patterns

```swift
// MVVM
View → ViewModel → Repository → API

// Navigation
NavigationStack + NavigationLink + navigationDestination

// API Loading
isLoading ? ProgressView() : Content()

// Error Handling
error != nil ? ErrorView() : Content()

// Empty State
items.isEmpty ? EmptyView() : List(items)
```

---

## Additional Resources

- [Apple's SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [WWDC SwiftUI Videos](https://developer.apple.com/videos/swiftui)
- [SwiftUI Lab](https://swiftui-lab.com/)
- [Hacking with Swift](https://www.hackingwithswift.com/swiftui)
