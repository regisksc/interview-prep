# Async/Await Challenges

## Challenge 1: Basic Async Function

**Time:** 15 minutes

### Requirements

1. Create an async function that simulates a network delay
2. Function should return a String after 2 seconds
3. Call the function and print the result
4. Handle the function call in a Task

### Starter Code

```swift
import Foundation

// TODO: Create async function here

// TODO: Call function in Task
```

### Expected Output

```
Starting...
(wait 2 seconds)
Result: Hello from async!
```

### Evaluation Criteria

- Correct async/await syntax
- Proper Task usage
- Error handling (optional)

---

## Challenge 2: Multiple Concurrent Tasks

**Time:** 25 minutes

### Requirements

1. Create three async functions that each return an Int after different delays
2. Function 1: Returns 1 after 1 second
3. Function 2: Returns 2 after 2 seconds
4. Function 3: Returns 3 after 3 seconds
5. Call all three concurrently using Task.group
6. Sum the results and print total

### Expected Output

```
Starting all tasks...
Task 1 complete: 1
Task 2 complete: 2
Task 3 complete: 3
Total: 6
Total time: ~3 seconds (not 6)
```

### Evaluation Criteria

- Task.group usage
- Concurrent execution
- Proper awaiting

---

## Challenge 3: MainActor for UI Updates

**Time:** 20 minutes

### Requirements

1. Create a class that fetches data in background
2. Updates a @Published property on main thread
3. Use @MainActor appropriately
4. Simulate with a label text update

### Starter Code

```swift
import Foundation

class ViewModel {
    var data: String = ""
    
    func fetchData() async {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        // TODO: Update data on main thread
        data = "Fetched data"
    }
}
```

### Evaluation Criteria

- @MainActor usage
- Background vs main thread awareness
- Proper isolation

---

## Challenge 4: AsyncSequence

**Time:** 30 minutes

### Requirements

1. Create an AsyncSequence that emits numbers 1-10
2. Each number is emitted after 500ms
3. Use for-await-in to consume the sequence
4. Calculate running sum as numbers arrive

### Expected Output

```
Received: 1, Sum: 1
Received: 2, Sum: 3
Received: 3, Sum: 6
...
Received: 10, Sum: 55
Total time: 5 seconds
```

### Evaluation Criteria

- AsyncSequence implementation
- AsyncIterator
- Proper timing

---

## Challenge 5: Error Handling in Async

**Time:** 25 minutes

### Requirements

1. Create an async function that can throw errors
2. Define custom error enum (network, timeout, parsing)
3. Use do-catch with async/await
4. Implement retry logic (up to 3 attempts)

### Starter Code

```swift
enum APIError: Error {
    case network
    case timeout
    case parsing
}

func fetchData() async throws -> String {
    // Simulate random failure
    let random = Int.random(in: 0..<10)
    if random < 3 {
        throw APIError.network
    }
    return "Success"
}

// TODO: Implement retry logic
```

### Evaluation Criteria

- async throws syntax
- Error handling patterns
- Retry implementation

---

## Challenge 6: Cancellation

**Time:** 20 minutes

### Requirements

1. Create a long-running Task
2. Implement cancellation check inside the task
3. Cancel the task after 3 seconds
4. Handle cancellation gracefully

### Expected Output

```
Task started
Working... (1 second)
Working... (2 seconds)
Working... (3 seconds)
Task cancelled!
Cleanup complete
```

### Evaluation Criteria

- Task.cancel() usage
- Task.isCancelled check
- Graceful cleanup

---

## Solutions

Reference solutions are in the `solutions/` directory.
