# Combine Challenges

## Challenge 1: Basic Publisher

**Time:** 15 minutes

### Requirements

1. Create a publisher that emits numbers 1-5
2. Subscribe using sink
3. Print each value received
4. Store the cancellable

### Starter Code

```swift
import Combine
import Foundation

var cancellables = Set<AnyCancellable>()

// TODO: Create publisher and subscribe

```

### Expected Output

```
Received: 1
Received: 2
Received: 3
Received: 4
Received: 5
Completed: finished
```

### Evaluation Criteria

- Publisher creation
- Sink subscription
- Cancellable storage

---

## Challenge 2: Transform Operators

**Time:** 20 minutes

### Requirements

1. Create a publisher from array ["1", "2", "3", "4", "5"]
2. Use map to convert strings to integers
3. Use filter to keep only even numbers
4. Print the results

### Expected Output

```
Received: 2
Received: 4
```

### Evaluation Criteria

- map operator
- filter operator
- Operator chaining

---

## Challenge 3: Debounce Search

**Time:** 30 minutes

### Requirements

1. Create a @Published property for search query
2. Use debounce (300ms) on the publisher
3. Remove duplicate queries
4. Simulate search by printing "Searching: query"

### Starter Code

```swift
class SearchViewModel: ObservableObject {
    @Published var query = ""
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // TODO: Implement debounce logic
    }
}

// Simulate typing
let vm = SearchViewModel()
vm.query = "S"
vm.query = "Sw"
vm.query = "Swi"
vm.query = "Swif"
vm.query = "Swift"
```

### Expected Output

```
(300ms delay)
Searching: Swift
```

### Evaluation Criteria

- debounce operator
- removeDuplicates
- @Published usage

---

## Challenge 4: CombineLatest for Form Validation

**Time:** 25 minutes

### Requirements

1. Create two @Published properties: email and password
2. Use combineLatest to validate both fields
3. Email must contain "@"
4. Password must be at least 8 characters
5. Output a boolean for form validity

### Expected Output

```
Email: "test" → Valid: false
Email: "test@example.com" → Valid: false (password too short)
Password: "password123" → Valid: true
```

### Evaluation Criteria

- combineLatest usage
- Multiple publisher validation
- Computed validity

---

## Challenge 5: FlatMap for API Chaining

**Time:** 35 minutes

### Requirements

1. Create a publisher that emits a user ID
2. Use flatMap to fetch user details
3. Then use flatMap again to fetch user's posts
4. Handle errors at each step

### API Simulation

```swift
func fetchUser(id: String) -> Future<User, Error>
func fetchPosts(userId: String) -> Future<[Post], Error>
```

### Expected Output

```
Fetching user: 1
User fetched: John
Fetching posts for: 1
Posts fetched: 5
```

### Evaluation Criteria

- flatMap for chaining
- Error handling
- Multiple async operations

---

## Challenge 6: Retry with Backoff

**Time:** 30 minutes

### Requirements

1. Create a publisher that fails twice then succeeds
2. Use retry to attempt multiple times
3. Add delay between retries (exponential backoff)
4. Track number of attempts

### Expected Output

```
Attempt 1: Failed
(wait 1 second)
Attempt 2: Failed
(wait 2 seconds)
Attempt 3: Success!
```

### Evaluation Criteria

- retry operator
- Delay implementation
- Attempt tracking

---

## Challenge 7: Memory Management

**Time:** 20 minutes

### Requirements

1. Create a ViewModel with a timer publisher
2. Start timer on init
3. Properly cancel on deinit
4. Print deallocation message

### Starter Code

```swift
class ViewModel: ObservableObject {
    @Published var count = 0
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // TODO: Start timer
    }
    
    deinit {
        print("ViewModel deallocated")
    }
}
```

### Expected Behavior

- Timer increments count every second
- ViewModel deallocates when released
- No memory leaks

### Evaluation Criteria

- Proper cancellable storage
- Timer cleanup
- Weak self captures

---

## Solutions

Reference solutions are in the `solutions/` directory.
