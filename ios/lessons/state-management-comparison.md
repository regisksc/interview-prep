# State Management: Picking the Right Tool

Five options, one job to do. This is the map for choosing between them.

---

## Start here

If you are building iOS features and want a practical default:

- local view-only state → `@State` or `@Binding`
- shared feature state → `ObservableObject` + `@Published`
- reactive event pipelines → Combine
- complex app-wide state → Redux pattern
- concurrent state → Actor isolation

That is the shortest honest answer.

---

## The normal feature-building flow

Most iOS features follow this path:

1. Decide whether the state is local to one view or shared across features
2. Decide whether the feature is sync, async, or stream-based
3. Choose the state owner (View, ViewModel, Store, Actor)
4. Keep UI focused on rendering and callbacks
5. Move derived values out of the view when they start getting noisy

In practice:

- `@State` if only one view cares
- `ObservableObject` + `@Published` if multiple views share data
- Combine if the tricky part is the event pipeline itself
- Redux if you need predictable state transitions or time-travel debugging

---

## Quick decision ladder

```
Is this only local view state?
  → @State or @Binding

Is this a shared feature state with multiple views?
  → ObservableObject + @Published

Do you need debounce, cancellation, or multi-stream composition?
  → Combine

Do you want explicit state transitions and auditability?
  → Redux pattern

Is this concurrent state accessed from multiple threads?
  → Actor isolation
```

---

## The landscape

| | @State/@Binding | ObservableObject | Combine | Redux | Actor |
|---|---|---|---|---|---|
| **Mental model** | Local view storage | Class-based observable | Reactive stream pipeline | Unidirectional data flow | Thread-safe isolated state |
| **Scope** | Single view | Shared views | Event pipelines | Global app state | Concurrent domains |
| **Boilerplate** | Minimal | Low | Medium | High | Low |
| **Learning curve** | Low | Low | Medium-High | High | Medium |
| **Best for** | Simple UI state | MVVM features | Complex async flows | Complex apps, debugging | Thread-safe state |

---

## Each tool in depth

### @State and @Binding

`@State` is **local view storage** — source of truth for a single SwiftUI view. SwiftUI manages the storage and triggers view updates when it changes.

```swift
struct CounterView: View {
    @State private var count = 0
    
    var body: some View {
        Text("Count: \(count)")
            .onTapGesture { count += 1 }
    }
}
```

`@Binding` creates a **two-way connection** between parent and child views — the child can read and modify the parent's state.

```swift
struct ParentView: View {
    @State private var count = 0
    
    var body: some View {
        ChildView(count: $count)
    }
}

struct ChildView: View {
    @Binding var count: Int
    
    var body: some View {
        Button("Increment") { count += 1 }
    }
}
```

**Pros**
- Zero boilerplate for local state
- Automatic view updates
- Type-safe, compile-time checked

**Cons**
- Only works in SwiftUI views (structs)
- Cannot share across unrelated views
- Not suitable for business logic

**When to use:**
- Toggle switches
- Form field values
- Animation triggers
- Local UI flags (isLoading, showError)

---

### ObservableObject + @Published

`ObservableObject` is the **MVVM backbone** — a class that notifies views when its `@Published` properties change.

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

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        List(viewModel.items, id: \.self) { item in
            Text(item)
        }
        .onAppear { viewModel.loadItems() }
    }
}
```

**@StateObject vs @ObservedObject:**
- `@StateObject`: You create and own the lifecycle (like `init`)
- `@ObservedObject`: Someone else owns it, you're borrowing (like a parameter)

```swift
// Correct: @StateObject for owned view models
struct ParentView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        ChildView(viewModel: viewModel)  // pass as @ObservedObject
    }
}

struct ChildView: View {
    @ObservedObject var viewModel: ViewModel  // borrowed reference
    
    var body: some View {
        Text(viewModel.items.count.description)
    }
}
```

**Pros**
- Clean MVVM separation
- Works with UIKit and SwiftUI
- Easy to test with mocks
- Supports dependency injection

**Cons**
- Reference type (can have retain cycles)
- No built-in async state handling
- Manual cancellation of subscriptions

**When to use:**
- Feature-level state (user profile, shopping cart)
- Data loading with loading/error states
- Shared state across multiple views

---

### Combine

Combine is Apple's **reactive framework** for handling asynchronous events over time. It excels at transforming, filtering, and composing event streams.

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
        Future { promise in
            // async search
            promise(.success([]))
        }
        .eraseToAnyPublisher()
    }
}
```

