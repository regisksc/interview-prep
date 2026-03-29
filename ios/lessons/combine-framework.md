# Combine Framework: Complete Guide

Combine is Apple's reactive framework for handling asynchronous events over time. It provides a declarative Swift API for processing values over time.

---

## Core Concepts

### Publishers & Subscribers

**Publisher:** A type that emits values over time.

```swift
protocol Publisher {
    associatedtype Output
    associatedtype Failure: Error
    
    func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure
}
```

**Subscriber:** A type that receives values from a publisher.

```swift
protocol Subscriber {
    associatedtype Input
    associatedtype Failure: Error
    
    func receive(subscription: Subscription)
    func receive(_ input: Input) -> Subscribers.Demand
    func receive(completion: Subscribers.Completion<Failure>)
}
```

**Basic example:**

```swift
let publisher = Just("Hello")
let subscriber = Subscribers.Sink<String, Never>(
    receiveCompletion: { completion in
        print("Completed: \(completion)")
    },
    receiveValue: { value in
        print("Received: \(value)")
    }
)

publisher.subscribe(subscriber)
// Output: Received: Hello
//         Completed: finished
```

**Simplified with `sink`:**

```swift
let cancellable = Just("Hello")
    .sink(
        receiveCompletion: { print("Completed: \($0)") },
        receiveValue: { print("Received: \($0)") }
    )
```

---

## Creating Publishers

### Just

Emits a single value and completes.

```swift
let publisher = Just(42)
publisher.sink { print($0) }  // 42
```

### Future

Emits a single value asynchronously.

```swift
func fetchUser(id: String) -> Future<User, Error> {
    Future { promise in
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                promise(.failure(error))
                return
            }
            let user = try? JSONDecoder().decode(User.self, from: data!)
            promise(.success(user!))
        }.resume()
    }
}
```

### Publishers.Sequence

Emits values from a sequence.

```swift
let publisher = Publishers.Sequence(sequence: [1, 2, 3, 4, 5])
publisher.sink { print($0) }  // 1, 2, 3, 4, 5
```

### Timer

Emits values at regular intervals.

```swift
let timer = Timer.publish(every: 1.0, on: .main, in: .common)
    .autoconnect()

timer.sink { date in
    print("Tick: \(date)")
}
```

### Subject

Manual control over emitted values.

```swift
let subject = PassthroughSubject<String, Never>()

subject.sink { print($0) }

subject.send("Hello")  // Hello
subject.send("World")  // World
subject.send(completion: .finished)
```

### @Published

Property wrapper that creates a publisher.

```swift
class ViewModel: ObservableObject {
    @Published var count = 0
    @Published var items: [String] = []
}

// Access the publisher
viewModel.$count
    .sink { print("Count changed to \($0)") }
```

---

## Key Operators

### Transforming Operators

**map:** Transform each element.

```swift
Just("42")
    .map { Int($0) ?? 0 }
    .sink { print($0) }  // 42
```

**flatMap:** Transform to another publisher.

```swift
Just("userId")
    .flatMap { id in
        fetchUser(id: id)  // Returns Future<User, Error>
    }
    .sink { print($0.name) }
```

**mapError:** Transform error type.

```swift
apiCall()
    .mapError { error -> MyError in
        switch error {
        case is URLError: return .network
        case is DecodingError: return .parsing
        default: return .unknown
        }
    }
```

### Filtering Operators

**filter:** Only emit values matching predicate.

```swift
Publishers.Sequence(sequence: [1, 2, 3, 4, 5, 6])
    .filter { $0 % 2 == 0 }
    .sink { print($0) }  // 2, 4, 6
```

**removeDuplicates:** Skip identical consecutive values.

```swift
Publishers.Sequence(sequence: ["A", "A", "B", "B", "B", "C"])
    .removeDuplicates()
    .sink { print($0) }  // A, B, C
```

**debounce:** Wait for pause in emissions.

```swift
searchTextField.publisher
    .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
    .sink { query in
        search(query)  // Only called 300ms after user stops typing
    }
```

**throttle:** Limit emission rate.

```swift
scrollPublisher
    .throttle(for: .milliseconds(100), scheduler: RunLoop.main, latest: true)
    .sink { offset in
        updateScrollIndicator(offset)
    }
```

### Combining Operators

**merge:** Combine multiple same-type publishers.

```swift
let merged = Publishers.Merge(
    Just(1),
    Just(2)
)
merged.sink { print($0) }  // 1, 2 (order not guaranteed)
```

**combineLatest:** Emit when any upstream emits.

