# Testing Challenges

## Challenge 1: Unit Test ViewModel

**Time:** 25 minutes

### Requirements

1. Create a simple ViewModel with @Published properties
2. Write unit tests for property changes
3. Test async methods with expectations
4. Verify notifications are sent

### ViewModel to Test

```swift
@MainActor
class CounterViewModel: ObservableObject {
    @Published var count: Int = 0
    
    func increment() {
        count += 1
    }
    
    func decrement() {
        count -= 1
    }
}
```

### Expected Tests

```swift
func test_increment() {
    let vm = CounterViewModel()
    vm.increment()
    XCTAssertEqual(vm.count, 1)
}

func test_decrement() {
    let vm = CounterViewModel()
    vm.decrement()
    XCTAssertEqual(vm.count, -1)
}
```

### Evaluation Criteria

- XCTest setup
- @MainActor handling
- Assertion usage

---

## Challenge 2: Mocking Dependencies

**Time:** 35 minutes

### Requirements

1. Create a protocol for API client
2. Create mock implementation
3. Test ViewModel with mock
4. Verify mock is called correctly

### Code to Test

```swift
protocol APIClient {
    func fetchUsers() async throws -> [User]
}

class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func loadUsers() async {
        do {
            users = try await apiClient.fetchUsers()
        } catch {
            users = []
        }
    }
}
```

### Expected Mock

```swift
class MockAPIClient: APIClient {
    var fetchUsersCalled = false
    var usersToReturn: [User] = []
    
    func fetchUsers() async throws -> [User] {
        fetchUsersCalled = true
        return usersToReturn
    }
}
```

### Evaluation Criteria

- Protocol-based design
- Mock implementation
- Verification of calls

---

## Challenge 3: Testing Combine Publishers

**Time:** 30 minutes

### Requirements

1. Create ViewModel with Combine publishers
2. Test publisher emissions
3. Use XCTestExpectation for async
4. Verify operator behavior

### Code to Test

```swift
class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var results: [String] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $query
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] query in
                self?.results = [query]
            }
            .store(in: &cancellables)
    }
}
```

### Evaluation Criteria

- Testing Combine streams
- XCTestExpectation usage
- Cancellable management

---

## Challenge 4: UI Testing Basics

**Time:** 40 minutes

### Requirements

1. Create a simple login screen
2. Write UI test for successful login
3. Write UI test for failed login
4. Verify navigation after login

### App to Test

```swift
struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @State private var showError = false
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            
            Button("Login") {
                if email == "test@test.com" && password == "password" {
                    isLoggedIn = true
                } else {
                    showError = true
                }
            }
            
            if isLoggedIn {
                Text("Welcome!")
            }
            
            if showError {
                Text("Invalid credentials")
            }
        }
    }
}
```

### Expected UI Test

```swift
func test_successfulLogin() {
    app.textFields["email"].tap()
    app.textFields["email"].typeText("test@test.com")
    app.secureTextFields["password"].typeText("password")
    app.buttons["Login"].tap()
    
    XCTAssertTrue(app.staticTexts["Welcome!"].exists)
}
```

### Evaluation Criteria

- XCUIApplication usage
- Element queries
- Assertions for UI state

---

## Challenge 5: Snapshot Testing

**Time:** 30 minutes

### Requirements

1. Install SnapshotTesting package
2. Create a view to test
3. Write snapshot test
4. Update snapshot when design changes

### View to Test

```swift
struct UserCard: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(user.name)
                .font(.headline)
            Text(user.email)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 4)
    }
}
```

### Expected Test

```swift
func test_userCardSnapshot() {
    let user = User(name: "John Doe", email: "john@example.com")
    let view = UserCard(user: user)
        .frame(width: 300)
    
    assertSnapshot(matching: view, as: .image)
}
```

### Evaluation Criteria

- SnapshotTesting setup
- View configuration for testing
- Snapshot management

---

## Challenge 6: Testing Error Handling

**Time:** 25 minutes

### Requirements

1. Create ViewModel that handles errors
2. Test success path
3. Test error path
3. Verify error state is set correctly

### Code to Test

```swift
enum APIError: Error {
    case network
    case unauthorized
    case server
}

class DataViewModel: ObservableObject {
    @Published var data: String?
    @Published var error: APIError?
    @Published var isLoading = false
    
    func fetchData() async {
        isLoading = true
        do {
            data = try await fetchFromAPI()
            error = nil
        } catch let error as APIError {
            self.error = error
            data = nil
        } catch {
            self.error = .server
            data = nil
        }
        isLoading = false
    }
    
    private func fetchFromAPI() async throws -> String {
        // Implementation
        return "Data"
    }
}
```

### Evaluation Criteria

- Error type testing
- State verification
- Multiple error scenarios

---

## Solutions

Reference solutions are in the `solutions/` directory.
