# Observable Pattern with @Published

The Observable pattern is the foundation of MVVM in iOS — classes notify observers when their state changes.

---

## Core Components

### ObservableObject Protocol

```swift
protocol ObservableObject {
    associatedtype ObjectWillChangePublisher : Publisher
    var objectWillChange: ObjectWillChangePublisher { get }
}
```

### @Published Property Wrapper

```swift
@propertyWrapper
struct Published<Value> {
    var wrappedValue: Value
    var projectedValue: Publisher<Value, Never>
}
```

---

## Basic Usage

```swift
class Counter: ObservableObject {
    @Published var count = 0
    
    func increment() {
        count += 1  // Automatically notifies observers
    }
}

// In SwiftUI
struct CounterView: View {
    @StateObject private var counter = Counter()
    
    var body: some View {
        Text("Count: \(counter.count)")
            .onTapGesture {
                counter.increment()
            }
    }
}
```

---

## Manual Notification

Sometimes you need to notify before the change:

```swift
class ViewModel: ObservableObject {
    var items: [String] = [] {
        willSet {
            objectWillChange.send()
        }
    }
    
    // Or for more complex scenarios
    func updateItems() {
        objectWillChange.send()
        // Multiple changes
        items.append("New")
        items.removeFirst()
    }
}
```

---

## Combining Multiple Published Properties

```swift
class FormViewModel: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var isValid = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Combine multiple published properties
        Publishers.CombineLatest($username, $email)
            .map { username, email in
                !username.isEmpty && isValidEmail(email)
            }
            .assign(to: &$isValid)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        // Validation logic
        return true
    }
}
```

---

## Testing ObservableObject

```swift
final class CounterTests: XCTestCase {
    var counter: Counter!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        counter = Counter()
        cancellables = []
    }
    
    func test_incrementNotifiesObservers() {
        let expectation = XCTestExpectation(description: "Notified")
        var notifyCount = 0
        
        counter.objectWillChange
            .sink { _ in
                notifyCount += 1
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        counter.increment()
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(notifyCount, 1)
        XCTAssertEqual(counter.count, 1)
    }
}
```

---

## Common Pitfalls

### Retain Cycles

```swift
// ❌ WRONG: Strong self capture
class ViewModel: ObservableObject {
    @Published var data: String = ""
    
    init() {
        $data.sink { [self] newValue in
            // self is strongly captured → retain cycle
            process(newValue)
        }
    }
}

// ✅ CORRECT: Weak self
class ViewModel: ObservableObject {
    @Published var data: String = ""
    
    init() {
        $data.sink { [weak self] newValue in
            self?.process(newValue)
        }
    }
}
```

### Not Specifying Scheduler

```swift
// ❌ WRONG: May update UI on background thread
apiCall()
    .assign(to: &$data)

// ✅ CORRECT: Specify main scheduler
apiCall()
    .receive(on: DispatchQueue.main)
    .assign(to: &$data)
```

---

## Best Practices

1. **Use @StateObject for owned ViewModels** — Creates once, keeps alive
2. **Use @ObservedObject for borrowed ViewModels** — Passed from parent
3. **Use @Published for UI-triggering state** — Loading, error, data
4. **Don't @Published computed properties** — They don't store values
5. **Combine related changes** — Use `objectWillChange.send()` for batch updates