```swift
Publishers.CombineLatest(emailPublisher, passwordPublisher)
    .map { email, password in
        !email.isEmpty && password.count >= 8
    }
    .assign(to: &$isValid)
```

**zip:** Pair elements from two publishers.

```swift
Publishers.Zip(
    Publishers.Sequence(sequence: [1, 2, 3]),
    Publishers.Sequence(sequence: ["A", "B", "C"])
)
.sink { print($0) }  // (1, A), (2, B), (3, C)
```

### Error Handling Operators

**catch:** Recover from errors.

```swift
apiCall()
    .catch { error in
        Just(fallbackValue)  // Emit fallback on error
    }
    .sink { print($0) }
```

**retry:** Retry on error.

```swift
apiCall()
    .retry(3)  // Retry up to 3 times
    .sink(
        receiveCompletion: { print("Completed: \($0)") },
        receiveValue: { print($0) }
    )
```

**replaceNil:** Replace nil with default.

```swift
optionalPublisher
    .replaceNil(with: defaultValue)
    .sink { print($0) }
```

**replaceEmpty:** Replace empty stream.

```swift
maybeEmptyPublisher
    .replaceEmpty(with: defaultValue)
    .sink { print($0) }
```

### Aggregation Operators

**reduce:** Accumulate values.

```swift
Publishers.Sequence(sequence: [1, 2, 3, 4, 5])
    .reduce(0, +)
    .sink { print($0) }  // 15
```

**collect:** Collect all values into array.

```swift
Publishers.Sequence(sequence: [1, 2, 3])
    .collect()
    .sink { print($0) }  // [1, 2, 3]
```

**scan:** Running reduction.

```swift
Publishers.Sequence(sequence: [1, 2, 3, 4])
    .scan(0, +)
    .sink { print($0) }  // 1, 3, 6, 10
```

---

## Real-World Patterns

### Search with Debounce

```swift
class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var results: [Product] = []
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $query
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .filter { $0.count >= 2 }
            .flatMap { [weak self] query -> AnyPublisher<[Product], Never> in
                self?.searchProducts(query) ?? Just([]).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$results)
    }
    
    private func searchProducts(_ query: String) -> AnyPublisher<[Product], Never> {
        Future { promise in
            // API call
            promise(.success([]))
        }
        .catch { _ in Just([]) }
        .eraseToAnyPublisher()
    }
}
```

### Form Validation

```swift
class SignUpViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isValid = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Publishers.CombineLatest3($email, $password, $confirmPassword)
            .map { email, password, confirm in
                self.isValidEmail(email) &&
                password.count >= 8 &&
                password == confirm
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$isValid)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let regex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
}
```

### Chained API Calls

```swift
func login(email: String, password: String) -> AnyPublisher<User, Error> {
    // 1. Get auth token
    apiClient.login(email: email, password: password)
        // 2. Use token to fetch user profile
        .flatMap { [weak self] token -> AnyPublisher<User, Error> in
            self?.apiClient.getUser(token: token) ?? Fail(error: AuthError.unknown).eraseToAnyPublisher()
        }
        // 3. Cache user locally
        .handleEvents(receiveOutput: { [weak self] user in
            self?.cacheUser(user)
        })
        .eraseToAnyPublisher()
}
```

### Retry with Exponential Backoff

```swift
func fetchWithRetry<T>(publisher: AnyPublisher<T, Error>) -> AnyPublisher<T, Error> {
    publisher
        .retry(3)
        .catch { error -> AnyPublisher<T, Error> in
            // Could add delay here for backoff
            Fail(error: error).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
}
```

### Loading State Management

```swift
class ViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func loadItems() {
        isLoading = true
        error = nil
        
        apiClient.fetchItems()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.error = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] items in
                    self?.items = items
                }
            )
            .store(in: &cancellables)
    }
}
```

### Cancellation

```swift
class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var results: [Product] = []
    
    private var searchCancellable: AnyCancellable?
    
    init() {
        $query
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] query in
                self?.performSearch(query)
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(_ query: String) {
        // Cancel previous search
        searchCancellable?.cancel()
        
        // Start new search
        searchCancellable = apiClient.search(query: query)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                self?.results = results
            }
    }
}
```

---

## SwiftUI Integration

### @Published to UI

```swift
class ViewModel: ObservableObject {
    @Published var items: [String] = []
    @Published var isLoading = false
}

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else {
                List(viewModel.items, id: \.self) { item in
                    Text(item)
                }
            }
        }
        .onAppear {
            viewModel.loadItems()
        }
    }
}
```

### .onReceive

```swift
struct TimerView: View {
    @State private var count = 0
    
    var body: some View {
        Text("Seconds: \(count)")
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                count += 1
            }
    }
}
```

