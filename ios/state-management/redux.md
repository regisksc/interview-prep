# Redux Pattern in Swift

Redux implements unidirectional data flow — state changes are predictable because they flow one way.

---

## Core Principles

1. **Single source of truth** — One app state
2. **State is read-only** — Only changed by dispatching actions
3. **Changes via pure functions** — Reducers transform state

---

## Basic Implementation

### State

```swift
struct AppState {
    var users: [User] = []
    var isLoading = false
    var error: String?
    var filter: UserFilter = .all
    
    enum UserFilter: String {
        case all, active, inactive
    }
}
```

### Actions

```swift
enum Action {
    // User actions
    case loadUsers
    case usersLoaded([User])
    case usersFailed(String)
    
    // Filter actions
    case setFilter(UserFilter)
    
    // Navigation actions
    case navigateToUserDetail(String)  // userId
}
```

### Reducer

```swift
func appReducer(state: AppState, action: Action) -> AppState {
    var newState = state
    
    switch action {
    case .loadUsers:
        newState.isLoading = true
        newState.error = nil
        
    case .usersLoaded(let users):
        newState.users = users
        newState.isLoading = false
        
    case .usersFailed(let error):
        newState.error = error
        newState.isLoading = false
        
    case .setFilter(let filter):
        newState.filter = filter
        
    case .navigateToUserDetail(let userId):
        // Handle navigation state
        break
    }
    
    return newState
}
```

### Store

```swift
class Store: ObservableObject {
    @Published private(set) var state: AppState
    
    private let reducer: (AppState, Action) -> AppState
    
    init(
        initialState: AppState = AppState(),
        reducer: @escaping (AppState, Action) -> AppState
    ) {
        self.state = initialState
        self.reducer = reducer
    }
    
    func dispatch(_ action: Action) {
        state = reducer(state, action)
    }
    
    // Selectors for derived state
    var filteredUsers: [User] {
        switch state.filter {
        case .all:
            return state.users
        case .active:
            return state.users.filter { $0.isActive }
        case .inactive:
            return state.users.filter { !$0.isActive }
        }
    }
}
```

---

## Usage in SwiftUI

```swift
// Setup in App
@main
struct MyApp: App {
    @StateObject private var store = Store(reducer: appReducer)
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}

// View
struct UserListView: View {
    @EnvironmentObject var store: Store
    
    var body: some View {
        Group {
            if store.state.isLoading {
                ProgressView()
            } else if let error = store.state.error {
                ErrorView(error: error, onRetry: loadUsers)
            } else {
                List(store.filteredUsers) { user in
                    NavigationLink(user.name, destination: UserDetailView(user: user))
                }
                .picker(SegmentedPicker())
            }
        }
        .onAppear { loadUsers() }
    }
    
    private func loadUsers() {
        store.dispatch(.loadUsers)
    }
}
```

---

## Middleware for Side Effects

```swift
// Middleware type
typealias Middleware<State, Action> = (State, Action, @escaping (Action) -> Void) -> Void

// Logging middleware
func loggingMiddleware<State, Action>(
    state: State,
    action: Action,
    dispatch: @escaping (Action) -> Void
) {
    print("Dispatching: \(action)")
    dispatch(action)
}

// Async middleware for API calls
func apiMiddleware(
    state: AppState,
    action: Action,
    dispatch: @escaping (Action) -> Void
) {
    switch action {
    case .loadUsers:
        Task {
            do {
                let users = try await apiClient.fetchUsers()
                dispatch(.usersLoaded(users))
            } catch {
                dispatch(.usersFailed(error.localizedDescription))
            }
        }
    default:
        dispatch(action)
    }
}
```

---

## Testing

```swift
final class StoreTests: XCTestCase {
    func test_loadUsers_success() {
        // Given
        var initialState = AppState()
        let store = Store(initialState: initialState, reducer: appReducer)
        
        // When
        store.dispatch(.loadUsers)
        XCTAssertTrue(store.state.isLoading)
        
        store.dispatch(.usersLoaded([User(id: "1", name: "Test")]))
        
        // Then
        XCTAssertFalse(store.state.isLoading)
        XCTAssertEqual(store.state.users.count, 1)
    }
    
    func test_loadUsers_failure() {
        // Given
        let store = Store(initialState: AppState(), reducer: appReducer)
        
        // When
        store.dispatch(.loadUsers)
        store.dispatch(.usersFailed("Network error"))
        
        // Then
        XCTAssertFalse(store.state.isLoading)
        XCTAssertEqual(store.state.error, "Network error")
    }
}
```

---

## When to Use Redux

**Good fit:**
- Complex state with many transitions
- Need for audit trails or analytics
- Time-travel debugging required
- Team consistency across platforms

**Overkill:**
- Simple CRUD apps
- Small team, single platform
- Most standard iOS apps

**Consider MVVM first** — Redux adds significant boilerplate.
