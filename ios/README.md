# iOS Senior Engineer — Interview Prep Course

> **Difficulty target:** Moderate (expect depth on architecture, concurrency, and Swift internals, not leetcode-hard algorithms)
> **Format:** Modules ordered by interview impact. Do Module 1 first, always.

---

## Table of Contents

| # | Module | Why it matters |
|---|--------|---------------|
| 1 | [Swift Language Fundamentals](#module-1-swift-language-fundamentals) | Every iOS question assumes fluent Swift |
| 2 | [UIKit & SwiftUI Lifecycle](#module-2-uikit--swiftui-lifecycle) | The mental model interviewers test most |
| 3 | [State Management & Data Flow](#module-3-state-management--data-flow) | Biggest differentiation between mid and senior |
| 4 | [Architecture & Project Structure](#module-4-architecture--project-structure) | Senior signal: can you own a codebase? |
| 5 | [Concurrency: async/await, Actors & Tasks](#module-5-concurrency-asyncawait-actors--tasks) | Deep Swift — expected at senior level |
| 6 | [Navigation & View Controllers](#module-6-navigation--view-controllers) | Practical, frequently tested |
| 7 | [Performance & Optimization](#module-7-performance--optimization) | Shows production experience |
| 8 | [Testing Strategy](#module-8-testing-strategy) | Non-negotiable in production-grade apps |
| 9 | [Native Features & Frameworks](#module-9-native-features--frameworks) | Differentiator for senior roles |
| 10 | [Security, Privacy & Compliance](#module-10-security-privacy--compliance) | Critical for any app handling sensitive user data |
| 11 | [Accessibility](#module-11-accessibility) | Required in any user-facing production app |
| 12 | [CI/CD & Release Pipeline](#module-12-cicd--release-pipeline) | Shows ownership beyond code |
| 13 | [Behavioral & System Design](#module-13-behavioral--system-design) | The round that actually gets you hired |

---

## SwiftUI Focus Track

If SwiftUI is your primary focus (recommended for modern iOS roles), follow this accelerated path:

| Week | Focus | Resources | Practice |
|------|-------|-----------|----------|
| 1 | Swift fundamentals + @State/@Binding | Module 1, 2 | Drills 1-10 |
| 2 | State management deep dive | Module 3, [SwiftUI State](lessons/swiftui-state.md) | Drills 11-30 |
| 3 | Layout + Navigation | Module 2, 6 | Challenges 1-5, 11-12 |
| 4 | Async/await + API integration | Module 5 | Challenges 6, 12 |
| 5 | Animations + Gestures | [Advanced Patterns](lessons/swiftui-advanced.md) | Drills 31-50 |
| 6 | Performance + Testing | Module 7, 8 | Challenges 13-15 |
| 7 | Advanced patterns | [Advanced Patterns](lessons/swiftui-advanced.md) | Challenges 16-20 |
| 8 | Interview prep | [Interview Questions](lessons/swiftui-interview-questions.md) | Mock interviews |

---

## Lessons

In-depth reference material beyond the module summaries.

| File | What it covers |
|------|---------------|
| [lessons/state-management-comparison.md](lessons/state-management-comparison.md) | Observable · @Published · Redux · MVVM — pros/cons, decision guide |
| [lessons/swiftui-state.md](lessons/swiftui-state.md) | @State, @Binding, @ObservedObject, @StateObject, @EnvironmentObject — complete guide |
| [lessons/combine-framework.md](lessons/combine-framework.md) | Publishers, subscribers, operators, backpressure, UIKit integration |
| [lessons/swiftui-advanced.md](lessons/swiftui-advanced.md) | Custom modifiers, Environment, Layout, Animations, Performance, Testing |
| [lessons/swiftui-troubleshooting.md](lessons/swiftui-troubleshooting.md) | Common issues, error messages, debugging tips |
| [lessons/swiftui-interview-questions.md](lessons/swiftui-interview-questions.md) | 33+ interview questions from basics to advanced |

---

## Lessons

In-depth reference material beyond the module summaries.

| File | What it covers |
|------|---------------|
| [lessons/state-management-comparison.md](lessons/state-management-comparison.md) | Observable · @Published · Redux · MVVM — pros/cons, decision guide, real-world scenarios |
| [lessons/swiftui-state.md](lessons/swiftui-state.md) | @State, @Binding, @ObservedObject, @StateObject, @EnvironmentObject — when to use which |
| [lessons/combine-framework.md](lessons/combine-framework.md) | Publishers, subscribers, operators, backpressure, UIKit integration |

---

## Module 1: Swift Language Fundamentals

> **Priority: CRITICAL.** iOS is Swift. If you stumble on Swift basics, nothing else matters.

---

### 1.1 Optionals & Nil Safety

Swift has compile-time null safety. Every type is non-optional by default.

```swift
let name: String = "Regis"      // never nil
var nickname: String?           // optional (can be nil)

// Safe unwrapping
if let nickname = nickname {
    print(nickname.uppercased())
}

// Guard for early exit
guard let nickname = nickname else { return }

// Nil-coalescing
let display = nickname ?? "anonymous"

// Optional chaining
let firstChar = nickname?.first

// Implicitly unwrapped optional (use sparingly)
let titleLabel: UILabel! = UILabel()
```

**What interviewers ask:**
- "What's the difference between `let` and `var`?"

```swift
let count = 0      // immutable (compile-time constant)
var total = 0      // mutable
```

- "When would you use `guard` vs `if let`?"

```swift
// guard: early exit, keeps happy path un-nested
// if let: nested scope, use when you need the unwrapped value briefly

func process(user: User?) {
    guard let user = user, user.isActive else { return }
    // rest of function uses unwrapped `user`
}
```

---

### 1.2 Value Types vs Reference Types

| Value Types (copy on assign) | Reference Types (shared instance) |
|------------------------------|-----------------------------------|
| `struct` | `class` |
| `enum` | `actor` (Swift 5.5+) |
| `tuple` | |

```swift
// Struct: copied when assigned or passed
struct User {
    let id: String
    var name: String
}

var user1 = User(id: "1", name: "Regis")
var user2 = user1        // copy
user2.name = "John"      // user1 unchanged

// Class: shared reference
class Counter {
    var value = 0
}

let c1 = Counter()
let c2 = c1              // same instance
c2.value = 10            // c1.value also 10
```

**When to use struct vs class:**
- Default to `struct` — safer, easier to reason about
- Use `class` when you need: identity, inheritance, or shared mutable state

---

### 1.3 Generics

Generics allow you to write reusable, type-safe code that works with any type.

```swift
// Generic function
func swapValues<T>(_ a: inout T, _ b: inout T) {
    let temp = a
    a = b
    b = temp
}

// Generic type
struct Repository<T> {
    private var items: [T] = []
    
    func findById(_ id: String) -> T? { ... }
    func findAll() -> [T] { ... }
}

// Usage
let userRepo = Repository<User>()
```

---

### 1.4 Extensions

Add methods to existing types without subclassing:

```swift
extension String {
    func toTitleCase() -> String {
        split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
            .joined(separator: " ")
    }
}

"hello world".toTitleCase()   // "Hello World"
```

---

### 1.5 Protocols

Define contracts that types must conform to:

```swift
protocol Loggable {
    func log(message: String)
}

extension Loggable {
    func log(message: String) {
        print("[\(type(of: self))] \(message)")
    }
}

class AuthService: Loggable {
    func login() {
        log(message: "Login called")
    }
}
```

**Protocol-oriented programming:** prefer protocols + extensions over class inheritance.

---

### 1.6 Closures & Capture Lists

Closures are self-contained blocks of functionality. Capture lists control memory management:

```swift
// Basic closure
let names = ["John", "Jane"]
let sorted = names.sorted { $0 > $1 }

// Capture list for memory safety
class ViewModel {
    var data: [String] = []
    var onComplete: (() -> Void)?
    
    func fetchData() {
        Task {
            // [weak self] prevents retain cycles
            await MainActor.run { [weak self] in
                self?.data = fetchedData
                self?.onComplete?()
            }
        }
    }
}
```

**What interviewers ask:**
- "What is a retain cycle and how do you prevent it?"

```swift
// Retain cycle: both hold strong references
class ViewController {
    var callback: (() -> Void)?
    
    func setup() {
        callback = {
            self.doSomething()   // self captured strongly → cycle
        }
    }
}

// Fix: use [weak self] or [unowned self]
callback = { [weak self] in
    self?.doSomething()
}
```

---

### 1.7 Result Builders (Swift 5.4+)

Result builders enable DSL-like syntax — the foundation of SwiftUI:

```swift
@resultBuilder
struct ArrayBuilder {
    static func buildBlock(_ components: [Int]...) -> [Int] {
        components.flatMap { $0 }
    }
}

@ArrayBuilder var numbers: [Int] {
    1
    2
    3
}   // [1, 2, 3]
```

---

### 1.8 Pattern Matching

Swift has powerful pattern matching beyond simple equality:

```swift
// Switch with where clauses
enum AuthState {
    case authenticated(userId: String)
    case unauthenticated
    case loading
}

func label(for state: AuthState) -> String {
    switch state {
    case .authenticated(let userId) where userId.hasPrefix("admin"):
        return "Admin: \(userId)"
    case .authenticated(let userId):
        return "User: \(userId)"
    case .unauthenticated:
        return "Please log in"
    case .loading:
        return "Loading..."
    }
}

// Tuple destructuring
let (name, age) = ("Regis", 30)

// Optional binding with multiple conditions
if let name = user.name, !name.isEmpty, name.count > 2 {
    // all conditions met
}
```

---

### Module 1 — Quick fire answers

| Question | Answer |
|----------|--------|
| What is the difference between `struct` and `class`? | Structs are value types (copied), classes are reference types (shared) |
| What does `guard` do? | Exits early if condition fails, keeps unwrapped value in scope |
| What is a protocol? | A contract defining methods/properties that conforming types must implement |
| What is `@escaping` for closures? | Closure outlives the function call — must be explicit for memory safety |

---

## Module 2: UIKit & SwiftUI Lifecycle

> **Priority: CRITICAL.** The most common technical deep-dive area.

---

### 2.1 App Lifecycle

**UIKit (UIApplicationDelegate):**

```swift
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, 
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // App launched — setup window
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // About to move from active → inactive
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Save data, release shared resources
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Undo background changes
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Final cleanup (not always called)
    }
}
```

**SwiftUI (Scene phase):**

```swift
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

// Observe lifecycle in views
struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        Text("Hello")
            .onChange(of: scenePhase) { phase in
                switch phase {
                case .active:
                    print("App is active")
                case .inactive:
                    print("App is inactive")
                case .background:
                    print("App in background")
                @unknown default:
                    break
                }
            }
    }
}
```

---

### 2.2 ViewController Lifecycle

```swift
class MyViewController: UIViewController {
    
    // 1. Loading phase
    override func loadView() {
        // Create view hierarchy programmatically (if not using storyboard/xib)
        view = UIView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // View loaded into memory — setup UI, constraints, data sources
    }
    
    // 2. Appearance phase
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Update UI, start animations, keyboard handling
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // View visible — start timers, analytics, heavy work
    }
    
    // 3. Disappearance phase
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Save state, stop animations
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Cleanup, stop timers, release resources
    }
    
    // 4. Memory phase
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release cached data, images
    }
    
    deinit {
        // ViewController deallocated
    }
}
```

---

### 2.3 SwiftUI View Lifecycle

SwiftUI views are value types — they're structs that get recreated frequently.

```swift
struct ContentView: View {
    @State private var count = 0
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            Text("Count: \(count)")
            Button("Increment") {
                count += 1
            }
        }
        .onAppear {
            // View appeared — like viewDidAppear
            viewModel.loadData()
        }
        .onDisappear {
            // View disappeared — like viewDidDisappear
            viewModel.cleanup()
        }
        .onChange(of: count) { newCount in
            // State changed — react to specific changes
            print("Count changed to \(newCount)")
        }
    }
}
```

**Key insight for interviews:** SwiftUI views are cheap structs — the `body` getter runs frequently. Heavy work belongs in `.onAppear`, view models, or computed properties — never directly in `body`.

---

### 2.4 UIView vs UIViewRepresentable

**UIKit:**

```swift
class CustomView: UIView {
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSubview(label)
        setupConstraints()
    }
    
    private func setupConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Custom layout logic
    }
    
    override func draw(_ rect: CGRect) {
        // Custom drawing
    }
}
```

**SwiftUI wrapper:**

```swift
struct CustomViewRepresentable: UIViewRepresentable {
    var text: String
    
    func makeUIView(context: Context) -> CustomView {
        let view = CustomView()
        return view
    }
    
    func updateUIView(_ uiView: CustomView, context: Context) {
        uiView.label.text = text
    }
}
```

---

### 2.5 Auto Layout & Layout Systems

**UIKit Auto Layout:**

```swift
// Programmatic constraints
let label = UILabel()
label.translatesAutoresizingMaskIntoConstraints = false
view.addSubview(label)

NSLayoutConstraint.activate([
    label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
    label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
    label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
])

// Or using anchors directly
label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
```

**SwiftUI Layout:**

```swift
VStack(alignment: .leading, spacing: 16) {
    Text("Title")
        .font(.headline)
    
    Text("Subtitle")
        .font(.subheadline)
        .foregroundColor(.secondary)
}
.padding(16)
.frame(maxWidth: .infinity, alignment: .leading)
```

---

### Module 2 — Quick fire answers

| Question | Answer |
|----------|--------|
| Difference between `viewDidLoad` and `viewWillAppear`? | `viewDidLoad` called once when view loads; `viewWillAppear` called every time before view appears |
| When does SwiftUI `body` get called? | Frequently — whenever any @State or @Binding changes, or parent redraws |
| What is `translatesAutoresizingMaskIntoConstraints`? | Tells Auto Layout whether to convert autoresizing mask to constraints (set to `false` for manual constraints) |
| What is the responder chain? | The path events travel: View → ViewController → NavigationController → Window → App |

---

## Module 3: State Management & Data Flow

> **Priority: CRITICAL.** This is where senior vs mid engineers are separated.
>
> **Deep dive:** [lessons/state-management-comparison.md](lessons/state-management-comparison.md) — full comparison of Observable, @Published, Redux, MVVM with decision guide and real-world scenarios.

---

### 3.1 The Spectrum

```
Local ←————————————————————————————→ Global
@State   @Published  ObservableObject  Redux  Actor-isolated
  │           │            │            │         │
Simple UI  Class-based  MVVM pattern  Unidirectional  Thread-safe
 changes   observable   + dependency   data flow     concurrent state
```

No single right answer — the senior answer is knowing **when to use which.**

---

### 3.2 @State — Local UI State

`@State` is source of truth for local SwiftUI view state:

```swift
struct CounterView: View {
    @State private var count = 0
    
    var body: some View {
        Text("Count: \(count)")
            .onTapGesture {
                count += 1   // triggers view update
            }
    }
}
```

**Rules:**
- Only use in `struct View`
- Never share @State between views
- Use for: toggle, form field, animation trigger

---

### 3.3 @Binding — Two-way connection

`@Binding` connects child views to parent state:

```swift
// Parent
struct ParentView: View {
    @State private var count = 0
    
    var body: some View {
        ChildView(count: $count)   // $ passes binding
    }
}

// Child
struct ChildView: View {
    @Binding var count: Int
    
    var body: some View {
        Button("Increment") {
            count += 1   // modifies parent's state
        }
    }
}
```

---

### 3.4 ObservableObject & @Published

For shared state across multiple views:

```swift
class ViewModel: ObservableObject {
    @Published var items: [String] = []
    @Published var isLoading = false
    
    func loadItems() {
        isLoading = true
        // async work
        items = ["Item 1", "Item 2"]
        isLoading = false
    }
}

// In SwiftUI
struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    @ObservedObject var observedViewModel: ViewModel
    
    var body: some View {
        List(viewModel.items, id: \.self) { item in
            Text(item)
        }
        .onAppear {
            viewModel.loadItems()
        }
    }
}
```

**@StateObject vs @ObservedObject:**
- `@StateObject`: You own the lifecycle (create it)
- `@ObservedObject`: Someone else owns it (passed in)

---

### 3.5 @EnvironmentObject — Global dependency injection

```swift
// Setup in App
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

// Access anywhere in view hierarchy
struct AnyView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Text(appState.user?.name ?? "Guest")
    }
}
```

---

### 3.6 MVVM Pattern (iOS Standard)

```swift
// Model
struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
}

// View
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.error {
                ErrorView(error: error, onRetry: viewModel.loadUser)
            } else if let user = viewModel.user {
                UserCard(user: user)
            }
        }
        .onAppear { viewModel.loadUser() }
    }
}

// ViewModel
@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let repository: UserRepository
    
    init(repository: UserRepository = UserRepository()) {
        self.repository = repository
    }
    
    func loadUser() async {
        isLoading = true
        error = nil
        
        do {
            user = try await repository.fetchCurrentUser()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}

// Repository
class UserRepository {
    private let apiClient: APIClient
    
    func fetchCurrentUser() async throws -> User {
        try await apiClient.get("/user")
    }
}
```

---

### 3.7 Combine Framework

Combine is Apple's reactive framework for handling asynchronous events:

```swift
import Combine

class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var results: [Product] = []
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $query
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { $0.count > 2 }
            .flatMap { query in
                self.searchProducts(query)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$results)
    }
    
    private func searchProducts(_ query: String) -> AnyPublisher<[Product], Never> {
        // async work
        Future { promise in
            promise(.success([]))
        }
        .eraseToAnyPublisher()
    }
}
```

**Key operators:**
- `debounce`: wait for pause in input
- `removeDuplicates`: skip identical values
- `flatMap`: transform to publisher, merge results
- `combineLatest`: combine multiple publishers
- `merge`: merge multiple publishers of same type

---

### 3.8 Redux/Unidirectional Data Flow

For complex state with predictable transitions:

```swift
// State
struct AppState {
    var users: [User] = []
    var isLoading = false
    var error: String?
    var filter: UserFilter = .all
}

// Actions
enum Action {
    case loadUsers
    case usersLoaded([User])
    case usersFailed(String)
    case setFilter(UserFilter)
}

// Store
class Store: ObservableObject {
    @Published private(set) var state: AppState
    
    private let reducer: Reducer
    private var cancellables = Set<AnyCancellable>()
    
    init(initialState: AppState = AppState(), reducer: Reducer) {
        self.state = initialState
        self.reducer = reducer
    }
    
    func dispatch(_ action: Action) {
        state = reducer.reduce(state, action)
    }
}

// Usage in view
struct UserListView: View {
    @StateObject private var store = Store(reducer: appReducer)
    
    var body: some View {
        List(store.state.users) { user in
            Text(user.name)
        }
        .onAppear {
            store.dispatch(.loadUsers)
        }
    }
}
```

---

### 3.9 Actor-Isolated State (Swift 5.5+)

Actors provide thread-safe state management:

```swift
actor Counter {
    private var value = 0
    
    func increment() -> Int {
        value += 1
        return value
    }
    
    func getValue() -> Int {
        value
    }
}

// Usage
let counter = Counter()
let newValue = await counter.increment()
```

**Why actors matter:** They automatically isolate mutable state to a single concurrent domain, preventing data races at compile time.

---

### 3.10 Decision Table

| Dimension | @State/@Binding | ObservableObject | Combine | Redux | Actor |
|-----------|-----------------|------------------|---------|-------|-------|
| **Scope** | Local view | Shared views | Reactive streams | Global app state | Concurrent state |
| **Boilerplate** | Minimal | Low | Medium | High | Low |
| **Learning curve** | Low | Low | Medium-High | High | Medium |
| **Best for** | Simple UI state | MVVM features | Event pipelines | Complex apps | Thread-safe state |

---

### Module 3 — Quick fire answers

| Question | Answer |
|----------|--------|
| @StateObject vs @ObservedObject? | StateObject owns lifecycle; ObservedObject is borrowed |
| What is @Published? | Property wrapper that notifies observers when value changes |
| When to use Redux? | Complex state with many transitions, need for time-travel debugging |
| What does `@MainActor` do? | Ensures all code runs on main thread — critical for UI updates |

---

## Module 4: Architecture & Project Structure

> **Priority: HIGH.** Senior engineers own codebases, not just features.

---

### 4.1 Common Patterns

**MVVM (Most Common):**
```
View → ViewModel → Model
       ↑              ↓
    Binding      Repository
```

**Clean Architecture:**
```
Presentation → Domain → Data
   (Views)    (Use Cases) (Repositories, API)
```

**VIPER:**
```
View → Interactor → Presenter → Entity
         ↑              ↓
      Router        Repository
```

---

### 4.2 Recommended Structure

```
MyApp/
├── App/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── DIContainer.swift
├── Features/
│   ├── Auth/
│   │   ├── Views/
│   │   ├── ViewModels/
│   │   └── AuthRouter.swift
│   ├── Home/
│   │   └── ...
│   └── Profile/
│       └── ...
├── Core/
│   ├── Network/
│   │   ├── APIClient.swift
│   │   └── Endpoints.swift
│   ├── Database/
│   │   └── CoreDataStack.swift
│   ├── Utils/
│   └── Extensions/
├── Resources/
│   ├── Assets.xcassets
│   ├── Localizable.strings
│   └── Info.plist
└── Tests/
    ├── UnitTests/
    └── UITests/
```

---

### 4.3 Dependency Injection

**Manual DI (Recommended):**

```swift
class DIContainer {
    static let shared = DIContainer()
    
    lazy var apiClient: APIClient = APIClient()
    lazy var userRepository: UserRepository = UserRepository(apiClient: apiClient)
    lazy var authViewModel: AuthViewModel = AuthViewModel(repository: userRepository)
    
    private init() {}
}

// Usage
let viewModel = DIContainer.shared.authViewModel
```

**Protocol-based DI:**

```swift
protocol ServiceLocator {
    func makeAuthViewModel() -> AuthViewModel
}

class ProductionServiceLocator: ServiceLocator {
    func makeAuthViewModel() -> AuthViewModel {
        AuthViewModel(repository: UserRepository(apiClient: APIClient()))
    }
}

class MockServiceLocator: ServiceLocator {
    func makeAuthViewModel() -> AuthViewModel {
        AuthViewModel(repository: MockUserRepository())
    }
}
```

---

### Module 4 — Quick fire answers

| Question | Answer |
|----------|--------|
| MVVM vs VIPER? | MVVM: simpler, faster; VIPER: more separation, more boilerplate |
| Why dependency injection? | Testability, flexibility, clear dependencies |
| Where to put business logic? | ViewModel (MVVM) or Use Case (Clean Architecture) |

---

## Module 5: Concurrency — async/await, Actors & Tasks

> **Priority: CRITICAL.** Modern Swift concurrency is expected at senior level.

---

### 5.1 async/await Basics

```swift
// Async function
func fetchUser(id: String) async throws -> User {
    let (data, response) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode(User.self, from: data)
}

// Calling async code
Task {
    do {
        let user = try await fetchUser(id: "123")
        print(user.name)
    } catch {
        print("Error: \(error)")
    }
}

// Main actor for UI
@MainActor
func updateUI() {
    // Safe UI updates
}
```

---

### 5.2 Task & TaskGroup

```swift
// Single task
@StateObject private var viewModel = ViewModel()

class ViewModel: ObservableObject {
    @Published var items: [Item] = []
    
    private var task: Task<Void, Never>?
    
    func load() {
        task = Task {
            await fetchItems()
        }
    }
    
    func cancel() {
        task?.cancel()
    }
    
    @MainActor
    private func fetchItems() async {
        // async work
    }
}

// Task group for parallel work
func fetchAllUsers() async throws -> [User] {
    try await withTaskGroup(of: User.self) { group in
        for id in userIds {
            group.addTask {
                try await self.fetchUser(id: id)
            }
        }
        
        var users: [User] = []
        for await user in group {
            users.append(user)
        }
        return users
    }
}
```

---

### 5.3 Actor Isolation

```swift
actor UserManager {
    private var users: [String: User] = [:]
    
    func getUser(id: String) async -> User? {
        users[id]
    }
    
    func addUser(_ user: User) async {
        users[user.id] = user
    }
}

// Usage
let manager = UserManager()
await manager.addUser(user)
let fetched = await manager.getUser(id: "123")
```

---

### 5.4 Sendable & Thread Safety

```swift
// Sendable types can cross concurrency domains safely
struct User: Sendable {
    let id: String
    let name: String
}

// Class must be actor-isolated or use locks
final class Counter: @unchecked Sendable {
    private var value = 0
    private let lock = NSLock()
    
    func increment() {
        lock.lock()
        defer { lock.unlock() }
        value += 1
    }
}
```

---

### Module 5 — Quick fire answers

| Question | Answer |
|----------|--------|
| What does `await` do? | Suspends execution until async operation completes |
| What is `@MainActor`? | Ensures code runs on main thread — required for UI |
| How do you cancel a Task? | Call `.cancel()` or let it deallocate |
| What is `Sendable`? | Protocol marking types safe to pass across concurrency domains |

---

## Module 6: Navigation & View Controllers

> **Priority: HIGH.** Practical, frequently tested.

---

### 6.1 UIKit Navigation

```swift
// Programmatic navigation
class ViewController: UIViewController {
    func goToDetail() {
        let detailVC = DetailViewController()
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func presentModal() {
        let modalVC = ModalViewController()
        modalVC.modalPresentationStyle = .pageSheet
        present(modalVC, animated: true)
    }
}

// Passing data
class DetailViewController: UIViewController {
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = user?.name
    }
}
```

---

### 6.2 SwiftUI Navigation

**NavigationStack (iOS 16+):**

```swift
struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List(viewModel.items) { item in
                NavigationLink(value: item.id) {
                    Text(item.name)
                }
            }
            .navigationDestination(for: String.self) { itemId in
                DetailView(itemId: itemId)
            }
        }
    }
}
```

**Programmatic navigation:**

```swift
// Push
navigationPath.append(itemId)

// Pop
navigationPath.removeLast()

// Pop to root
navigationPath = NavigationPath()
```

---

### 6.3 Deep Linking

```swift
// UIKit
func application(_ application: UIApplication, 
                 continue userActivity: NSUserActivity,
                 restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    if let url = userActivity.webpageURL {
        handleDeepLink(url)
    }
    return true
}

// SwiftUI
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }
}
```

---

### Module 6 — Quick fire answers

| Question | Answer |
|----------|--------|
| NavigationStack vs NavigationView? | NavigationStack is iOS 16+ replacement with better path management |
| How to pass data in SwiftUI navigation? | Use @State + NavigationLink(value:) or environment objects |
| What is restorationIdentifier? | iOS saves/restores VC state across app launches |

---

## Module 7: Performance & Optimization

> **Priority: HIGH.** Shows production experience.

---

### 7.1 Common Bottlenecks

| Issue | Detection | Fix |
|-------|-----------|-----|
| Main thread blocking | Xcode debugger, Time Profiler | Move to background, use async/await |
| Offscreen rendering | Core Animation instrument | `shouldRasterize`, remove shadows |
| Large images | Memory gauge | Resize, use thumbnails, lazy loading |
| Unnecessary redraws | View debugger | `@State` optimization, `EquatableView` |

---

### 7.2 UITableView/UICollectionView Optimization

```swift
// Cell reuse
func tableView(_ tableView: UITableView, 
               cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel?.text = items[indexPath.row]
    return cell
}

// Prefetching
extension ViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, 
                   prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            preloadImage(for: items[indexPath.row])
        }
    }
}
```

---

### 7.3 SwiftUI Performance

```swift
// Lazy loading
List {
    ForEach(items) { item in
        Text(item.name)
    }
}

// Or for more control
LazyVStack {
    ForEach(items) { item in
        Text(item.name)
    }
}

// Avoid work in body
struct OptimizedView: View {
    let items: [Item]
    
    // Computed property (cached by SwiftUI)
    private var sortedItems: [Item] {
        items.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        List(sortedItems) { item in
            Text(item.name)
        }
    }
}

// Use @StateObject not @ObservedObject for owned view models
```

---

### 7.4 Memory Management

```swift
// Weak references to avoid retain cycles
class ViewModel {
    var onComplete: (() -> Void)?
    
    func load() {
        Task { [weak self] in
            await self?.updateUI()
        }
    }
}

// Image caching
let cache = NSCache<NSString, UIImage>()
cache.countLimit = 100
cache.totalCostLimit = 100 * 1024 * 1024  // 100MB
```

---

### Module 7 — Quick fire answers

| Question | Answer |
|----------|--------|
| How to detect retain cycles? | Xcode Memory Graph debugger |
| What is `dequeueReusableCell`? | Reuses table/collection cells instead of creating new ones |
| Why use LazyVStack? | Only creates views when they're about to appear on screen |

---

## Module 8: Testing Strategy

> **Priority: HIGH.** Non-negotiable in production-grade apps.

---

### 8.1 Unit Testing ViewModels

```swift
import XCTest
@testable import MyApp

final class ProfileViewModelTests: XCTestCase {
    var viewModel: ProfileViewModel!
    var mockRepository: MockUserRepository!
    
    override func setUp() {
        mockRepository = MockUserRepository()
        viewModel = ProfileViewModel(repository: mockRepository)
    }
    
    func test_loadUser_success() async {
        // Given
        mockRepository.userToReturn = User(id: "1", name: "Test")
        
        // When
        await viewModel.loadUser()
        
        // Then
        XCTAssertEqual(viewModel.user?.name, "Test")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }
    
    func test_loadUser_failure() async {
        // Given
        mockRepository.errorToThrow = NetworkError.unauthorized
        
        // When
        await viewModel.loadUser()
        
        // Then
        XCTAssertNil(viewModel.user)
        XCTAssertEqual(viewModel.error as? NetworkError, .unauthorized)
    }
}
```

---

### 8.2 UI Testing

```swift
import XCTest

final class MyAppUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        app = XCUIApplication()
        app.launch()
    }
    
    func test_loginFlow() {
        app.textFields["email"].tap()
        app.textFields["email"].typeText("test@example.com")
        app.secureTextFields["password"].typeText("password123")
        app.buttons["Login"].tap()
        
        XCTAssertTrue(app.staticTexts["Welcome"].exists)
    }
}
```

---

### 8.3 Snapshot Testing

```swift
import SnapshotTesting

func test_snapshot() {
    let view = ProfileView(viewModel: ProfileViewModel())
    view.frame = CGSize(width: 375, height: 667)
    
    assertSnapshot(matching: view, as: .image)
}
```

---

### Module 8 — Quick fire answers

| Question | Answer |
|----------|--------|
| XCTest vs Quick/Nimble? | XCTest is built-in; Quick/Nimble is BDD-style alternative |
| What is mocking? | Replacing real dependencies with test doubles |
| Why snapshot testing? | Catch unintended UI changes automatically |

---

## Module 9: Native Features & Frameworks

> **Priority: MEDIUM-HIGH.** Differentiator for senior roles.

---

### 9.1 Core Data

```swift
// Stack setup
class CoreDataStack {
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MyApp")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data load failed: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func save() {
        if context.hasChanges {
            try? context.save()
        }
    }
}

// Usage
let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
fetchRequest.predicate = NSPredicate(format: "isActive == %@", NSNumber(true))
let users = try? context.fetch(fetchRequest)
```

---

### 9.2 UserDefaults

```swift
// Simple
UserDefaults.standard.set("value", forKey: "key")
let value = UserDefaults.standard.string(forKey: "key")

// Property wrapper
@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get { UserDefaults.standard.object(forKey: key) as? T ?? defaultValue }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}

// Usage
@UserDefault(key: "hasSeenOnboarding", defaultValue: false)
var hasSeenOnboarding: Bool
```

---

### 9.3 Notifications

```swift
// Post
NotificationCenter.default.post(name: .userDidLogin, object: user)

// Observe
NotificationCenter.default.addObserver(
    self,
    selector: #selector(handleLogin),
    name: .userDidLogin,
    object: nil
)

// Combine
NotificationCenter.default.publisher(for: .userDidLogin)
    .sink { notification in
        // handle
    }
    .store(in: &cancellables)
```

---

### 9.4 Key-Value Observing (KVO)

```swift
// Observe
observation = object.observe(\.property, options: [.new]) { _, change in
    print("Changed to \(change.newValue ?? "nil")")
}

// Swift 5.5+ with Combine is preferred
```

---

### Module 9 — Quick fire answers

| Question | Answer |
|----------|--------|
| NSManagedObjectContext thread safety? | Not thread-safe — use one per thread or use `perform`/`performAndWait` |
| UserDefaults for what? | Small preferences, not large data sets |
| NotificationCenter vs Combine? | Combine is type-safe, composable, easier to manage lifecycle |

---

## Module 10: Security, Privacy & Compliance

> **Priority: HIGH.** Critical for any app handling sensitive user data.

---

### 10.1 Keychain

```swift
import Security

class KeychainManager {
    static let shared = KeychainManager()
    
    func save(token: String, forKey key: String) throws {
        let data = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGeneric,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed
        }
    }
    
    func read(forKey key: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGeneric,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            throw KeychainError.readFailed
        }
        return token
    }
}
```

---

### 10.2 App Transport Security

```xml
<!-- Info.plist -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <!-- Or allow specific domains -->
    <key>NSExceptionDomains</key>
    <dict>
        <key>api.example.com</key>
        <dict>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
            <false/>
        </dict>
    </dict>
</dict>
```

---

### 10.3 Privacy Manifest (iOS 17+)

```xml
<!-- PrivacyInfo.xcprivacy -->
<dict>
    <key>NSPrivacyCollectedDataTypes</key>
    <array>
        <dict>
            <key>NSPrivacyCollectedDataType</key>
            <string>NSPrivacyCollectedDataTypeEmailAddress</string>
            <key>NSPrivacyCollectedDataTypeLinked</key>
            <true/>
            <key>NSPrivacyCollectedDataTypeTracking</key>
            <false/>
        </dict>
    </array>
</dict>
```

---

### Module 10 — Quick fire answers

| Question | Answer |
|----------|--------|
| Where to store auth tokens? | Keychain, never UserDefaults |
| What is ATS? | App Transport Security — forces HTTPS |
| What is privacy manifest? | iOS 17+ requirement declaring data collection practices |

---

## Module 11: Accessibility

> **Priority: MEDIUM.** Required in any user-facing production app.

---

### 11.1 UIKit Accessibility

```swift
label.isAccessibilityElement = true
label.accessibilityLabel = "Submit form"
label.accessibilityHint = "Double tap to submit your information"
label.accessibilityTraits = .button

// Custom actions
label.accessibilityCustomActions = [
    UIAccessibilityCustomAction(name: "Delete", target: self, selector: #selector(delete))
]
```

---

### 11.2 SwiftUI Accessibility

```swift
Text("Hello")
    .accessibilityLabel("Greeting")
    .accessibilityHint("Welcome message")
    .accessibilityAddTraits(.isHeader)

Button("Submit") {
    // action
}
.accessibilityAction {
    // custom action
}
```

---

### 11.3 Dynamic Type

```swift
// UIKit
label.font = UIFont.preferredFont(forTextStyle: .body)
label.adjustsFontForContentSizeCategory = true

// SwiftUI
Text("Hello")
    .font(.body)
```

---

### Module 11 — Quick fire answers

| Question | Answer |
|----------|--------|
| What is VoiceOver? | iOS screen reader for visually impaired users |
| accessibilityLabel vs accessibilityHint? | Label identifies element; hint describes what happens on action |
| Why Dynamic Type? | Respects user's system font size preference |

---

## Module 12: CI/CD & Release Pipeline

> **Priority: MEDIUM.** Shows ownership beyond code.

---

### 12.1 Fastlane

```ruby
# Fastfile
default_platform :ios

lane :beta do
  increment_build_number
  build_app(workspace: "MyApp.xcworkspace", scheme: "MyApp")
  upload_to_testflight
end

lane :release do
  increment_version_number
  build_app(workspace: "MyApp.xcworkspace", scheme: "MyApp")
  upload_to_app_store
end
```

---

### 12.2 GitHub Actions

```yaml
name: iOS Build

on: [push, pull_request]

jobs:
  build:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_15.0.app
    
    - name: Build
      run: xcodebuild -workspace MyApp.xcworkspace -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 15' build
      
    - name: Test
      run: xcodebuild test -workspace MyApp.xcworkspace -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

### Module 12 — Quick fire answers

| Question | Answer |
|----------|--------|
| What is Fastlane? | Automation tool for building, testing, and deploying iOS apps |
| Why CI/CD? | Catch bugs early, automate releases, consistent process |

---

## Module 13: Behavioral & System Design

> **Priority: HIGH.** The round that actually gets you hired.

---

### 13.1 System Design Questions

**"Design Instagram feed":**

```
1. Clarify requirements
   - Features: photos, likes, comments, infinite scroll
   - Scale: millions of users, high read:write ratio
   
2. High-level architecture
   Client → API Gateway → Services (Feed, User, Media) → DBs
   
3. Data model
   User, Post, Like, Comment, Follow
   
4. Caching strategy
   - CDN for images
   - Redis for feed cache
   - Pagination with cursor
   
5. Trade-offs
   - Pull vs push feed model
   - Consistency vs availability
```

---

### 13.2 Behavioral Framework (STAR)

- **S**ituation: Set context
- **T**ask: What you needed to do
- **A**ction: What you did
- **R**esult: Outcome, metrics, learnings

**Example:**
> "Situation: Our app had 40% crash rate on iOS 15 launch.
> Task: I was tasked with stabilizing the release.
> Action: I set up crash analytics, identified the top 3 crashes, wrote regression tests, and coordinated a hotfix.
> Result: Crash rate dropped to 0.5% within 48 hours, App Store rating recovered from 2.1 to 4.3 stars."

---

### 13.3 Questions to Ask Interviewers

- "What does your iOS team structure look like?"
- "How do you handle technical debt?"
- "What's your release cadence?"
- "How do you measure app quality?"

---

## Practice

See the [`practice/`](practice) folder for hands-on exercises:

- **challenges/** — Find the bugs in existing code
- **build/** — Implement features from scratch
- **drills/** — Focused exercises on specific concepts

---

## Additional Resources

| Resource | What it covers |
|----------|---------------|
| [Apple Swift Documentation](https://docs.swift.org) | Official language reference |
| [WWDC Videos](https://developer.apple.com/wwdc) | Latest iOS features and best practices |
| [iOS Dev Weekly](https://iosdevweekly.com) | Weekly iOS development news |
| [Swift By Sundell](https://www.swiftbysundell.com) | Deep dives on Swift topics |

---

## License

MIT — Feel free to use for interview preparation.