**Key operators:**

| Operator | What it does | Common use |
|----------|-------------|------------|
| `debounce` | Waits for pause in emissions | Search input |
| `removeDuplicates` | Skips identical values | Filter changes |
| `flatMap` | Transforms to publisher, merges results | API calls |
| `combineLatest` | Emits when any upstream emits | Form validation |
| `merge` | Merges multiple same-type publishers | Parallel requests |
| `switchToLatest` | Cancels previous, uses latest | Typeahead search |
| `retry` | Retries on error | Network resilience |

**Pros**
- Powerful event transformation
- Built-in operators for common patterns
- Type-safe, compile-time checked
- Integrates with UIKit and SwiftUI

**Cons**
- Steep learning curve (functional reactive)
- Verbose error handling
- Debugging can be challenging
- More boilerplate than simple callbacks

**When to use:**
- Search with debounce and cancellation
- Form validation with multiple fields
- Chaining dependent API calls
- Real-time data synchronization

---

### Redux Pattern

Redux implements **unidirectional data flow** — state changes are predictable because they flow one way: Action → Reducer → State → View.

```swift
// State
struct AppState {
    var users: [User] = []
    var isLoading = false
    var error: String?
    var filter: UserFilter = .all
}

// Actions (sealed enum for exhaustiveness)
enum Action {
    case loadUsers
    case usersLoaded([User])
    case usersFailed(String)
    case setFilter(UserFilter)
}

// Reducer (pure function)
func appReducer(state: AppState, action: Action) -> AppState {
    var newState = state
    
    switch action {
    case .loadUsers:
        newState.isLoading = true
    case .usersLoaded(let users):
        newState.users = users
        newState.isLoading = false
    case .usersFailed(let error):
        newState.error = error
        newState.isLoading = false
    case .setFilter(let filter):
        newState.filter = filter
    }
    
    return newState
}

// Store
class Store: ObservableObject {
    @Published private(set) var state: AppState
    
    private let reducer: (AppState, Action) -> AppState
    
    init(initialState: AppState = AppState(), 
         reducer: @escaping (AppState, Action) -> AppState) {
        self.state = initialState
        self.reducer = reducer
    }
    
    func dispatch(_ action: Action) {
        state = reducer(state, action)
    }
}

// Usage
struct UserListView: View {
    @StateObject private var store = Store(reducer: appReducer)
    
    var body: some View {
        Group {
            if store.state.isLoading {
                ProgressView()
            } else {
                List(store.state.users) { user in
                    Text(user.name)
                }
            }
        }
        .onAppear { store.dispatch(.loadUsers) }
    }
}
```

**Pros**
- Predictable state transitions
- Easy to debug (log every action)
- Time-travel debugging possible
- Clear separation of concerns

**Cons**
- Significant boilerplate
- Overkill for simple apps
- Learning curve for beginners
- Can lead to "action soup"

**When to use:**
- Complex apps with many state transitions
- Need for audit trails or analytics
- Team consistency across platforms
- Apps requiring undo/redo functionality

---

### Actor Isolation

Actors provide **thread-safe state** by isolating mutable state to a single concurrent domain. Swift 5.5+ concurrency feature.

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

**Why actors matter:** They automatically prevent data races at compile time. Two tasks cannot simultaneously modify the actor's state.

```swift
actor UserManager {
    private var users: [String: User] = [:]
    
    func getUser(id: String) async -> User? {
        users[id]
    }
    
    func addUser(_ user: User) async {
        users[user.id] = user
    }
    
    func getAllUsers() async -> [User] {
        Array(users.values)
    }
}

// Safe concurrent access
let manager = UserManager()
await Task.group {
    await manager.addUser(user1)
    await manager.addUser(user2)
    let all = await manager.getAllUsers()
}
```

**Pros**
- Compile-time thread safety
- No manual locks or queues
- Integrates with async/await
- Clear ownership of mutable state

**Cons**
- Swift 5.5+ only
- Actor isolation can cause unexpected `await` requirements
- Not suitable for UI state (must be on MainActor anyway)
- Can introduce performance overhead

**When to use:**
- Shared state accessed from multiple async contexts
- Caching layers
- Rate limiters or throttles
- Background data synchronization

---

## Decision scenarios

### Scenario 1: Search bar with live results

**Problem:** User types, you need to debounce, call API, handle loading/error, and cancel in-flight requests when new input arrives.