### .assign(to:)

```swift
class ViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var filteredItems: [Item] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .map { text in
                items.filter { $0.name.contains(text) }
            }
            .assign(to: &$filteredItems)
    }
}
```

---

## Memory Management

### Store Cancellables

```swift
class ViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        publisher
            .sink { }
            .store(in: &cancellables)
    }
    
    deinit {
        // Cancellables automatically cancelled
    }
}
```

### Weak Self

```swift
publisher
    .sink { [weak self] value in
        self?.handle(value)
    }
```

### Automatic Cancellation

```swift
// .assign automatically cancels on deallocation
publisher
    .assign(to: &$publishedProperty)

// .store(in:) cancels when container deallocates
publisher
    .sink { }
    .store(in: &cancellables)
```

---

## Testing Combine

### Testing with Expectations

```swift
func testSearchDebounce() {
    let expectation = XCTestExpectation(description: "Search completed")
    var receivedQuery: String?
    
    viewModel.$results
        .dropFirst()  // Skip initial empty state
        .sink { results in
            receivedQuery = results.first?.name
            expectation.fulfill()
        }
        .store(in: &cancellables)
    
    viewModel.query = "Test"
    
    wait(for: [expectation], timeout: 1.0)
    
    XCTAssertEqual(receivedQuery, "Test Product")
}
```

### Testing with XCTest

```swift
func testViewModelLoadItems() {
    let mockRepo = MockRepository()
    mockRepo.itemsToReturn = [Item(name: "Test")]
    
    let viewModel = ViewModel(repository: mockRepo)
    
    let expectation = XCTestExpectation(description: "Items loaded")
    
    viewModel.$items
        .dropFirst()
        .sink { items in
            XCTAssertEqual(items.count, 1)
            XCTAssertEqual(items[0].name, "Test")
            expectation.fulfill()
        }
        .store(in: &cancellables)
    
    viewModel.loadItems()
    
    wait(for: [expectation], timeout: 1.0)
}
```

---

## Common Pitfalls

### Forgetting to Store Cancellable

```swift
// ❌ WRONG: Publisher cancelled immediately
publisher.sink { }

// ✅ CORRECT: Store cancellable
cancellable = publisher.sink { }
// or
publisher.sink { }.store(in: &cancellables)
```

### Not Handling Errors

```swift
// ❌ WRONG: Silent failure
apiCall().sink { value in
    print(value)
}

// ✅ CORRECT: Handle completion
apiCall().sink(
    receiveCompletion: { print("Completed: \($0)") },
    receiveValue: { print($0) }
)
```

### Retain Cycles

```swift
// ❌ WRONG: Strong self capture
publisher.sink { [self] value in
    handle(value)  // Retain cycle if publisher holds self
}

// ✅ CORRECT: Weak self
publisher.sink { [weak self] value in
    self?.handle(value)
}
```

### Threading Issues

```swift
// ❌ WRONG: UI update on background thread
apiCall()
    .sink { value in
        self.updateUI(value)  // May be on background thread
    }

// ✅ CORRECT: Specify scheduler
apiCall()
    .receive(on: DispatchQueue.main)
    .sink { value in
        self.updateUI(value)  // Always on main thread
    }
```

---

## Quick Reference

| Operator | Purpose | Example |
|----------|---------|---------|
| `map` | Transform values | `.map { $0.uppercased() }` |
| `flatMap` | Transform to publisher | `.flatMap { fetch($0) }` |
| `filter` | Filter values | `.filter { $0 > 0 }` |
| `debounce` | Wait for pause | `.debounce(for: .milliseconds(300))` |
| `throttle` | Limit rate | `.throttle(for: .seconds(1))` |
| `removeDuplicates` | Skip duplicates | `.removeDuplicates()` |
| `combineLatest` | Combine streams | `.combineLatest($a, $b)` |
| `merge` | Merge publishers | `.merge(p1, p2)` |
| `catch` | Handle errors | `.catch { _ in Just(fallback) }` |
| `retry` | Retry on error | `.retry(3)` |
| `reduce` | Accumulate | `.reduce(0, +)` |
| `collect` | Collect to array | `.collect()` |

---

## When to Use Combine

**Good fit:**
- Search with debounce
- Form validation with multiple fields
- Chained API calls
- Real-time data synchronization
- Complex event composition

**Overkill:**
- Simple async/await calls
- Single value fetch
- Basic state updates
- One-off network requests

**Rule of thumb:** Use Combine when you need to transform, filter, or compose multiple event streams over time. For simple async operations, async/await is cleaner.
