# SwiftUI State: Complete Guide

Understanding when to use each property wrapper is critical for building robust SwiftUI apps.

---

## Quick Decision Tree

```
Is the state local to ONE view and owned by that view?
  → @State

Do you need to MODIFY a parent's state from a child view?
  → @Binding

Is the state a CLASS (ObservableObject) that you OWN (create)?
  → @StateObject

Is the state a CLASS (ObservableObject) that someone ELSE owns?
  → @ObservedObject

Do you need to SHARE state across the entire view hierarchy?
  → @EnvironmentObject

Is the state a simple value you want persisted to UserDefaults?
  → @AppStorage

Do you need to READ system values (color scheme, locale, size category)?
  → @Environment
```

---

## @State — Local View Storage

**Use when:** A single view owns and modifies simple value-type state.

```swift
struct CounterView: View {
    @State private var count = 0
    @State private var isShowingAlert = false
    
    var body: some View {
        VStack {
            Text("Count: \(count)")
            
            Button("Increment") {
                count += 1
            }
            
            Button("Show Alert") {
                isShowingAlert = true
            }
            .alert("Hello", isPresented: $isShowingAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}
```

**Key points:**
- Only use in `struct View`
- Stores value types (Int, String, Bool, structs)
- SwiftUI manages the storage lifecycle
- Triggers view update when changed
- Never share @State between views

**Common mistakes:**

```swift
// ❌ WRONG: Using @State in a class
class MyViewModel {
    @State var count = 0  // Won't work!
}

// ❌ WRONG: Trying to share @State
struct ParentView: View {
    @State private var count = 0
    
    var body: some View {
        ChildView(count: count)  // Passes a copy, not the state
    }
}

// ✅ CORRECT: Use @Binding for child modification
struct ParentView: View {
    @State private var count = 0
    
    var body: some View {
        ChildView(count: $count)  // Passes binding
    }
}
```

---

## @Binding — Two-Way Connection

**Use when:** A child view needs to read AND modify parent's state.

```swift
// Parent owns the state
struct ParentView: View {
    @State private var count = 0
    
    var body: some View {
        VStack {
            Text("Parent count: \(count)")
            ChildView(count: $count)  // $ creates binding
        }
    }
}

// Child borrows the state
struct ChildView: View {
    @Binding var count: Int
    
    var body: some View {
        Button("Increment from child") {
            count += 1  // Modifies parent's state
        }
    }
}
```

**Creating bindings from @State:**

```swift
// Full binding
struct FormView: View {
    @State private var name = ""
    @State private var email = ""
    
    var body: some View {
        VStack {
            TextField("Name", text: $name)
            TextField("Email", text: $email)
            
            // Pass individual bindings to child
            SubmitButton(name: $name, email: $email)
        }
    }
}

// Binding to a property of @State struct
struct User {
    var name: String
    var email: String
}

struct FormView: View {
    @State private var user = User(name: "", email: "")
    
    var body: some View {
        VStack {
            // Binding to specific property
            TextField("Name", text: $user.name)
            TextField("Email", text: $user.email)
        }
    }
}
```

**Custom binding with get/set:**

```swift
struct SliderView: View {
    @State private var value = 50.0
    
    var body: some View {
        // Custom binding with transformation
        Slider(
            value: Binding(
                get: { value / 100.0 },
                set: { value = $0 * 100.0 }
            ),
            in: 0...1
        )
    }
}
```

---

## @StateObject — Owned ObservableObject

**Use when:** You create and own an ObservableObject's lifecycle.

```swift
class ProfileViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var isLoading = false
    
    func save() async {
        isLoading = true
        // Save logic
        isLoading = false
    }
}

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    //        ^^^^^^^^^^ You own this
    
    var body: some View {
        VStack {
            TextField("Name", text: $viewModel.name)
            TextField("Email", text: $viewModel.email)
            
            Button("Save") {
                Task {
                    await viewModel.save()
                }
            }
            .disabled(viewModel.isLoading)
        }
    }
}
```

**Key points:**
- Initialize inline or in init (not in body)
- SwiftUI creates once, keeps alive while view exists
- Use for ViewModels you own
- iOS 14+ (use @ObservedObject for iOS 13)

**Common mistakes:**

```swift
// ❌ WRONG: Creating in body (recreates on every render)
struct ProfileView: View {
    @ObservedObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        // viewModel gets recreated every time body runs!
    }
}

// ❌ WRONG: Using @StateObject for passed-in dependency
struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel  // Can't init here
    
    var body: some View { }
}

// ✅ CORRECT: @StateObject for owned, @ObservedObject for borrowed
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        DetailView(viewModel: viewModel)  // Pass to child
    }
}

struct DetailView: View {
    @ObservedObject var viewModel: ProfileViewModel  // Borrowed
    
    var body: some View { }
}
```

---

## @ObservedObject — Borrowed ObservableObject

**Use when:** An ObservableObject is created elsewhere and passed in.

