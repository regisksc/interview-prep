# Practice Challenges

Find-the-bug challenges to test your iOS debugging skills.

## Available Challenges

| Challenge | Difficulty | Concepts |
|-----------|------------|----------|
| [swift_fundamentals/](swift_fundamentals) | Easy | Optionals, value types, closures |
| [viewmodel_lifecycle/](viewmodel_lifecycle) | Medium | @StateObject, Task, memory |
| [concurrency/](concurrency) | Medium-Hard | Actors, MainActor, async |
| [combine_memory/](combine_memory) | Hard | Cancellables, retain cycles |
| [performance/](performance) | Medium | SwiftUI body, state |

---

## How to Use

1. Open the challenge in Xcode
2. Run the app
3. Observe the buggy behavior
4. Find and fix all 3 bugs
5. Verify the fix

---

## Tips

- Read the code carefully
- Think about lifecycle and memory
- Use breakpoints and console logs
- Consider thread safety
- Check for common patterns (weak self, Task cancellation)

---

## Bug Categories

### Memory Bugs
- Retain cycles in closures
- Missing weak self
- Not storing cancellables

### Concurrency Bugs
- UI updates off main thread
- Race conditions
- Missing await

### Lifecycle Bugs
- Using view after dismiss
- Not checking mounted
- Task not cancelled

### State Bugs
- @ObservedObject instead of @StateObject
- Mutating value types incorrectly
- State in wrong scope
