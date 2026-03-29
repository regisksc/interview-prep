# Multiple Choice Questions

Quick knowledge checks for iOS concepts.

---

## Swift Fundamentals

### Question 1

What is the output of this code?

```swift
var a = [1, 2, 3]
var b = a
b.append(4)
print(a.count)
```

A) 3  
B) 4  
C) Compile error  
D) Runtime error

<details>
<summary>Answer</summary>

**A) 3**

Arrays are value types in Swift. When assigned to `b`, a copy is made. Modifying `b` doesn't affect `a`.

</details>

---

### Question 2

What does `guard` do that `if let` doesn't?

A) Unwraps optionals  
B) Keeps unwrapped value in scope after the guard statement  
C) Is faster at runtime  
D) Works with non-optional types only

<details>
<summary>Answer</summary>

**B) Keeps unwrapped value in scope after the guard statement**

`guard` exits early if condition fails, and the unwrapped value remains available in the enclosing scope.

</details>

---

### Question 3

What is the difference between `struct` and `class`?

A) Structs can have methods, classes cannot  
B) Structs are value types, classes are reference types  
C) Classes can conform to protocols, structs cannot  
D) There is no difference

<details>
<summary>Answer</summary>

**B) Structs are value types, classes are reference types**

Structs are copied when assigned/passed. Classes share references.

</details>

---

### Question 4

What does `@escaping` mean for a closure?

A) The closure runs asynchronously  
B) The closure outlives the function call  
C) The closure cannot capture self  
D) The closure is optional

<details>
<summary>Answer</summary>

**B) The closure outlives the function call**

Escaping closures are stored or called after the function returns, requiring explicit memory management.

</details>

---

## SwiftUI

### Question 5

When does a SwiftUI view's `body` get called?

A) Only when the view is created  
B) When any @State or @Binding changes  
C) Only when onAppear is called  
D) When the app launches

<details>
<summary>Answer</summary>

**B) When any @State or @Binding changes**

SwiftUI views are structs that get recreated frequently. The body is a computed property that runs whenever dependent state changes.

</details>

---

### Question 6

What's the difference between @StateObject and @ObservedObject?

A) No difference  
B) @StateObject creates the object, @ObservedObject borrows it  
C) @StateObject is for SwiftUI, @ObservedObject is for UIKit  
D) @StateObject works on iOS 14+, @ObservedObject on iOS 13

<details>
<summary>Answer</summary>

**B) @StateObject creates the object, @ObservedObject borrows it**

@StateObject owns the lifecycle (creates it). @ObservedObject receives it from elsewhere.

</details>

---

### Question 7

What happens if you forget to add .environmentObject()?

A) Compile error  
B) Runtime crash  
C) View doesn't update  
D) Default value is used

<details>
<summary>Answer</summary>

**B) Runtime crash**

Missing environment objects cause a runtime crash with "No ObservableObject of type X found in environment."

</details>

---

## Concurrency

### Question 8

What does `await` do?

A) Runs code on background thread  
B) Suspends execution until async operation completes  
C) Creates a new Task  
D) Cancels the current Task

<details>
<summary>Answer</summary>

**B) Suspends execution until async operation completes**

`await` marks a suspension point where the function waits for an async operation without blocking the thread.

</details>

---

### Question 9

What is `@MainActor`?

A) A singleton for the app  
B) A global actor ensuring code runs on main thread  
C) A replacement for DispatchQueue.main  
D) A SwiftUI-only annotation

<details>
<summary>Answer</summary>

**B) A global actor ensuring code runs on main thread**

@MainActor isolates code to the main actor, ensuring all execution happens on the main thread.

</details>

---

### Question 10

How do you cancel a Task?

A) Call .stop()  
B) Call .cancel()  
C) Set it to nil  
D) Tasks cannot be cancelled

<details>
<summary>Answer</summary>

**B) Call .cancel()**

Tasks have a .cancel() method. The task should check Task.isCancelled for cooperative cancellation.

</details>

---

## Combine

### Question 11

What does `debounce` do?

A) Delays all emissions by a fixed time  
B) Waits for a pause in emissions before emitting  
C) Limits emission rate to once per interval  
D) Combines multiple publishers

<details>
<summary>Answer</summary>

**B) Waits for a pause in emissions before emitting**

Debounce waits for a specified silence period before emitting the latest value. Common for search inputs.

</details>

---

### Question 12

What happens if you don't store a Cancellable?

A) Compile error  
B) Runtime crash  
C) Publisher is immediately cancelled  
D) Memory leak

<details>
<summary>Answer</summary>

**C) Publisher is immediately cancelled**

Cancellables must be stored. When they deallocate, the subscription is cancelled.

</details>

---

## UIKit

### Question 13

When is `viewDidLoad` called?

A) Every time the view appears  
B) Once when the view is loaded into memory  
C) Before the view controller is created  
D) After the view disappears

<details>
<summary>Answer</summary>

**B) Once when the view is loaded into memory**

viewDidLoad is called once after the view hierarchy is loaded. Use it for one-time setup.

</details>

---

### Question 14

What is the responder chain?

A) The order views are laid out  
B) The path events travel from view to app  
C) The sequence of view controller lifecycle methods  
D) The navigation stack

<details>
<summary>Answer</summary>

**B) The path events travel from view to app**

The responder chain determines how touch events propagate: View → ViewController → NavigationController → Window → App.

</details>

---

## Architecture

### Question 15

What is the main benefit of MVVM?

A) Fewer files  
B) Separation of UI and business logic  
C) Faster compilation  
D) Automatic testing

<details>
<summary>Answer</summary>

**B) Separation of UI and business logic**

MVVM separates View (UI), ViewModel (state/logic), and Model (data), making code more testable and maintainable.

</details>

---

### Question 16

When should you use Redux over MVVM?

A) Always  
B) Never  
C) When you need predictable state transitions or time-travel debugging  
D) For simple CRUD apps

<details>
<summary>Answer</summary>

**C) When you need predictable state transitions or time-travel debugging**

Redux adds boilerplate but provides predictable state flow, useful for complex apps with many state transitions.

</details>

---

## Memory Management

### Question 17

What causes a retain cycle?

A) Two objects strongly referencing each other  
B) Using too many closures  
C) Not using weak self  
D) Having too many properties

<details>
<summary>Answer</summary>

**A) Two objects strongly referencing each other**

Retain cycles occur when two objects hold strong references to each other, preventing deallocation.

</details>

---

### Question 18

How do you prevent retain cycles in closures?

A) Use [strong self]  
B) Use [weak self] or [unowned self]  
C) Don't use closures  
D) Make the closure @escaping

<details>
<summary>Answer</summary>

**B) Use [weak self] or [unowned self]**

Capture lists with weak/unowned break the strong reference cycle.

</details>

---

## More Questions Coming Soon

Check back for updates with more questions on:
- Core Data
- Networking
- Security
- Accessibility
- CI/CD

---

## How to Use

1. Read each question carefully
2. Try to answer without looking
3. Click "Answer" to check
4. Review explanations for questions you missed
5. Revisit related modules in the main README