```swift
struct ChildView: View {
    @ObservedObject var viewModel: ProfileViewModel
    //        ^^^^^^^^^^^^^^^^ Borrowed reference
    
    var body: some View {
        Text(viewModel.name)
    }
}

// Parent passes it
struct ParentView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        ChildView(viewModel: viewModel)
    }
}
```

**Key points:**
- Don't create the object — receive it
- View doesn't control lifecycle
- Common for dependency injection
- Same as @StateObject but without ownership

**When to use @ObservedObject vs @StateObject:**

| Scenario | Use |
|----------|-----|
| Creating ViewModel in this view | @StateObject |
| Receiving ViewModel as parameter | @ObservedObject |
| Receiving from environment | @EnvironmentObject |
| Creating in App struct | @StateObject |

---

## @EnvironmentObject — Shared Across Hierarchy

**Use when:** Multiple views across the hierarchy need the same data.

```swift
// Setup at app level
@main
struct MyApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var userSession = UserSession()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(userSession)
        }
    }
}

// Access anywhere in hierarchy
struct AnyNestedView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var userSession: UserSession
    
    var body: some View {
        Text("User: \(userSession.user?.name ?? "Guest")")
    }
}
```

**Key points:**
- Inject once at top of hierarchy
- Access from any descendant view
- No need to pass through intermediate views
- Missing object = runtime crash

**Common mistakes:**

```swift
// ❌ WRONG: Forgetting to add .environmentObject
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
            // Missing: .environmentObject(appState)
        }
    }
}
// Result: Runtime crash "No ObservableObject of type AppState found"

// ✅ CORRECT: Always add at injection point
WindowGroup {
    ContentView()
        .environmentObject(appState)
}
```

**When to use @EnvironmentObject vs passing @ObservedObject:**

| @EnvironmentObject | @ObservedObject |
|-------------------|-----------------|
| App-wide state (theme, user session) | Feature-specific state |
| Deeply nested views | Shallow view hierarchy |
| Many views need same data | Only child needs data |
| Avoid prop drilling | Explicit dependencies |

---

## @Environment — System Values

**Use when:** Reading system-provided values.

```swift
struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.locale) var locale
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text(colorScheme == .dark ? "Dark mode" : "Light mode")
            
            Button("Close") {
                dismiss()  // Dismiss current view
            }
        }
    }
}
```

**Common environment keys:**

```swift
@Environment(\.colorScheme) var colorScheme
@Environment(\.dismiss) var dismiss
@Environment(\.openURL) var openURL
@Environment(\.presentationMode) var presentationMode  // iOS 13-15
@Environment(\.horizontalSizeClass) var horizontalSizeClass
@Environment(\.verticalSizeClass) var verticalSizeClass
@Environment(\.isEnabled) var isEnabled
@Environment(\.layoutDirection) var layoutDirection
```

**Custom environment values:**

```swift
// Define custom key
struct UserKey: EnvironmentKey {
    static let defaultValue: User? = nil
}

extension EnvironmentValues {
    var user: User? {
        get { self[UserKey.self] }
        set { self[UserKey.self] = newValue }
    }
}

// Inject custom value
ContentView()
    .environment(\.user, currentUser)

// Read custom value
@Environment(\.user) var user
```

---

## @AppStorage — UserDefaults Wrapper

**Use when:** Persisting simple values to UserDefaults.

```swift
struct SettingsView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("username") private var username: String = ""
    @AppStorage("darkMode") private var darkMode = false
    
    var body: some View {
        VStack {
            Toggle("Dark Mode", isOn: $darkMode)
            TextField("Username", text: $username)
        }
    }
}
```

**Key points:**
- Automatically reads/writes to UserDefaults
- Triggers view update when value changes
- Only for property list types (String, Int, Bool, Data, URL)
- Not for complex objects

**Common mistakes:**

```swift
// ❌ WRONG: Using for complex objects
@AppStorage("user") private var user: User  // Won't compile

// ✅ CORRECT: Use for simple values, ViewModel for complex
@AppStorage("userId") private var userId: String = ""

class UserViewModel: ObservableObject {
    @Published var user: User?
    
    func load(userId: String) {
        // Fetch from database
    }
}
```

---

## @SceneStorage — Scene Restoration

**Use when:** Preserving state across app relaunches (scene restoration).

```swift
struct ContentView: View {
    @SceneStorage("currentTab") private var currentTab = 0
    @SceneStorage("searchQuery") private var searchQuery = ""
    
    var body: some View {
        TabView(selection: $currentTab) {
            // Tabs restore selection after relaunch
        }
    }
}
```

**Key points:**
- Similar to @AppStorage but per-scene
- Survives app termination and relaunch
- Limited storage (use for UI state, not data)

---

## Comparison Table

| Wrapper | Storage | Lifecycle | Use For |
|---------|---------|-----------|---------|
| `@State` | SwiftUI-managed | View lifetime | Local value-type state |
| `@Binding` | Parent's @State | Parent's lifetime | Two-way parent-child |
| `@StateObject` | You create | View lifetime | Owned ObservableObject |
| `@ObservedObject` | Passed in | External | Borrowed ObservableObject |
| `@EnvironmentObject` | Injected at top | App lifetime | Shared across hierarchy |
| `@Environment` | System/injected | App lifetime | System values, custom keys |
| `@AppStorage` | UserDefaults | Persistent | Simple persisted values |
| `@SceneStorage` | Scene restoration | Scene lifetime | UI state across relaunch |

