# Actor-Isolated State

Actors provide thread-safe state management by isolating mutable state to a single concurrent domain.

---

## What is an Actor?

An actor is a reference type that automatically isolates its mutable state from concurrent access.

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
let newValue = await counter.increment()  // Must await
```

---

## Why Actors?

### Without Actor (Data Race Risk)

```swift
class Counter {
    private var value = 0
    
    func increment() {
        value += 1  // Not thread-safe!
    }
}

// Concurrent access can cause data races
Task {
    for _ in 0..<1000 {
        counter.increment()
    }
}
Task {
    for _ in 0..<1000 {
        counter.increment()
    }
}
// Final value may not be 2000
```

### With Actor (Thread-Safe)

```swift
actor Counter {
    private var value = 0
    
    func increment() {
        value += 1  // Automatically serialized
    }
    
    func getValue() async -> Int {
        value
    }
}

// Concurrent access is safe
let counter = Counter()
await Task.group {
    for _ in 0..<1000 {
        await counter.increment()
    }
    for _ in 0..<1000 {
        await counter.increment()
    }
}
// Final value is guaranteed to be 2000
```

---

## Real-World Examples

### Image Cache

```swift
actor ImageCache {
    private var cache: [String: UIImage] = [:]
    private let maxCount = 100
    
    func getImage(forKey key: String) -> UIImage? {
        cache[key]
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache[key] = image
        if cache.count > maxCount {
            cache.removeValue(forKey: cache.keys.first ?? "")
        }
    }
    
    func clear() {
        cache.removeAll()
    }
}

// Usage
let cache = ImageCache()
let image = await cache.getImage(forKey: "avatar_123")
await cache.setImage(avatarImage, forKey: "avatar_123")
```

### Rate Limiter

```swift
actor RateLimiter {
    private var lastCallTime: Date = .distantPast
    private let minimumInterval: TimeInterval
    
    init(minimumInterval: TimeInterval = 1.0) {
        self.minimumInterval = minimumInterval
    }
    
    func execute<T>(_ block: @escaping () async throws -> T) async rethrows -> T {
        let now = Date()
        let timeSinceLastCall = now.timeIntervalSince(lastCallTime)
        
        if timeSinceLastCall < minimumInterval {
            let delay = minimumInterval - timeSinceLastCall
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        lastCallTime = Date()
        return try await block()
    }
}

// Usage
let rateLimiter = RateLimiter(minimumInterval: 1.0)
await rateLimiter.execute {
    await apiClient.makeRequest()
}
```

### User Session Manager

```swift
actor SessionManager {
    private var session: Session?
    private var refreshTask: Task<Session, Error>?
    
    func getSession() async throws -> Session {
        if let session = session, !session.isExpired {
            return session
        }
        
        if let refreshTask = refreshTask {
            return try await refreshTask.value
        }
        
        refreshTask = Task {
            defer { self.refreshTask = nil }
            let newSession = try await apiClient.refreshSession()
            self.session = newSession
            return newSession
        }
        
        return try await refreshTask!.value
    }
    
    func logout() {
        session = nil
        refreshTask?.cancel()
        refreshTask = nil
    }
}
```

---

## Actor Reentrancy

Be aware of reentrancy — other tasks can run between your await points.

```swift
actor Counter {
    var value = 0
    
    func incrementThenCheck() async -> Bool {
        value += 1
        try await Task.sleep(nanoseconds: 1_000_000_000)  // Reentrancy point!
        return value == 1  // May not be true!
    }
}

// Another task can increment between increment and check
```

**Solution:** Minimize await points in critical sections.

```swift
actor Counter {
    var value = 0
    
    func incrementThenCheck() async -> Bool {
        value += 1
        let currentValue = value  // Capture before await
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return currentValue == 1  // Now reliable
    }
}
```

---

## MainActor

`@MainActor` is a global actor that ensures code runs on the main thread.

```swift
@MainActor
class ViewModel: ObservableObject {
    @Published var data: String = ""
    
    func loadData() async {
        let result = await fetchFromNetwork()  // Runs off main thread
        data = result  // Automatically on main thread
    }
}

// Or for individual functions
@MainActor
func updateUI() {
    // Safe UI updates
}
```

---

## Testing Actors

```swift
final class ImageCacheTests: XCTestCase {
    var cache: ImageCache!
    
    override func setUp() {
        cache = ImageCache()
    }
    
    func test_setAndGetImage() async {
        let image = UIImage()
        await cache.setImage(image, forKey: "test")
        
        let retrieved = await cache.getImage(forKey: "test")
        XCTAssertNotNil(retrieved)
    }
    
    func test_cacheLimit() async {
        for i in 0..<150 {
            await cache.setImage(UIImage(), forKey: "image_\(i)")
        }
        
        let count = await cache.cache.count
        XCTAssertEqual(count, 100)  // maxCount
    }
}
```

---

## When to Use Actors

**Good fit:**
- Shared mutable state across async contexts
- Caching layers
- Rate limiters or throttles
- Background data synchronization
- Thread-safe counters or metrics

**Not needed:**
- UI state (use @MainActor)
- Value types (structs are already thread-safe when immutable)
- Read-only data (use let constants)

---

## Comparison with Other Approaches

| Approach | Thread Safety | Complexity | Best For |
|----------|--------------|------------|----------|
| Actor | Compile-time | Low | Shared mutable state |
| Dispatch Queue | Runtime | Medium | Legacy code, GCD workflows |
| Locks (NSLock) | Runtime | High | Fine-grained control |
| @MainActor | Compile-time | Low | UI state |

---

## Best Practices

1. **Keep actor boundaries small** — One responsibility per actor
2. **Avoid holding locks across await** — Can cause deadlocks
3. **Use `nonisolated` for read-only access** — When safe
4. **Be aware of reentrancy** — Capture state before await points
5. **Prefer actors over locks** — Compile-time safety is better
