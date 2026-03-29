# SwiftUI Advanced Patterns

Deep dive into advanced SwiftUI techniques for senior-level interviews.

---

## Table of Contents

1. [Custom ViewModifiers](#custom-viewmodifiers)
2. [Environment & Preferences](#environment--preferences)
3. [Custom Layout](#custom-layout)
4. [Advanced Animations](#advanced-animations)
5. [Performance Optimization](#performance-optimization)
6. [Interop with UIKit](#interop-with-uikit)
7. [Testing SwiftUI](#testing-swiftui)
8. [Architecture Patterns](#architecture-patterns)

---

## Custom ViewModifiers

### Creating Reusable Modifiers

```swift
// Basic modifier
struct CardStyle: ViewModifier {
    var shadowColor: Color = .black
    var shadowRadius: CGFloat = 4
    
    func body(content: Content) -> some View {
        content
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 2)
            .padding(.horizontal, 16)
    }
}

// Extension for easy use
extension View {
    func cardStyle(shadowColor: Color = .black, shadowRadius: CGFloat = 4) -> some View {
        modifier(CardStyle(shadowColor: shadowColor, shadowRadius: shadowRadius))
    }
}

// Usage
Text("Hello")
    .cardStyle()
```

### Conditional Modifiers

```swift
struct ConditionalPadding: ViewModifier {
    let shouldPad: Bool
    let amount: CGFloat
    
    func body(content: Content) -> some View {
        if shouldPad {
            content.padding(amount)
        } else {
            content
        }
    }
}

// Or using @ViewBuilder
struct HighlightModifier: ViewModifier {
    let isHighlighted: Bool
    
    func body(content: Content) -> some View {
        content
            .background(isHighlighted ? Color.yellow : Color.clear)
            .fontWeight(isHighlighted ? .bold : .regular)
    }
}
```

### Modifier Composition

```swift
struct PrimaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.blue)
            .cornerRadius(8)
            .shadow(radius: 4)
    }
}

// Combine modifiers
Text("Submit")
    .modifier(PrimaryButtonStyle())
    .scaleEffect(isPressed ? 0.95 : 1.0)
    .animation(.spring(), value: isPressed)
```

---

## Environment & Preferences

### Custom Environment Values

```swift
// 1. Define the key
struct IsLoadingKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

// 2. Extend EnvironmentValues
extension EnvironmentValues {
    var isLoading: Bool {
        get { self[IsLoadingKey.self] }
        set { self[IsLoadingKey.self] = newValue }
    }
}

// 3. Inject value
ContentView()
    .environment(\.isLoading, true)

// 4. Read value
struct MyView: View {
    @Environment(\.isLoading) var isLoading
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else {
                Content()
            }
        }
    }
}
```

### EnvironmentObject for Dependency Injection

```swift
// Service locator pattern
class Services: ObservableObject {
    let apiClient: APIClient
    let imageCache: ImageCache
    
    init() {
        self.apiClient = APIClient()
        self.imageCache = ImageCache()
    }
}

// Inject at app level
@main
struct MyApp: App {
    @StateObject private var services = Services()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(services)
        }
    }
}

// Access in views
struct ContentView: View {
    @EnvironmentObject var services: Services
    
    var body: some View {
        List {
            ForEach(items) { item in
                ItemRow(item: item)
            }
        }
        .task {
            await services.apiClient.fetchItems()
        }
    }
}
```

### PreferenceKey for Child-to-Parent Communication

```swift
// Define preference
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
                        .preference(key: HeaderHeightKey.self, value: geo.size.height)
                }
            )
    }
}

// Parent reads preference
struct ParentView: View {
    @State private var headerHeight: CGFloat = 0
    
    var body: some View {
        VStack {
            HeaderView()
            Content()
        }
        .onPreferenceChange(HeaderHeightKey.self) { newHeight in
            headerHeight = newHeight
        }
    }
}
```

---

## Custom Layout

### LayoutProtocol (iOS 16+)

```swift
struct FlexLayout: Layout {
    var spacing: CGFloat = 8
    var alignment: HorizontalAlignment = .leading
    
    func sizeThatFits(proposal: ProposedViewSize, 
                      subviews: Subviews, 
                      cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var currentX: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > width && currentX > 0 {
                // New row
                currentX = 0
                height += currentRowHeight + spacing
                currentRowHeight = 0
            }
            
            currentRowHeight = max(currentRowHeight, size.height)
            currentX += size.width + spacing
        }
        
        height += currentRowHeight
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, 
                       proposal: ProposedViewSize, 
                       subviews: Subviews, 
                       cache: inout ()) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var currentRowHeight: CGFloat = 0
        let width = bounds.width
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > width + bounds.minX && currentX > bounds.minX {
                currentX = bounds.minX
                currentY += currentRowHeight + spacing
                currentRowHeight = 0
            }
            
            subview.place(at: CGPoint(x: currentX, y: currentY), 
                         proposal: .unspecified)
            
            currentRowHeight = max(currentRowHeight, size.height)
            currentX += size.width + spacing
        }
    }
}

// Usage
FlexLayout(spacing: 12) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}
```

### GeometryReader for Custom Layouts

```swift
struct ResponsiveGrid: View {
    var items: [Item]
    
    var body: some View {
        GeometryReader { geometry in
            let columns = calculateColumns(for: geometry.size.width)
            let itemWidth = (geometry.size.width - (columns - 1) * 8) / columns
            
            ForEach(items) { item in
                let index = items.firstIndex(where: { $0.id == item.id }) ?? 0
                let column = index % columns
                let row = index / columns
                
                ItemView(item: item)
                    .frame(width: itemWidth)
                    .position(
                        x: CGFloat(column) * (itemWidth + 8) + itemWidth / 2,
                        y: CGFloat(row) * (itemWidth + 8) + itemWidth / 2
                    )
            }
        }
    }
    
    private func calculateColumns(for width: CGFloat) -> Int {
        let itemWidth: CGFloat = 100
        return max(1, Int(width / itemWidth))
    }
}
```

---

## Advanced Animations

### Matched Geometry Effect

```swift
struct HeroAnimation: View {
    @Namespace var namespace
    @State var isExpanded = false
    
    var body: some View {
        VStack {
            if isExpanded {
                Image("photo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 300)
                    .matchedGeometryEffect(id: "photo", in: namespace)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isExpanded = false
                        }
                    }
            } else {
                Image("photo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .matchedGeometryEffect(id: "photo", in: namespace)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isExpanded = true
                        }
                    }
            }
        }
    }
}
```

### Custom Animations

```swift
// Spring with custom parameters
withAnimation(.spring(
    response: 0.5,
    dampingFraction: 0.6,
    blendDuration: 0.5
)) {
    scale = 1.2
}

// Interpolating spring for physics
withAnimation(.interpolatingSpring(
    stiffness: 170,
    damping: 15
)) {
    offset = CGSize(width: 100, height: 0)
}

// Custom timing curve
Animation.timingCurve(
    0.68, -0.55, 0.265, 1.55,
    duration: 0.4
)
```

### Transaction for Fine Control

```swift
struct CustomTransaction: View {
    @State var count = 0
    
    var body: some View {
        Text(count.description)
            .transaction { transaction in
                transaction.animation = .easeInOut(duration: 0.3)
                transaction.disablesAnimations = false
                transaction.responder = UIImpactFeedbackGenerator(style: .medium)
            }
            .onTapGesture {
                count += 1
            }
    }
}
```

### Phase Animator (iOS 17+)

```swift
@available(iOS 17.0, *)
struct PulsingDot: View {
    var body: some View {
        PhaseAnimator([false, true]) { isExpanded in
            Circle()
                .fill(isExpanded ? Color.blue : Color.green)
                .scaleEffect(isExpanded ? 1.5 : 1.0)
        } animation: { phase in
            .easeInOut(duration: 0.5)
        }
    }
}
```

---

## Performance Optimization

### Avoiding Unnecessary Recomputations

```swift
// ❌ Expensive work in body
var body: some View {
    let sorted = items
        .filter { $0.isActive }
        .sorted { $0.name < $1.name }
        .map { Transform($0) }
    
    return List(sorted) { item in
        Text(item.name)
    }
}

// ✅ Computed property (cached)
private var sortedItems: [Item] {
    items
        .filter { $0.isActive }
        .sorted { $0.name < $1.name }
        .map { Transform($0) }
}

var body: some View {
    List(sortedItems) { item in
        Text(item.name)
    }
}

// ✅ Even better: @State for derived state
struct OptimizedView: View {
    @State private var processedItems: [Item] = []
    
    var body: some View {
        List(processedItems) { item in
            Text(item.name)
        }
        .task(id: items) {
            processedItems = process(items)
        }
    }
}
```

### EquatableView for Conditional Updates

```swift
struct ExpensiveRow: View, Equatable {
    let item: Item
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.item.id == rhs.item.id && 
        lhs.item.name == rhs.item.name
    }
    
    var body: some View {
        // Expensive rendering
    }
}

// Usage
List {
    ForEach(items) { item in
        ExpensiveRow(item: item)
    }
}
```

### Lazy Loading

```swift
// Use LazyVStack for long lists
ScrollView {
    LazyVStack(spacing: 16) {
        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
    .padding()
}

// For grids
LazyVGrid(columns: [
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible())
]) {
    ForEach(items) { item in
        ItemCard(item: item)
    }
}
```

### DrawingGroup for Complex Views

```swift
// Rasterize complex view hierarchies
struct ComplexGraphic: View {
    var body: some View {
        VStack {
            // Many overlapping shapes
            ForEach(0..<50) { i in
                Circle()
                    .fill(Color.random)
                    .frame(width: 20, height: 20)
                    .offset(x: CGFloat(i) * 5)
            }
        }
        .drawingGroup()  // Renders as single texture
    }
}
```

---

## Interop with UIKit

### UIViewRepresentable

```swift
struct MapView: UIViewRepresentable {
    let centerCoordinate: CLLocationCoordinate2D
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setCenter(centerCoordinate, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, 
                     viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // Custom annotation view
            return nil
        }
    }
}
```

### UIViewControllerRepresentable

```swift
struct WebView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> WKViewController {
        WKViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: WKViewController, 
                                context: Context) {
        uiViewController.load(url: url)
    }
}

class WKViewController: UIViewController {
    private var webView: WKWebView!
    private let url: URL
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView(frame: view.bounds)
        view.addSubview(webView)
        load(url: url)
    }
    
    func load(url: URL) {
        webView.load(URLRequest(url: url))
    }
}
```

### Handling UIKit Delegate Patterns

```swift
struct TextFieldRepresentable: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.delegate = context.coordinator
        return textField
    }
    
    func updateUIView(_ uiTextField: UITextField, context: Context) {
        if uiTextField.text != text {
            uiTextField.text = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: TextFieldRepresentable
        
        init(_ parent: TextFieldRepresentable) {
            self.parent = parent
        }
        
        func textField(_ textField: UITextField, 
                      shouldChangeCharactersIn range: NSRange, 
                      replacementString string: String) -> Bool {
            return true
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
    }
}
```

---

## Testing SwiftUI

### ViewInspector (Third-party)

```swift
import ViewInspector
import XCTest

struct ContentViewTests: XCTestCase {
    func test_titleDisplaysCorrectly() throws {
        let view = ContentView(title: "Test")
        let text = try view.inspect().find(text: "Test")
        XCTAssertEqual(try text.string(), "Test")
    }
    
    func test_buttonExists() throws {
        let view = ContentView()
        let button = try view.inspect().find(view: Button<Self>.self)
        XCTAssertNotNil(button)
    }
}
```

### Snapshot Testing

```swift
import SnapshotTesting
import XCTest

final class SnapshotTests: XCTestCase {
    func test_homeView() {
        let view = HomeView(viewModel: HomeViewModel())
            .frame(width: 375, height: 667)
        
        assertSnapshot(matching: view, as: .image)
    }
    
    func test_darkMode() {
        let view = HomeView(viewModel: HomeViewModel())
            .frame(width: 375, height: 667)
            .environment(\.colorScheme, .dark)
        
        assertSnapshot(matching: view, as: .image)
    }
}
```

### UITesting

```swift
import XCTest

final class AppUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        app = XCUIApplication()
        app.launch()
    }
    
    func test_navigationFlow() {
        app.buttons["View Details"].tap()
        XCTAssertTrue(app.staticTexts["Detail View"].exists)
        
        app.navigationButtons["Back"].tap()
        XCTAssertTrue(app.staticTexts["Home"].exists)
    }
    
    func test_formSubmission() {
        app.textFields["name"].tap()
        app.textFields["name"].typeText("John")
        
        app.buttons["Submit"].tap()
        
        XCTAssertTrue(app.alerts["Success"].exists)
    }
}
```

---

## Architecture Patterns

### MVVM + Clean Architecture

```swift
// Domain Layer
protocol UserRepository {
    func getUser(id: String) async throws -> User
}

class GetUser {
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func execute(id: String) async throws -> User {
        try await repository.getUser(id: id)
    }
}

// Data Layer
class UserRepositoryImpl: UserRepository {
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func getUser(id: String) async throws -> User {
        try await apiClient.get("/users/\(id)")
    }
}

// Presentation Layer (ViewModel)
@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let getUser: GetUser
    
    init(getUser: GetUser) {
        self.getUser = getUser
    }
    
    func loadUser(id: String) async {
        isLoading = true
        do {
            user = try await getUser.execute(id: id)
        } catch {
            self.error = error
        }
        isLoading = false
    }
}

// View
struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    let userId: String
    
    init(userId: String, viewModel: ProfileViewModel) {
        self.userId = userId
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let user = viewModel.user {
                UserCard(user: user)
            }
        }
        .task {
            await viewModel.loadUser(id: userId)
        }
    }
}
```

### Component-Based Architecture

```swift
// Reusable components
struct Button: View {
    let title: String
    let action: () -> Void
    var variant: ButtonVariant = .primary
    
    enum ButtonVariant {
        case primary, secondary, danger
    }
    
    var body: some View {
        SwiftUI.Button(action: action) {
            Text(title)
                .font(.headline)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(backgroundForVariant)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
    
    private var backgroundForVariant: Color {
        switch variant {
        case .primary: return .blue
        case .secondary: return .gray
        case .danger: return .red
        }
    }
}

// Usage
Button(title: "Submit", action: submit)
Button(title: "Cancel", action: cancel, variant: .secondary)
```

---

## Interview Questions

### Q: How does SwiftUI's state management work?

**A:** SwiftUI uses property wrappers to manage state:
- `@State` for local value-type state
- `@Binding` for two-way connections
- `@StateObject` for owned reference-type state
- `@ObservedObject` for borrowed reference-type state
- `@EnvironmentObject` for dependency injection across hierarchy

The key insight is that SwiftUI views are value types that get recreated frequently. State is stored outside the view struct, and changes trigger view recomputation.

### Q: What's the difference between @StateObject and @ObservedObject?

**A:** Both work with ObservableObject, but:
- `@StateObject` creates and owns the object lifecycle
- `@ObservedObject` borrows a reference without owning it

Using `@ObservedObject` for owned objects causes recreation on every render, losing state.

### Q: How do you optimize SwiftUI performance?

**A:** Key strategies:
1. Move expensive computations out of `body`
2. Use `LazyVStack`/`LazyVGrid` for long lists
3. Apply `EquatableView` to prevent unnecessary updates
4. Use `@State` at the lowest level needed
5. Extract subviews to limit redraw scope
6. Use `.drawingGroup()` for complex graphics
7. Profile with Instruments (Time Profiler, Core Animation)

### Q: Explain the SwiftUI render cycle

**A:** 
1. State changes (via @State, @Published, etc.)
2. SwiftUI marks affected views as dirty
3. View structs are recreated (body is called)
4. Diffing algorithm compares new vs old view hierarchy
5. Only changed RenderObjects are updated
6. Display refreshes

Key insight: Views are cheap structs; Elements and RenderObjects are expensive and preserved across updates.

---

## Additional Resources

- [Apple's SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [WWDC SwiftUI Sessions](https://developer.apple.com/videos/swiftui)
- [SwiftUI Lab](https://swiftui-lab.com/)
- [Hacking with Swift](https://www.hackingwithswift.com/swiftui)