---

## State Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        App Level                             │
│  @StateObject (AppState, UserSession)                        │
│       ↓ .environmentObject()                                 │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                    Feature Level                             │
│  @StateObject (ViewModel)                                    │
│       ↓ passed as @ObservedObject                            │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                      View Level                              │
│  @State (local UI state)                                     │
│       ↓ passed as @Binding                                   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                     Child Level                              │
│  @Binding (modify parent state)                              │
│  @EnvironmentObject (access shared state)                    │
└─────────────────────────────────────────────────────────────┘
```

---

## Real-World Example: Complete Feature

```swift
// Model
struct User: Codable, Identifiable {
    let id: String
    var name: String
    var email: String
}

// AppState (shared across app)
class AppState: ObservableObject {
    @Published var currentUser: User?
    @Published var theme: AppTheme = .system
    
    enum AppTheme: String {
        case light, dark, system
    }
}

// ViewModel (feature-level)
@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var error: String?
    @Published var isEditing = false
    
    private let repository: UserRepository
    private let appState: AppState
    
    init(repository: UserRepository, appState: AppState) {
        self.repository = repository
        self.appState = appState
    }
    
    func loadUser() async {
        isLoading = true
        error = nil
        
        do {
            user = try await repository.fetchUser(id: appState.currentUser?.id ?? "")
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updateName(_ newName: String) async {
        guard var user = user else { return }
        user.name = newName
        
        do {
            let updated = try await repository.updateUser(user)
            self.user = updated
            isEditing = false
        } catch {
            self.error = error.localizedDescription
        }
    }
}

// Main View
struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    @EnvironmentObject var appState: AppState
    @AppStorage("hasCompletedProfile") private var hasCompletedProfile = false
    
    init(viewModel: ProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.error {
                ErrorView(error: error, onRetry: loadUser)
            } else if let user = viewModel.user {
                Form {
                    Section("Profile") {
                        if viewModel.isEditing {
                            TextField("Name", text: $user.name)
                        } else {
                            Text(user.name)
                        }
                        Text(user.email)
                    }
                    
                    Section {
                        if viewModel.isEditing {
                            Button("Save") {
                                Task { await viewModel.updateName(user.name) }
                            }
                            Button("Cancel", role: .cancel) {
                                viewModel.isEditing = false
                            }
                        } else {
                            Button("Edit Profile") {
                                viewModel.isEditing = true
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Profile")
        .onAppear(perform: loadUser)
        .onChange(of: hasCompletedProfile) { newValue in
            if !newValue {
                // Prompt user to complete profile
            }
        }
    }
    
    private func loadUser() {
        Task {
            await viewModel.loadUser()
        }
    }
}

// Child view with binding
struct ProfileHeaderView: View {
    @Binding var isEditing: Bool
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        HStack {
            Text("Profile")
                .font(.headline)
            Spacer()
            Button(isEditing ? "Done" : "Edit") {
                isEditing.toggle()
            }
        }
    }
}
```

---

## Testing Tips

```swift
// Test @State with ViewInspector or manual inspection
func testCounterView() {
    let view = CounterView()
    // Use ViewInspector or UITest
}

// Test @StateObject ViewModel in isolation
func testProfileViewModel() async {
    let mockRepo = MockUserRepository()
    let appState = AppState()
    let viewModel = ProfileViewModel(repository: mockRepo, appState: appState)
    
    await viewModel.loadUser()
    
    XCTAssertEqual(viewModel.user?.name, "Test User")
    XCTAssertFalse(viewModel.isLoading)
}

// Test @Binding with parent controlling state
func testChildViewWithBinding() {
    var count = 0
    let binding = Binding(
        get: { count },
        set: { count = $0 }
    )
    
    let childView = ChildView(count: binding)
    // Test that child modifies count correctly
}
```

---

## Performance Considerations

**Avoid unnecessary updates:**

```swift
// ❌ Expensive computation in body
var body: some View {
    Text(items.filter { $0.isActive }.sorted { $0.name < $1.name }.count)
}

// ✅ Use computed property or lazy
private var activeSortedItems: [Item] {
    items.filter { $0.isActive }.sorted { $0.name < $1.name }
}

var body: some View {
    Text(activeSortedItems.count)
}
```

**Use @StateObject not @ObservedObject for owned ViewModels:**

```swift
// ❌ Recreates ViewModel on every render
struct View: View {
    @ObservedObject var viewModel = ViewModel()
    
    var body: some View { }
}

// ✅ Creates once
struct View: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View { }
}
```

**Use EquatableView for expensive views:**

```swift
struct ExpensiveView: View, Equatable {
    let data: [Item]
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.data.count == rhs.data.count
    }
    
    var body: some View {
        // Only redraws if data.count changes
    }
}
```