**Solution:** Combine + ObservableObject

```swift
class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var results: [Product] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(apiClient: APIClient) {
        $query
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { $0.count >= 2 }
            .flatMap { query in
                self.search(query, apiClient: apiClient)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                switch result {
                case .success(let products):
                    self?.results = products
                    self?.isLoading = false
                case .failure(let error):
                    self?.error = error.localizedDescription
                    self?.isLoading = false
                }
            }
            .store(in: &cancellables)
    }
    
    private func search(_ query: String, apiClient: APIClient) -> AnyPublisher<[Product], Error> {
        apiClient.search(query: query)
    }
}
```

---

### Scenario 2: User profile with edit capability

**Problem:** Multiple views need to read and update user data. Changes should persist and sync across the app.

**Solution:** ObservableObject + @Published (MVVM)

```swift
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var error: String?
    @Published var isEditing = false
    
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    @MainActor
    func loadUser() async {
        isLoading = true
        do {
            user = try await repository.fetchCurrentUser()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
    
    @MainActor
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
```

---

### Scenario 3: Shopping cart across app

**Problem:** Cart is accessed from product list, detail views, and checkout. Needs to persist and sync in real-time.

**Solution:** Redux or ObservableObject with singleton store

```swift
// Redux approach
struct CartState {
    var items: [CartItem] = []
    var total: Decimal {
        items.reduce(0) { $0 + $1.price * Decimal($1.quantity) }
    }
}

enum CartAction {
    case addItem(CartItem)
    case removeItem(String)  // productId
    case updateQuantity(String, Int)
    case clear
}

func cartReducer(state: CartState, action: CartAction) -> CartState {
    var newState = state
    
    switch action {
    case .addItem(let item):
        if let index = newState.items.firstIndex(where: { $0.productId == item.productId }) {
            newState.items[index].quantity += 1
        } else {
            newState.items.append(item)
        }
    case .removeItem(let productId):
        newState.items.removeAll { $0.productId == productId }
    case .updateQuantity(let productId, let quantity):
        if let index = newState.items.firstIndex(where: { $0.productId == productId }) {
            if quantity <= 0 {
                newState.items.remove(at: index)
            } else {
                newState.items[index].quantity = quantity
            }
        }
    case .clear:
        newState.items = []
    }
    
    return newState
}
```

---

### Scenario 4: Image cache with concurrent access

**Problem:** Multiple async tasks need to read/write to image cache. Must be thread-safe.

**Solution:** Actor

```swift
actor ImageCache {
    private var cache: [String: UIImage] = [:]
    private let maxCount = 100
    private let maxMemory: Int64 = 100 * 1024 * 1024  // 100MB
    
    func getImage(forKey key: String) -> UIImage? {
        cache[key]
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache[key] = image
        trimIfNeeded()
    }
    
    private func trimIfNeeded() {
        if cache.count > maxCount {
            let sorted = cache.sorted { $0.value.jpegData(compressionQuality: 0.5)?.count ?? 0 < $1.value.jpegData(compressionQuality: 0.5)?.count ?? 0 }
            cache.removeValue(forKey: sorted.first?.key ?? "")
        }
    }
}
```

---

## How to answer "Which state management do you use?"

> "I evaluate based on the scope and complexity of the feature:
>
> For local UI state like toggles or form fields, I use `@State` — it's built for that.
>
> For feature-level state shared across views, I reach for `ObservableObject` with `@Published` — it's the MVVM standard and works well with testing.
>
> If the feature involves complex event pipelines — like search with debounce, cancellation, or combining multiple streams — I layer Combine on top.
>
> For app-wide state with complex transitions or when we need auditability, I consider Redux for its predictability.
>
> And for concurrent state that needs thread safety, I use actors — they prevent data races at compile time.
>
> The key is matching the tool to the problem, not forcing one pattern everywhere."

---

## Quick reference

| State Type | Recommended Approach |
|------------|---------------------|
| Toggle, switch | `@State` |
| Form field | `@State` + `@Binding` |
| Loading indicator | `@Published` in ViewModel |
| API data (users, products) | `ObservableObject` + async/await |
| Search with debounce | Combine |
| Form validation | Combine (`combineLatest`) |
| Shopping cart | Redux or singleton `ObservableObject` |
| Image cache | Actor |
| User session | `ObservableObject` + Keychain |
| App theme/settings | `@AppStorage` or `ObservableObject` |
