# iOS Senior Engineer — Interview Prep Course

> **Who this is for:** You know programming (maybe Kotlin, JS, Python, etc.) but you're **new to Swift and iOS**. This guide explains every concept from scratch — no assumed Swift knowledge.
>
> **Format:** 13 modules ordered by interview impact. Do Module 1 first, always.

---

## If you have < 24 hours

> **Skip everything below.** Go straight to the [Cram Plan](CRAM-PLAN.md). It tells you exactly what to study hour by hour, with the minimum you need to not embarrass yourself. Come back here when you have more time.

---

## Table of Contents

| # | Module | Why it matters |
|---|--------|---------------|
| 1 | [Swift Language Fundamentals](#module-1-swift-language-fundamentals) | Every iOS question assumes fluent Swift |
| 2 | [UIKit & SwiftUI Lifecycle](#module-2-uikit--swiftui-lifecycle) | The mental model interviewers test most |
| 3 | [State Management & Data Flow](#module-3-state-management--data-flow) | Biggest differentiation between mid and senior |
| 4 | [Architecture & Project Structure](#module-4-architecture--project-structure) | Senior signal: can you own a codebase? |
| 5 | [Concurrency: async/await, Actors & Tasks](#module-5-concurrency-asyncawait-actors--tasks) | Deep Swift — expected at senior level |
| 6 | [Navigation & View Controllers](#module-6-navigation--view-controllers) | Practical, frequently tested |
| 7 | [Performance & Optimization](#module-7-performance--optimization) | Shows production experience |
| 8 | [Testing Strategy](#module-8-testing-strategy) | Non-negotiable in production-grade apps |
| 9 | [Native Features & Frameworks](#module-9-native-features--frameworks) | Differentiator for senior roles |
| 10 | [Security, Privacy & Compliance](#module-10-security-privacy--compliance) | Critical for any app handling sensitive user data |
| 11 | [Accessibility](#module-11-accessibility) | Required in any user-facing production app |
| 12 | [CI/CD & Release Pipeline](#module-12-cicd--release-pipeline) | Shows ownership beyond code |
| 13 | [Behavioral & System Design](#module-13-behavioral--system-design) | The round that actually gets you hired |

---

## SwiftUI Focus Track

If SwiftUI is your primary focus (recommended for modern iOS roles), follow this accelerated path. **Full map:** [lessons/lesson-practice-map.md](lessons/lesson-practice-map.md).

Practice is **8 progressive apps** with increasing difficulty (★☆☆ → ★★★). Each starts from a pre-built starter, evolves step-by-step, and includes LLM-reviewable rubrics. See [practice/apps/](practice/apps/README.md).

| Week | Focus | Lessons | App (difficulty) |
|------|-------|---------|-----------------|
| 1 | Swift fundamentals + local state | Module 1–2 · [swiftui-state](lessons/swiftui-state.md) | [**01 Mood Tracker**](practice/apps/01-mood-tracker/README.md) ★☆☆ steps 1–4 |
| 2 | Shared state, environment | [swiftui-state](lessons/swiftui-state.md) (continued) | **01 Mood Tracker** steps 5–7 |
| 3 | Layout, grids, modifiers | [swiftui-advanced](lessons/swiftui-advanced.md) (layout, modifiers) | [**02 Recipe Book**](practice/apps/02-recipe-book/README.md) ★☆☆ |
| 4 | Animation, gestures | [swiftui-advanced](lessons/swiftui-advanced.md) (animation) | [**03 Weather Cards**](practice/apps/03-weather-cards/README.md) ★★☆ |
| 5 | Lists, navigation, sheets | Module 6 · [troubleshooting](lessons/swiftui-troubleshooting.md) | [**04 Contacts**](practice/apps/04-contacts/README.md) ★★☆ |
| 6 | @Observable, Combine | [state-management-comparison](lessons/state-management-comparison.md) · [combine](lessons/combine-framework.md) | [**05 Habit Tracker**](practice/apps/05-habit-tracker/README.md) ★★☆ |
| 7 | Async, networking, UIKit interop | [combine](lessons/combine-framework.md) · Module 5, 7 | [**06 News Reader**](practice/apps/06-news-reader/README.md) ★★★ |
| 8 | Charts, SwiftData, persistence | [swiftui-advanced](lessons/swiftui-advanced.md) · Module 7, 9 | [**07 Expense Tracker**](practice/apps/07-expense-tracker/README.md) ★★★ |
| 9 | Architecture, testing | Module 4, 5, 8 | [**08 Mini Social**](practice/apps/08-mini-social/README.md) ★★★ |
| 10 | Interview prep | [interview-questions](lessons/swiftui-interview-questions.md) · [troubleshooting](lessons/swiftui-troubleshooting.md) | Mock interviews; revisit weak apps |

---

## Lessons

In-depth reference material beyond the module summaries. Each file lists **contents** at the top (and [swiftui-state](lessons/swiftui-state.md) / [swiftui-advanced](lessons/swiftui-advanced.md) link drills and project folders).

| File | What it covers |
|------|---------------|
| [lessons/lesson-practice-map.md](lessons/lesson-practice-map.md) | **Index:** lesson sections ↔ 8 practice apps ↔ 52 steps |
| [lessons/state-management-comparison.md](lessons/state-management-comparison.md) | Observable · @Published · Redux · MVVM — pros/cons, decision guide, scenarios |
| [lessons/swiftui-state.md](lessons/swiftui-state.md) | @State through @SceneStorage — table of contents + practice column |
| [lessons/combine-framework.md](lessons/combine-framework.md) | Publishers, operators, SwiftUI integration, memory |
| [lessons/swiftui-advanced.md](lessons/swiftui-advanced.md) | Modifiers, environment, layout, animation, performance, UIKit interop, testing |
| [lessons/swiftui-troubleshooting.md](lessons/swiftui-troubleshooting.md) | Symptoms → fixes (state, layout, lists, performance, async) |
| [lessons/swiftui-interview-questions.md](lessons/swiftui-interview-questions.md) | Questions by level + scenarios |

---

## Module 1: Swift Language Fundamentals

> **Priority: CRITICAL.** iOS is Swift. If you stumble on Swift basics, nothing else matters.
>
> This module is extra-detailed because you're learning a new language. Take your time here.

---

### 1.1 The Absolute Basics: Variables, Constants, and Types

If you know any programming language, Swift will feel familiar — but there are important differences.

```swift
// 'let' = constant (cannot change after set). Like 'val' in Kotlin or 'const' in JS.
let name: String = "Regis"

// 'var' = variable (can change). Like 'var' in Kotlin/JS.
var score: Int = 0
score = 10  // this is fine because we used 'var'

// name = "Someone else"  // ERROR! 'let' means you can't reassign it.

// Swift has "type inference" — the compiler figures out the type for you.
// You don't always need to write ': String' or ': Int'.
let city = "Seoul"       // Swift knows this is a String
var temperature = 23.5   // Swift knows this is a Double (decimal number)
let isRaining = false    // Swift knows this is a Bool (true/false)
```

**Swift's basic types:**

```swift
let wholeNumber: Int = 42           // integer (whole number)
let decimal: Double = 3.14          // decimal number (like float but more precise)
let text: String = "hello"          // text
let flag: Bool = true               // true or false
let letter: Character = "A"        // single character
```

> **In plain English:** Swift has two ways to store values: `let` (permanent, can't change) and `var` (changeable). The compiler is smart enough to figure out the type most of the time, so you usually don't need to write `let x: Int = 5` — just `let x = 5` is fine.

---

### 1.2 Optionals & Nil Safety

In most languages (Java, JS, Python), any variable can be `null`/`nil`/`None` and your program crashes at runtime if you try to use it. Swift takes a completely different approach.

**In Swift, variables CANNOT be nil by default.** If you want a variable to possibly be empty, you must explicitly mark it with a `?` after the type. This is called an **Optional**. Swift then forces you to handle the "what if it's nil?" case — you can't just use it and hope.

```swift
// This variable MUST always have a String value. It can never be nil.
let name: String = "Regis"

// This variable CAN be nil. The '?' makes it an "Optional String".
// Think of it as a box that either contains a String or is empty (nil).
var nickname: String? = nil    // currently empty
nickname = "Reg"                // now it has a value
nickname = nil                  // back to empty — this is allowed because of the '?'

// You CANNOT do this:
// let forced: String = nil    // ERROR! String (without ?) can never be nil.
```

**Unwrapping — getting the value out of an Optional:**

Since an Optional might be nil, Swift won't let you use the value directly. You must first check ("unwrap") it:

```swift
var nickname: String? = "Reg"

// OPTION 1: 'if let' — check and unwrap in one step
// "If nickname has a value, put that value into 'unwrapped' and run the block"
if let unwrapped = nickname {
    // 'unwrapped' is a regular String here, guaranteed non-nil
    print(unwrapped.uppercased())  // prints "REG"
}
// Outside the if-block, 'unwrapped' doesn't exist

// OPTION 2: 'guard let' — check and exit early if nil
// "Make sure nickname has a value. If it doesn't, leave this function."
func greet() {
    guard let unwrapped = nickname else {
        // nickname was nil — we must exit the function here
        print("No nickname")
        return   // 'return' exits the function
    }
    // From here on, 'unwrapped' is a regular String, guaranteed non-nil
    print("Hello, \(unwrapped)!")
}

// OPTION 3: Nil-coalescing — provide a default value
// "Use nickname if it has a value, otherwise use 'anonymous'"
let display = nickname ?? "anonymous"
// display is always a regular String (never nil)

// OPTION 4: Optional chaining — safely access properties/methods
// "If nickname is not nil, get its first character. Otherwise, result is nil."
let firstChar = nickname?.first
// firstChar is 'Character?' — it's also optional because nickname might be nil

// OPTION 5: Force unwrap with '!' — DANGEROUS, avoid when possible
// "I'm 100% sure this is not nil. Crash if I'm wrong."
let forced = nickname!  // crashes if nickname is nil
```

**When to use `guard` vs `if let`:**

```swift
// Use 'guard' when nil means "we can't continue" — keeps your code flat
func processUser(user: User?) {
    guard let user = user else {
        print("No user provided")
        return  // exit early
    }
    // All the remaining code can use 'user' without worrying about nil.
    // No deep nesting needed!
    print(user.name)
    print(user.email)
}

// Use 'if let' when nil is just one possibility — you handle both cases
func displayName(nickname: String?) {
    if let nickname = nickname {
        print("Hi, \(nickname)")
    } else {
        print("Hi, stranger")
    }
}
```

**Implicitly Unwrapped Optionals — the `!` type:**

```swift
// UILabel! means "this will be nil initially, but I promise it will have
// a value by the time I use it." Common in UIKit (the older iOS framework)
// because views are set up in stages.
var titleLabel: UILabel!  // nil right now
// Later, during setup:
// titleLabel = UILabel()
// Now you can use titleLabel without unwrapping every time.
// But if you forget to set it up — CRASH!
```

> **In plain English:** Swift's Optionals force you to think about nil at compile time, not runtime. Instead of getting random "null pointer" crashes in production, the compiler catches it while you're writing code. It feels annoying at first, but it prevents an entire category of bugs.

---

### 1.3 Value Types vs Reference Types

This is one of the most important concepts in Swift and interviewers love asking about it.

A **value type** is like a photocopy — when you assign it to a new variable, you get an independent copy. Changing the copy doesn't affect the original.

A **reference type** is like a shared Google Doc — when you assign it to a new variable, both variables point to the same object. Changing one changes both.

| Value Types (copy on assign) | Reference Types (shared instance) |
|------------------------------|-----------------------------------|
| `struct` (the workhorse of Swift) | `class` |
| `enum` | `actor` (more on this in Module 5) |
| `tuple` | closures (functions) |

```swift
// ---- STRUCT (value type) — gets copied ----

// 'struct' defines a value type. Like a data class in Kotlin.
struct User {
    let id: String      // 'let' = this property can't change after creation
    var name: String    // 'var' = this property can change
}

var user1 = User(id: "1", name: "Regis")
var user2 = user1        // user2 is a COPY of user1. They're independent now.
user2.name = "John"      // only user2 changes
print(user1.name)        // prints "Regis" — user1 is untouched
print(user2.name)        // prints "John"


// ---- CLASS (reference type) — shared ----

// 'class' defines a reference type. Like a regular class in Java/Kotlin/Python.
class Counter {
    var value = 0        // mutable property
}

let c1 = Counter()
let c2 = c1              // c2 and c1 point to the SAME Counter object
c2.value = 10            // changing c2 also changes c1!
print(c1.value)          // prints 10 — both point to the same object
print(c2.value)          // prints 10
```

**When to use `struct` vs `class`:**

```swift
// DEFAULT: Use struct.
// Structs are safer because copies are independent — no surprise mutations.
struct Product {
    let id: String
    var name: String
    var price: Double
}

// USE CLASS when you need:
// 1. Identity — you need to check if two variables point to the SAME object
//    (not just equal values)
// 2. Inheritance — you need one class to build on another
// 3. Shared mutable state — multiple parts of your app need to read/write
//    the same object (but consider actors instead — see Module 5)

class Logger {
    // You want ONE logger shared across the whole app
    static let shared = Logger()   // 'static' = belongs to the type, not instances
    
    func log(_ message: String) {
        print("[LOG] \(message)")
    }
}
```

> **In plain English:** In Swift, `struct` is the default choice. It's like working with spreadsheet copies — your copy, your changes. `class` is like a shared Google Doc — everyone sees every edit. Structs are safer because you can't accidentally change someone else's data. Use classes only when you specifically need sharing.

---

### 1.4 Functions and Closures

**Functions** in Swift have a distinctive syntax with named parameters:

```swift
// A function that takes two parameters and returns a String.
// 'greeting' and 'name' are the parameter names.
func makeGreeting(greeting: String, name: String) -> String {
    // '\(...)' is "string interpolation" — embedding a value inside a string.
    // Like `${}` in JS template literals or `$variable` in Kotlin.
    return "\(greeting), \(name)!"
}

// When CALLING the function, you must use the parameter names:
let message = makeGreeting(greeting: "Hello", name: "Regis")
// prints: "Hello, Regis!"

// Swift lets you have TWO names for a parameter:
// - An "argument label" (used when calling)
// - A "parameter name" (used inside the function)
func greet(_ name: String, from city: String) -> String {
    // '_' means "no label needed when calling"
    // 'from' is the external label, 'city' is used inside
    return "Hello \(name) from \(city)!"
}
let msg = greet("Regis", from: "Seoul")
// The '_' before 'name' means we don't write a label for it.

// Functions can have default values for parameters:
func connect(to host: String, port: Int = 443) {
    print("Connecting to \(host):\(port)")
}
connect(to: "api.example.com")        // uses default port 443
connect(to: "api.example.com", port: 8080)  // overrides default
```

**Closures** — a closure is an unnamed function you can pass around as a variable. Like a lambda in Kotlin/Python, or an arrow function in JavaScript. In Swift, the syntax uses curly braces `{ }`.

```swift
// A regular function:
func add(a: Int, b: Int) -> Int {
    return a + b
}

// The same thing as a closure (unnamed function stored in a variable):
// The type '(Int, Int) -> Int' means "takes two Ints, returns an Int"
let addClosure: (Int, Int) -> Int = { (a: Int, b: Int) -> Int in
    // 'in' separates the parameters from the body. Think of it as '{' in a lambda.
    return a + b
}
let result = addClosure(3, 5)  // result is 8

// Swift has LOTS of shortcuts for closures. Here's the progression:

let names = ["Charlie", "Alice", "Bob"]

// Full form:
let sorted1 = names.sorted(by: { (a: String, b: String) -> Bool in
    return a < b
})

// Shorter — Swift infers the types:
let sorted2 = names.sorted(by: { a, b in
    return a < b
})

// Even shorter — 'return' is implicit for single-expression closures:
let sorted3 = names.sorted(by: { a, b in a < b })

// Shortest — $0 means "first parameter", $1 means "second parameter":
let sorted4 = names.sorted(by: { $0 < $1 })

// "Trailing closure" syntax — when a closure is the LAST argument,
// you can write it outside the parentheses:
let sorted5 = names.sorted { $0 < $1 }

// All five versions produce the same result: ["Alice", "Bob", "Charlie"]
```

**Common closures you'll see everywhere:**

```swift
let numbers = [1, 2, 3, 4, 5]

// 'map' — transform each element. Like .map() in JS/Kotlin/Python.
let doubled = numbers.map { $0 * 2 }           // [2, 4, 6, 8, 10]

// 'filter' — keep elements that pass a test
let evens = numbers.filter { $0 % 2 == 0 }     // [2, 4]

// 'reduce' — combine all elements into one value
let sum = numbers.reduce(0) { $0 + $1 }        // 15
// $0 is the running total (starts at 0), $1 is each element

// 'compactMap' — like map, but also removes nil results
let strings = ["1", "two", "3", "four"]
let integers = strings.compactMap { Int($0) }   // [1, 3]
// Int("two") returns nil, so compactMap drops it

// 'forEach' — like a for loop but as a method
numbers.forEach { print($0) }                   // prints 1, 2, 3, 4, 5
```

> **In plain English:** Closures are just functions without names that you can pass around. You'll see them constantly in Swift — as callbacks, in array operations like `.map` and `.filter`, and throughout SwiftUI. The `$0`, `$1` shorthand is just a quick way to refer to parameters without naming them.

---

### 1.5 Closures & Capture Lists (Memory)

When a closure uses a variable from outside itself, it "captures" that variable — it keeps a reference to it. This can cause memory problems if you're not careful.

**Retain cycle** (the bug): Two objects hold strong references to each other, so neither can ever be freed from memory. It's a memory leak.

```swift
// PROBLEM: Retain cycle
class ViewController {
    var name = "Main Screen"
    
    // 'onComplete' stores a closure. The '?' means it can be nil.
    // '() -> Void' means "a function that takes nothing and returns nothing".
    // 'Void' is Swift's way of saying "no return value" (like 'void' in Java/C).
    var onComplete: (() -> Void)?
    
    func setup() {
        onComplete = {
            // This closure captures 'self' (the ViewController) strongly.
            // Now: ViewController → onComplete → closure → self (ViewController)
            // It's a loop! Neither can be freed. This is a RETAIN CYCLE.
            print(self.name)
        }
    }
    
    // 'deinit' runs when the object is freed from memory.
    // Like a destructor in C++ or finalize in Java.
    // If this never prints, you have a memory leak!
    deinit {
        print("ViewController freed")
    }
}

// FIX: Use [weak self] in the closure's "capture list"
class FixedViewController {
    var name = "Main Screen"
    var onComplete: (() -> Void)?
    
    func setup() {
        // '[weak self]' is a "capture list" — it goes before the parameters.
        // 'weak' means "don't keep this object alive just because the closure uses it."
        // 'self' becomes optional (Self?) inside the closure, so use 'self?' with '?'.
        onComplete = { [weak self] in
            // 'self?.name' — if self is nil (already freed), this is just nil.
            // No crash, no retain cycle.
            print(self?.name ?? "gone")
        }
    }
    
    deinit {
        print("FixedViewController freed")  // This WILL print now!
    }
}
```

**`@escaping` — closures that outlive the function:**

```swift
// By default, a closure parameter is "non-escaping" — it runs immediately
// inside the function and doesn't live beyond it.

func doNow(action: () -> Void) {
    action()  // runs right now, inside this function
}

// '@escaping' means "this closure will be stored or called LATER,
// after the function returns." You must mark it explicitly.
// This is common for callbacks, network completions, and async work.

class DataLoader {
    // This stores the closure for later — so it must be @escaping
    var completionHandler: (() -> Void)?
    
    func load(completion: @escaping () -> Void) {
        completionHandler = completion  // stored for later!
    }
}
```

> **In plain English:** When a closure references `self` (the object it belongs to), it creates a strong link. If that object also holds the closure, they grip each other forever and neither gets freed — that's a memory leak called a "retain cycle." The fix is `[weak self]`, which says "hold a loose grip — if the object goes away, just let it go." You'll write `[weak self]` a LOT in real iOS code.

---

### 1.6 Protocols

A **protocol** is the same thing as an **interface** in Java/Kotlin/TypeScript. It says "any type that claims to be X must provide these methods/properties." You "conform to" a protocol instead of "implementing" an interface.

```swift
// Defining a protocol — it's like a contract.
// Any type that says "I am Loggable" MUST have a log() method.
protocol Loggable {
    func log(message: String)
}

// A struct conforming to the protocol (like "implements" in Java)
struct ConsoleLogger: Loggable {
    // We MUST provide this method because the protocol requires it
    func log(message: String) {
        print("[LOG] \(message)")
    }
}

// A class can also conform
class FileLogger: Loggable {
    func log(message: String) {
        // write to file...
        print("[FILE] \(message)")
    }
}

// Now you can use the protocol as a type — any Loggable works:
func performAction(logger: Loggable) {
    logger.log(message: "Action performed")
}
performAction(logger: ConsoleLogger())  // works
performAction(logger: FileLogger())     // also works
```

**Protocol extensions — adding default behavior:**

```swift
// You can give protocols default implementations using extensions.
// This is like default methods in Java interfaces.
protocol Describable {
    var description: String { get }   // 'get' means read-only property
}

// 'extension' adds new functionality to an existing type.
// Here we add a default implementation to the protocol.
extension Describable {
    var description: String {
        return "I am a \(type(of: self))"
        // 'type(of: self)' returns the actual type name at runtime
    }
}

// Now any type that conforms to Describable gets the default for free:
struct Cat: Describable {
    // No need to write 'description' — the default works!
}
print(Cat().description)  // "I am a Cat"

// But you CAN override it:
struct Dog: Describable {
    var description: String { return "Woof! I'm a dog" }
}
print(Dog().description)  // "Woof! I'm a dog"
```

**Common built-in protocols you'll see:**

```swift
// 'Codable' = can be converted to/from JSON (or other formats).
// It's actually a combination of 'Encodable' (to JSON) and 'Decodable' (from JSON).
struct User: Codable {
    let id: String
    let name: String
    let email: String
}

// 'Identifiable' = has a unique 'id' property. Required by SwiftUI lists.
struct Task: Identifiable {
    let id: String        // SwiftUI uses this to track items in a list
    var title: String
}

// 'Equatable' = can be compared with == for equality
struct Point: Equatable {
    let x: Double
    let y: Double
}
let a = Point(x: 1, y: 2)
let b = Point(x: 1, y: 2)
print(a == b)  // true — because Point conforms to Equatable

// 'Hashable' = can be used as a dictionary key or in a Set
struct Product: Hashable {
    let id: String
    let name: String
}
let productSet: Set<Product> = [Product(id: "1", name: "Widget")]
```

**Protocol-oriented programming** is a core Swift philosophy. Instead of building deep class hierarchies (class A → class B → class C), you define small protocols and compose them. This is considered more "Swifty."

> **In plain English:** A protocol says "if you want to be part of this club, you must be able to do these things." Any struct, class, or enum can join the club by providing the required methods. This lets you write code that works with ANY type that has the right abilities, rather than one specific type. It's exactly like interfaces in other languages.

---

### 1.7 Enums (Enumerations)

Swift enums are much more powerful than enums in most languages. They can hold data, have methods, and conform to protocols.

```swift
// Basic enum — a type with a fixed set of possible values
enum Direction {
    case north
    case south
    case east
    case west
}

// You can also write them on one line:
// enum Direction { case north, south, east, west }

var heading = Direction.north
heading = .south  // Swift knows the type, so you can skip 'Direction.'

// Enums work great with 'switch' — and you MUST handle every case:
switch heading {
case .north:
    print("Going north")
case .south:
    print("Going south")
case .east:
    print("Going east")
case .west:
    print("Going west")
// No 'default' needed — we covered all cases!
// If you add a new case later, the compiler will warn you everywhere.
}

// ASSOCIATED VALUES — enums can carry data!
// This is like sealed classes in Kotlin.
enum NetworkResult {
    case success(data: Data)        // carries the response data
    case failure(error: String)     // carries an error message
    case loading                     // no associated data
}

let result = NetworkResult.success(data: Data())

// Extract the associated value with switch:
switch result {
case .success(let data):
    // 'data' is now available as a regular variable
    print("Got \(data.count) bytes")
case .failure(let error):
    print("Error: \(error)")
case .loading:
    print("Still loading...")
}

// RAW VALUES — assign underlying values to cases
enum StatusCode: Int {
    case ok = 200
    case notFound = 404
    case serverError = 500
}
let code = StatusCode.ok
print(code.rawValue)  // 200

// Create from raw value (returns optional because the value might not match):
let fromCode = StatusCode(rawValue: 404)  // Optional(StatusCode.notFound)
```

> **In plain English:** Enums in Swift define a type that can only be one of a few specific values — like a traffic light that can only be red, yellow, or green. The killer feature is "associated values": each case can carry different data, like a package that's labeled "success" and contains your data, or labeled "failure" and contains an error message. This is everywhere in iOS code.

---

### 1.8 Generics

Generics let you write code that works with any type, while still being type-safe. Like generics in Java/Kotlin/TypeScript.

```swift
// WITHOUT generics — you'd need separate functions for each type:
func swapInts(_ a: inout Int, _ b: inout Int) {
    let temp = a; a = b; b = temp
}
func swapStrings(_ a: inout String, _ b: inout String) {
    let temp = a; a = b; b = temp
}

// WITH generics — one function works for ANY type:
// '<T>' means "T is a placeholder for any type"
// 'inout' means "this parameter can be modified" (passed by reference)
func swapValues<T>(_ a: inout T, _ b: inout T) {
    let temp = a
    a = b
    b = temp
}

var x = 5, y = 10
swapValues(&x, &y)  // '&' is required for inout parameters
// x is now 10, y is now 5

var s1 = "hello", s2 = "world"
swapValues(&s1, &s2)
// s1 is now "world", s2 is now "hello"

// Generic type — a container that works with any content type:
struct Box<T> {
    var content: T
}

let intBox = Box(content: 42)         // Box<Int>
let stringBox = Box(content: "Hi")    // Box<String>

// You can constrain generics — require the type to conform to a protocol:
// Here T must be Equatable (support ==)
func findIndex<T: Equatable>(of item: T, in array: [T]) -> Int? {
    for (index, element) in array.enumerated() {
        if element == item {
            return index
        }
    }
    return nil  // not found
}

let index = findIndex(of: "Bob", in: ["Alice", "Bob", "Charlie"])
// index is Optional(1)
```

> **In plain English:** Generics let you write a function or type once and use it with many different types. Instead of writing `BoxOfInts`, `BoxOfStrings`, `BoxOfUsers`, you write `Box<T>` and T becomes whatever type you put in. The compiler makes sure everything stays type-safe.

---

### 1.9 Extensions

Extensions let you add new methods, computed properties, or protocol conformances to ANY existing type — even types you didn't write (like `String` or `Int`). You cannot add stored properties.

```swift
// Add a method to the built-in String type:
extension String {
    // 'var' with a body (no '= value') is a "computed property" —
    // it calculates its value each time you access it.
    var isBlank: Bool {
        // 'trimmingCharacters' removes whitespace from both ends
        return trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func toTitleCase() -> String {
        // 'split' breaks the string into pieces
        // 'map' transforms each piece — '$0' is the current piece
        // 'joined' puts the pieces back together
        split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
            .joined(separator: " ")
    }
}

"  ".isBlank                   // true
"hello world".toTitleCase()    // "Hello World"

// Add a convenience method to Int:
extension Int {
    var isEven: Bool { self % 2 == 0 }
}
4.isEven    // true
7.isEven    // false

// Add protocol conformance via extension:
struct Temperature {
    let celsius: Double
}

// 'CustomStringConvertible' is a protocol that requires a 'description' property.
// It controls what print() shows.
extension Temperature: CustomStringConvertible {
    var description: String {
        return "\(celsius)°C"
    }
}
print(Temperature(celsius: 22))  // "22.0°C"
```

> **In plain English:** Extensions let you bolt new functionality onto existing types without modifying their original code. Want all Strings to have a `.isBlank` property? Extension. Want all Ints to have an `.isEven` check? Extension. It's one of Swift's most useful features and you'll see it used heavily to organize code.

---

### 1.10 Error Handling

Swift uses `throw`/`try`/`catch` for error handling, similar to Java/Kotlin — but errors are defined as enums (not classes).

```swift
// Define your errors as an enum conforming to the 'Error' protocol
enum NetworkError: Error {
    case invalidURL
    case noConnection
    case serverError(statusCode: Int)   // can carry data
}

// Functions that can fail are marked with 'throws'
func fetchData(from urlString: String) throws -> Data {
    // 'guard' exits early if the condition fails
    guard let url = URL(string: urlString) else {
        throw NetworkError.invalidURL
        // 'throw' is like 'throw' in Java — it sends the error to the caller
    }
    
    // Imagine some networking code here...
    // If the server returns an error:
    let statusCode = 500
    if statusCode >= 400 {
        throw NetworkError.serverError(statusCode: statusCode)
    }
    
    return Data()  // pretend we got data
}

// CALLING a throwing function — three options:

// Option 1: 'do/try/catch' — handle each error case
do {
    // 'try' is required before calling any 'throws' function
    let data = try fetchData(from: "https://api.example.com")
    print("Got \(data.count) bytes")
} catch NetworkError.invalidURL {
    print("Bad URL")
} catch NetworkError.serverError(let code) {
    print("Server returned \(code)")
} catch {
    // 'error' is automatically available in the catch block
    print("Something went wrong: \(error)")
}

// Option 2: 'try?' — returns nil on failure (no crash, no error details)
let maybeData = try? fetchData(from: "bad url")
// maybeData is 'Data?' — nil if it failed

// Option 3: 'try!' — crash if it fails (only use when you're 100% sure)
// let data = try! fetchData(from: "definitely valid url")
```

> **In plain English:** Swift's error handling is like try/catch in other languages, but errors are defined as enums with clear cases. Functions that can fail say `throws` in their signature, and callers must write `try` to acknowledge the possibility of failure. This makes it obvious which calls can fail, unlike languages where any function might throw unexpectedly.

---

### 1.11 Pattern Matching

Swift has powerful pattern matching — especially in `switch` statements:

```swift
// Enum with associated values (recap):
enum AuthState {
    case authenticated(userId: String)
    case unauthenticated
    case loading
}

func label(for state: AuthState) -> String {
    switch state {
    // 'let userId' extracts the associated value
    // 'where' adds an extra condition (like an if-clause)
    case .authenticated(let userId) where userId.hasPrefix("admin"):
        return "Admin: \(userId)"
    case .authenticated(let userId):
        return "User: \(userId)"
    case .unauthenticated:
        return "Please log in"
    case .loading:
        return "Loading..."
    }
}

// Tuple pattern matching:
// A tuple is a group of values. '(String, Int)' is a tuple of String and Int.
let person = ("Regis", 30)
let (name, age) = person   // "destructuring" — like const [a, b] = arr in JS
print(name)  // "Regis"
print(age)   // 30

// Switch on tuples:
let point = (0, 5)
switch point {
case (0, 0):
    print("At origin")
case (_, 0):        // '_' means "I don't care about this value"
    print("On x-axis")
case (0, _):
    print("On y-axis")  // this matches because x is 0
case (let x, let y):
    print("At (\(x), \(y))")
}

// Range matching:
let temperature = 25
switch temperature {
case ..<0:           // '..<' means "up to but not including"
    print("Freezing")
case 0..<20:
    print("Cold")
case 20..<30:
    print("Nice")     // this matches
default:
    print("Hot")
}

// 'if case' — pattern match without a full switch:
let response = NetworkResult.success(data: Data())
if case .success(let data) = response {
    print("Got data: \(data.count) bytes")
}
```

> **In plain English:** Pattern matching lets you check the "shape" of data and extract values at the same time. Instead of writing chains of if/else statements to check types and values, you describe the pattern you're looking for and Swift matches it for you. The `switch` statement in Swift is much more powerful than in most languages.

---

### 1.12 Result Builders (How SwiftUI Works)

Result builders are the magic behind SwiftUI's declarative syntax. When you write views stacked inside a `VStack { ... }`, result builders make that work.

```swift
// This is what SwiftUI code looks like:
// (Don't worry about understanding every detail — just notice the syntax)
struct ContentView: View {
    var body: some View {
        VStack {            // <-- these stacked views work because of result builders
            Text("Hello")
            Text("World")
            Button("Tap me") {
                print("tapped")
            }
        }
    }
}

// Behind the scenes, the @ViewBuilder result builder collects each view
// and combines them into a single view. You DON'T need to write your own
// result builders — but you should know they exist.

// Simple custom example to show the concept:
// '@resultBuilder' tells Swift "this struct defines a DSL (domain-specific language)"
@resultBuilder
struct ArrayBuilder {
    // 'buildBlock' receives all the individual elements and combines them
    static func buildBlock(_ components: Int...) -> [Int] {
        // '...' means "variadic" — accepts any number of arguments
        Array(components)
    }
}

// '@ArrayBuilder' on a function means "use the ArrayBuilder to process the body"
@ArrayBuilder func myNumbers() -> [Int] {
    1
    2
    3
}
// myNumbers() returns [1, 2, 3]
```

> **In plain English:** Result builders are what let SwiftUI code look like a shopping list of views instead of function calls. When you write `Text("Hello")` followed by `Text("World")` inside a `VStack`, a result builder secretly collects them all and builds a combined view. You'll use this every day but rarely need to build your own.

---

### Module 1 — Quick-Fire Answers

| Question | Answer |
|----------|--------|
| What is the difference between `struct` and `class`? | Structs are value types (copied on assign), classes are reference types (shared). Default to struct. |
| What does `guard` do? | Exits early if condition fails; the unwrapped value stays in scope for the rest of the function. |
| What is a protocol? | A contract (like an interface in Java/Kotlin). Any type conforming to it must implement the required methods/properties. |
| What is `@escaping` for closures? | Marks a closure that will be stored or called AFTER the function returns. Required for callbacks and async work. |
| What is a retain cycle? | Two objects hold strong references to each other, so neither can be freed. Fix with `[weak self]`. |
| What are optionals? | A type that might have no value (`nil`). Marked with `?`. Swift forces you to handle the nil case. |
| What is `$0` in a closure? | Shorthand for the first parameter. `$1` is the second, etc. |
| What is `some View`? | "Some type that conforms to the View protocol, but I'm not telling you which one." Called an "opaque return type." |

---

## Module 2: UIKit & SwiftUI Lifecycle

> **Priority: CRITICAL.** The most common technical deep-dive area.

There are two UI frameworks in iOS:
- **UIKit** — the older, battle-tested framework. Uses classes, inheritance, and imperative code ("do this, then do that").
- **SwiftUI** — the newer, declarative framework (2019+). Uses structs and describes "what" the UI should look like, not "how" to build it.

Most real apps use a mix of both. New projects lean SwiftUI; legacy code is UIKit.

---

### 2.1 App Lifecycle

The "lifecycle" is the sequence of events your app goes through from launch to termination. Like `onCreate`/`onResume`/`onPause` in Android.

**UIKit approach — `UIApplicationDelegate`:**

```swift
// '@main' tells Swift "this is the entry point of the app" (like main() in C)
@main
// 'UIResponder' is a base class that handles touch events.
// 'UIApplicationDelegate' is a protocol with methods iOS calls at lifecycle events.
class AppDelegate: UIResponder, UIApplicationDelegate {
    // 'UIWindow' is the actual window on screen — every app has at least one.
    var window: UIWindow?
    
    // Called when the app finishes launching — your setup goes here.
    // Like onCreate() in Android.
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Set up initial view controller, database, analytics, etc.
        return true
    }
    
    // App is about to become inactive (incoming call, notification, etc.)
    func applicationWillResignActive(_ application: UIApplication) {
        // Pause timers, stop animations
    }
    
    // App moved to background (user pressed Home or switched apps)
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Save data, release shared resources
    }
    
    // App about to come back to foreground
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Refresh data, undo background changes
    }
    
    // App is being terminated (not always called!)
    func applicationWillTerminate(_ application: UIApplication) {
        // Final cleanup — but don't rely on this being called
    }
}
```

**SwiftUI approach — Scene phase:**

```swift
// '@main' — entry point of the app
@main
// 'App' is a protocol — your struct describes the app structure
struct MyApp: App {
    // '@StateObject' creates and owns an observable object (explained in Module 3).
    // For now: it's a shared data container that lives as long as the app does.
    @StateObject private var appState = AppState()
    
    // 'some Scene' — the body returns a scene (a window or group of windows)
    var body: some Scene {
        // 'WindowGroup' creates a window. On iPhone, there's just one.
        WindowGroup {
            ContentView()
                // '.environmentObject' makes appState available to ALL child views
                .environmentObject(appState)
        }
    }
}

// Observe lifecycle changes inside any SwiftUI view:
struct ContentView: View {
    // '@Environment' reads a value from the system environment.
    // '\.scenePhase' is a key that gives us the current app state.
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        Text("Hello")
            // '.onChange' runs code when a value changes
            .onChange(of: scenePhase) { oldPhase, newPhase in
                switch newPhase {
                case .active:
                    // App is visible and in the foreground
                    print("App is active")
                case .inactive:
                    // App is visible but not interactive (e.g., switching apps)
                    print("App is inactive")
                case .background:
                    // App is not visible — save state here
                    print("App in background")
                @unknown default:
                    // Future-proofing: handle any new cases Apple adds
                    break
                }
            }
    }
}
```

> **In plain English:** Your app goes through stages — launched, active, backgrounded, terminated. iOS tells your app about each transition so you can save data, pause timers, or refresh the UI. In UIKit you get callback methods (like `applicationDidEnterBackground`). In SwiftUI you watch the `scenePhase` value. Same concept, different syntax.

---

### 2.2 ViewController Lifecycle (UIKit)

A **ViewController** manages a single screen (or portion of a screen) in UIKit. It has a lifecycle of methods that iOS calls automatically:

```swift
// 'UIViewController' is the base class for all screen controllers in UIKit.
// 'override' means we're replacing the parent class's version of this method.
class MyViewController: UIViewController {
    
    // 1. LOADING PHASE — view is being created
    
    override func loadView() {
        // Create the view hierarchy programmatically (skip if using storyboards)
        // 'UIView()' creates a blank rectangular view
        view = UIView()
    }
    
    override func viewDidLoad() {
        // 'super.viewDidLoad()' — always call the parent's version first.
        // 'super' refers to the parent class (UIViewController).
        super.viewDidLoad()
        // Called ONCE when the view loads into memory.
        // Set up UI elements, constraints, data sources here.
        // Like onCreateView() in Android.
        
        view.backgroundColor = .white
        setupUI()
    }
    
    // 2. APPEARANCE PHASE — view is about to be shown
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Called EVERY TIME before the view appears (not just the first time).
        // Refresh data, start animations, update navigation bar.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // View is now visible on screen.
        // Start timers, analytics, or fetch data.
    }
    
    // 3. DISAPPEARANCE PHASE — view is going away
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // View is about to be hidden. Save state, stop animations.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // View is no longer visible. Stop timers, release heavy resources.
    }
    
    // 4. MEMORY PHASE
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // iOS is running low on memory — release anything you can recreate.
    }
    
    // Called when this ViewController is freed from memory:
    deinit {
        print("MyViewController deallocated")
    }
    
    private func setupUI() {
        // Your UI setup code here
    }
}
```

**Order of calls:**

```
loadView() → viewDidLoad() → viewWillAppear() → viewDidAppear()
                                                       ↓
                              viewDidDisappear() ← viewWillDisappear()
```

> **In plain English:** When you navigate to a new screen in UIKit, iOS creates a ViewController and calls methods in a specific order: first it loads the view (`viewDidLoad` — once), then it shows it (`viewWillAppear` — every time the screen appears). When you navigate away, it calls `viewWillDisappear` and `viewDidDisappear`. Interviewers love asking about this order.

---

### 2.3 SwiftUI View Lifecycle

SwiftUI views work very differently from UIKit. They're structs (value types), not classes. They get recreated frequently — whenever state changes, SwiftUI may rebuild the struct. This is cheap because structs are lightweight.

```swift
struct ContentView: View {
    // '@State' — local state owned by this view (more in Module 3).
    // 'private' means only this struct can access it.
    @State private var count = 0
    
    // 'body' is a computed property that describes the UI.
    // SwiftUI calls this WHENEVER the view needs to be re-rendered.
    var body: some View {
        // 'VStack' stacks views vertically (like a vertical LinearLayout in Android)
        VStack {
            Text("Count: \(count)")
            
            // 'Button' creates a tappable button.
            // The first argument is the label, the closure is the action.
            Button("Increment") {
                count += 1  // changing @State triggers a re-render of body
            }
        }
        .onAppear {
            // Called when this view appears on screen.
            // Like viewDidAppear in UIKit.
            print("View appeared!")
        }
        .onDisappear {
            // Called when this view is removed from screen.
            // Like viewDidDisappear in UIKit.
            print("View disappeared!")
        }
        .onChange(of: count) { oldValue, newValue in
            // Called whenever 'count' changes.
            print("Count went from \(oldValue) to \(newValue)")
        }
        .task {
            // '.task' runs async code when the view appears.
            // Automatically cancelled when the view disappears.
            // Perfect for loading data!
            await loadData()
        }
    }
    
    func loadData() async {
        // Load data from network, etc.
    }
}
```

**Key rule for interviews:** The `body` property runs frequently (on every state change). Never put heavy work directly in `body`. Use `.onAppear`, `.task`, or move logic to a view model.

> **In plain English:** In SwiftUI, you describe WHAT the UI should look like, and SwiftUI figures out HOW to display it. When state changes, SwiftUI re-runs `body` to get the new description, compares it to the old one, and only updates what actually changed (like React's virtual DOM). Heavy work goes in `.onAppear` or `.task`, never directly in `body`.

---

### 2.4 Bridging UIKit and SwiftUI

Real-world apps often mix both frameworks. SwiftUI provides wrapper protocols to use UIKit components in SwiftUI and vice versa.

**Using a UIKit view inside SwiftUI — `UIViewRepresentable`:**

```swift
// 'UIViewRepresentable' is a protocol that lets you wrap a UIKit view
// so it can be used inside SwiftUI.
struct MapView: UIViewRepresentable {
    // 'MKMapView' is UIKit's built-in map component
    
    // Create the UIKit view
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        return mapView
    }
    
    // Update the UIKit view when SwiftUI state changes
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Update the map based on new SwiftUI state
    }
}

// Now you can use it in SwiftUI like any other view:
struct ContentView: View {
    var body: some View {
        MapView()
            .frame(height: 300)
    }
}
```

**Using a SwiftUI view inside UIKit — `UIHostingController`:**

```swift
// 'UIHostingController' wraps a SwiftUI view so UIKit can display it.
// You give it a SwiftUI view, and it acts like a regular UIViewController.
class MyViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swiftUIView = Text("Hello from SwiftUI!")
        // 'UIHostingController' takes any SwiftUI view and makes it a UIKit VC
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        // Add it as a child view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}
```

> **In plain English:** `UIViewRepresentable` = "I have a UIKit component and want to use it in SwiftUI." `UIHostingController` = "I have a SwiftUI view and want to show it in UIKit." You'll need both in real apps because not everything has been ported to SwiftUI yet.

---

### 2.5 Layout Systems

**UIKit uses Auto Layout** — you define rules ("constraints") about where views should be:

```swift
let label = UILabel()
// This line is ALWAYS needed when creating constraints programmatically.
// It tells Auto Layout "I'll define my own constraints, don't generate any."
label.translatesAutoresizingMaskIntoConstraints = false
label.text = "Hello"
view.addSubview(label)   // add the label to the screen

// 'NSLayoutConstraint.activate' turns on a list of positioning rules:
NSLayoutConstraint.activate([
    // "label's top edge should be 20 points below the safe area top"
    // 'safeAreaLayoutGuide' avoids the notch/dynamic island
    label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
    
    // "label's left edge should be 16 points from the screen's left edge"
    label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
    
    // "label's right edge should be 16 points from the screen's right edge"
    // negative because we're measuring inward
    label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
])
```

**SwiftUI uses declarative layout** — you compose views together:

```swift
// 'VStack' = vertical stack (top to bottom)
// 'HStack' = horizontal stack (left to right)
// 'ZStack' = depth stack (back to front, overlapping)
VStack(alignment: .leading, spacing: 16) {
    Text("Title")
        .font(.headline)           // set the font style
    
    Text("Subtitle")
        .font(.subheadline)
        .foregroundColor(.secondary)  // gray color
    
    HStack {
        Image(systemName: "star.fill")  // SF Symbols icon
        Text("4.5 stars")
    }
}
.padding(16)                           // add 16 points of space around all edges
.frame(maxWidth: .infinity, alignment: .leading)  // take full width, align left
```

> **In plain English:** In UIKit, you position views by writing rules: "this view should be 20 pixels below that view." In SwiftUI, you describe the layout with containers: "stack these three views vertically with 16 pixels between them." SwiftUI is simpler to write but UIKit gives you more control for complex layouts.

---

### Module 2 — Quick-Fire Answers

| Question | Answer |
|----------|--------|
| Difference between `viewDidLoad` and `viewWillAppear`? | `viewDidLoad` called once when view loads into memory; `viewWillAppear` called every time before view appears on screen. |
| When does SwiftUI `body` get called? | Whenever any `@State`, `@Binding`, or observed value changes — potentially many times. Keep it lightweight. |
| What is `translatesAutoresizingMaskIntoConstraints`? | A flag you set to `false` when adding constraints in code. Tells UIKit "don't auto-generate constraints for me." |
| What is the responder chain? | The path touch events travel through: View → ViewController → NavigationController → Window → App. If nobody handles it, the event is ignored. |
| `UIViewRepresentable` vs `UIHostingController`? | `UIViewRepresentable` wraps UIKit for use in SwiftUI. `UIHostingController` wraps SwiftUI for use in UIKit. |

---

## Module 3: State Management & Data Flow

> **Priority: CRITICAL.** This is where senior vs mid engineers are separated.
>
> **Deep dive:** [lessons/state-management-comparison.md](lessons/state-management-comparison.md) — full comparison of Observable, @Published, Redux, MVVM with decision guide and real-world scenarios.

"State" is just data that can change over time: the text in a search field, whether a loading spinner is showing, the list of items from an API. In SwiftUI, when state changes, the UI automatically updates. The key question is: **where does each piece of state live, and who can change it?**

---

### 3.1 The Spectrum of State Management

```
Local ←————————————————————————————→ Global
@State   @Binding   @Observable   @EnvironmentObject   Actor-isolated
  │         │           │               │                    │
Simple     Two-way    Shared          App-wide           Thread-safe
UI state   connection across views    injection          concurrent state
```

There's no single right answer — the senior-level answer is knowing **when to use which.**

---

### 3.2 @State — Local UI State

`@State` is the simplest form of state in SwiftUI. It's state that belongs to ONE specific view.

```swift
struct CounterView: View {
    // '@State' tells SwiftUI: "this is a piece of data that can change,
    // and when it does, re-render the view."
    // 'private' because no other view should directly access this.
    @State private var count = 0
    
    var body: some View {
        // '\(count)' embeds the count value in the string
        Text("Count: \(count)")
            .onTapGesture {
                count += 1   // changing @State triggers a re-render of body
            }
    }
}
```

**Rules for @State:**
- Only use inside `struct View` (not classes)
- Always mark `private` — other views shouldn't touch it directly
- Use for simple, local things: toggle states, form field text, animation triggers

```swift
struct ToggleExample: View {
    @State private var isOn = false       // toggle state
    @State private var searchText = ""    // text field contents
    @State private var showSheet = false  // whether a sheet is showing
    
    var body: some View {
        VStack {
            // 'Toggle' is a built-in on/off switch.
            // '$isOn' (with the dollar sign) creates a "binding" — explained next.
            Toggle("Dark Mode", isOn: $isOn)
            
            // 'TextField' is a text input field.
            // '$searchText' binds the text field to our state.
            TextField("Search...", text: $searchText)
            
            Button("Show Details") {
                showSheet = true
            }
            // '.sheet' presents a modal view that slides up from the bottom
            .sheet(isPresented: $showSheet) {
                Text("Detail view here")
            }
        }
    }
}
```

> **In plain English:** `@State` is like a local variable that, when changed, causes the screen to refresh. Use it for simple stuff within a single view — toggle switches, text fields, animation triggers. Think of it as "this view's private notepad."

---

### 3.3 @Binding — Two-Way Connection

`@Binding` lets a child view read AND write a parent's state. It's not a separate source of truth — it's a "window" into someone else's `@State`.

```swift
// PARENT owns the state with @State
struct ParentView: View {
    @State private var username = ""
    
    var body: some View {
        VStack {
            Text("Hello, \(username.isEmpty ? "stranger" : username)")
            
            // '$username' (with $) passes a BINDING, not just the value.
            // This lets the child view modify the parent's state.
            UsernameField(text: $username)
        }
    }
}

// CHILD uses @Binding to connect to parent's state
struct UsernameField: View {
    // '@Binding' means "I don't own this data — someone passed it to me,
    // and when I change it, the original changes too."
    @Binding var text: String
    
    var body: some View {
        TextField("Enter username", text: $text)
            .textFieldStyle(.roundedBorder)
    }
}
```

**The `$` prefix** creates a binding from a `@State` property. It's Swift's way of passing a two-way reference.

```swift
// $count is a Binding<Int> — it can read AND write the original @State
// count (without $) is just the current Int value — read-only
```

> **In plain English:** `@Binding` is like giving someone a remote control to your TV. They can change the channel (modify the value), and you'll both see the same channel. The parent keeps the actual state; the child just has a remote. Use it whenever a child component needs to modify its parent's data.

---

### 3.4 @Observable and ObservableObject — Shared State

When state needs to be shared across multiple views or contains complex logic, you move it out of the view into a separate class.

**Modern approach (iOS 17+) — `@Observable`:**

```swift
// 'import Observation' gives us the @Observable macro
import Observation

// '@Observable' is a "macro" — it automatically adds code that makes
// SwiftUI watch this class for changes.
// A "macro" is a Swift feature that generates boilerplate code for you at compile time.
@Observable
class UserViewModel {
    var name = ""          // SwiftUI will detect changes to this
    var isLoading = false  // and this
    var errorMessage: String?  // and this
    
    func loadUser() async {
        isLoading = true
        // Simulate network call
        // 'try? await Task.sleep' pauses for a duration
        try? await Task.sleep(for: .seconds(1))
        name = "Regis"
        isLoading = false
    }
}

struct ProfileView: View {
    // '@State' works with @Observable classes in iOS 17+
    @State private var viewModel = UserViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                // 'ProgressView' is a built-in loading spinner
                ProgressView("Loading...")
            } else {
                Text("Hello, \(viewModel.name)")
            }
        }
        // '.task' runs async code when the view appears
        .task {
            await viewModel.loadUser()
        }
    }
}
```

**Older approach (iOS 13+) — `ObservableObject` with `@Published`:**

You'll see this in most existing codebases because `@Observable` is newer.

```swift
// 'ObservableObject' is a protocol that says "I can notify SwiftUI when I change."
// Like LiveData in Android, but for the whole class.
class ProfileViewModel: ObservableObject {
    // '@Published' marks properties that should trigger UI updates when changed.
    // Without @Published, SwiftUI won't know the value changed.
    @Published var name = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadUser() async {
        isLoading = true
        try? await Task.sleep(for: .seconds(1))
        name = "Regis"
        isLoading = false
    }
}

struct ProfileView: View {
    // '@StateObject' creates AND owns an ObservableObject.
    // Use this when THIS view is responsible for the object's lifetime.
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else {
                Text("Hello, \(viewModel.name)")
            }
        }
        .task {
            await viewModel.loadUser()
        }
    }
}
```

**@StateObject vs @ObservedObject:**

```swift
// @StateObject — YOU create it, YOU own it. SwiftUI keeps it alive.
// Use when the view is the "source" of this object.
struct ParentView: View {
    @StateObject private var viewModel = MyViewModel()  // I own this
    
    var body: some View {
        ChildView(viewModel: viewModel)
    }
}

// @ObservedObject — someone ELSE created it, you're just using it.
// Use when the view receives the object from a parent.
struct ChildView: View {
    @ObservedObject var viewModel: MyViewModel  // I don't own this, parent does
    
    var body: some View {
        Text(viewModel.name)
    }
}
```

> **In plain English:** When state gets complex (loading states, network data, business logic), move it out of the view into a ViewModel class. Mark the class so SwiftUI can watch it for changes. `@Observable` (new, simpler) or `ObservableObject` + `@Published` (older, more common in existing code) both do this. `@StateObject` = "I created this." `@ObservedObject` = "Someone passed this to me."

---

### 3.5 @EnvironmentObject — App-Wide Shared State

For state that many unrelated views need (current user, theme settings, app configuration), use environment objects. They're injected at a high level and available to all child views — no need to pass them down through every intermediate view.

```swift
// The shared state class
class AppState: ObservableObject {
    @Published var currentUser: User?
    @Published var isDarkMode = false
}

// Inject at the top level of your app:
@main
struct MyApp: App {
    // Create it once at the app level
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // '.environmentObject' makes it available to ALL child views
                .environmentObject(appState)
        }
    }
}

// Access it from ANY descendant view — no matter how deeply nested:
struct SettingsView: View {
    // '@EnvironmentObject' reads the value from the environment.
    // The type must match what was injected. Crashes if not found!
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            if let user = appState.currentUser {
                Text("Logged in as \(user.name)")
            } else {
                Text("Not logged in")
            }
            
            Toggle("Dark Mode", isOn: $appState.isDarkMode)
        }
    }
}
```

> **In plain English:** `@EnvironmentObject` is like a global variable that any view can read. Instead of passing data from Parent → Child → Grandchild → GreatGrandchild, you inject it once at the top, and any view anywhere in the tree can grab it. Use it for truly app-wide state like the current user or theme.

---

### 3.6 MVVM Pattern (The iOS Standard)

**MVVM** stands for **Model-View-ViewModel**. It's the most common architecture pattern in iOS. Here's a complete example with everything explained:

```swift
// ---- MODEL ----
// The raw data structure. Just holds data, no UI logic.
// 'Codable' = can be converted to/from JSON
// 'Identifiable' = has a unique 'id' property (SwiftUI needs this for lists)
struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
}

// ---- VIEW ----
// Describes what the UI looks like. No business logic here.
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        // 'Group' is an invisible container — it lets you apply modifiers
        // to different views based on conditions.
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.errorMessage {
                VStack {
                    Text("Error: \(error)")
                    Button("Retry") {
                        // 'Task' creates a new async context so we can call 'await'
                        Task { await viewModel.loadUser() }
                    }
                }
            } else if let user = viewModel.user {
                VStack(alignment: .leading, spacing: 8) {
                    Text(user.name)
                        .font(.title)
                    Text(user.email)
                        .foregroundColor(.secondary)
                }
            }
        }
        .task { await viewModel.loadUser() }
    }
}

// ---- VIEWMODEL ----
// The bridge between Model and View. Contains business logic.
// '@MainActor' ensures all code runs on the main thread — required
// because UI updates MUST happen on the main thread (same as Android).
@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // The ViewModel receives its dependencies through the initializer.
    // This makes it easy to test — you can pass a mock repository.
    private let repository: UserRepository
    
    init(repository: UserRepository = UserRepository()) {
        self.repository = repository
    }
    
    func loadUser() async {
        isLoading = true
        errorMessage = nil
        
        do {
            user = try await repository.fetchCurrentUser()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

// ---- REPOSITORY ----
// Handles data fetching (network, database, etc.)
class UserRepository {
    func fetchCurrentUser() async throws -> User {
        // 'URLSession' is Apple's built-in networking library.
        // Like OkHttp in Android or fetch() in JavaScript.
        let url = URL(string: "https://api.example.com/user")!
        
        // 'URLSession.shared.data(from:)' fetches data from a URL.
        // 'try await' because it's async and can fail.
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // 'JSONDecoder' converts JSON data into a Swift struct.
        // Works because User conforms to 'Codable'.
        return try JSONDecoder().decode(User.self, from: data)
    }
}
```

> **In plain English:** MVVM splits your code into three layers. The **Model** is pure data (a `User` struct). The **View** describes the UI (SwiftUI code). The **ViewModel** sits between them — it fetches data, handles errors, and exposes state the View can display. The View never talks to the network directly. This separation makes code testable and organized.

---

### 3.7 Combine Framework (Brief Intro)

**Combine** is Apple's framework for handling streams of values over time. Think of it as RxJava/RxKotlin for iOS. It's being gradually replaced by `async/await` for many use cases, but you'll still see it in existing codebases.

```swift
import Combine

class SearchViewModel: ObservableObject {
    @Published var query = ""       // the text the user types
    @Published var results: [String] = []
    
    // 'Set<AnyCancellable>' stores subscriptions so they stay alive.
    // When this set is deallocated, all subscriptions are cancelled.
    // Think of it as a "subscription bag" — like disposables in RxJava.
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // '$query' gives us a "publisher" — a stream of values over time.
        // Each time the user types, a new value flows through this chain.
        $query
            // Wait 300ms after the user stops typing before proceeding.
            // This avoids searching on every keystroke.
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            // Don't search again if the text didn't actually change.
            .removeDuplicates()
            // Only search if the query has more than 2 characters.
            .filter { $0.count > 2 }
            // '.sink' subscribes to the stream and runs code for each value.
            .sink { [weak self] searchText in
                self?.performSearch(searchText)
            }
            // '.store' keeps the subscription alive in our cancellables set.
            .store(in: &cancellables)
    }
    
    private func performSearch(_ text: String) {
        // search logic here
        results = ["Result for \(text)"]
    }
}
```

**Key Combine operators you'll see:**
- `debounce` — wait for a pause in values (great for search-as-you-type)
- `removeDuplicates` — skip identical consecutive values
- `filter` — only let values through that pass a test
- `map` — transform each value
- `sink` — subscribe and receive values

> **In plain English:** Combine lets you set up a pipeline: "when this value changes, wait 300ms, check if it's different from last time, and if so, run a search." Instead of writing lots of timer and flag logic yourself, you chain operators together like building blocks. It's powerful but has a steep learning curve. For new code, `async/await` (Module 5) is often simpler.

---

### 3.8 Decision Table — When to Use What

| Tool | Scope | Use When | Example |
|------|-------|----------|---------|
| `@State` | Single view | Simple UI toggles, form fields | Toggle dark mode, text field contents |
| `@Binding` | Parent ↔ child | Child needs to modify parent's state | Reusable form components |
| `@Observable` / `ObservableObject` | Shared across views | ViewModel pattern, shared business logic | User profile, shopping cart |
| `@EnvironmentObject` | Entire app / subtree | App-wide state, avoiding prop drilling | Current user, theme, settings |
| Combine | Reactive streams | Complex event pipelines, debouncing | Search-as-you-type, form validation |
| Actor | Concurrent state | Thread-safe state accessed from multiple threads | Cache manager, analytics |

---

### Module 3 — Quick-Fire Answers

| Question | Answer |
|----------|--------|
| `@StateObject` vs `@ObservedObject`? | `@StateObject` creates and owns the object. `@ObservedObject` borrows one that was created elsewhere. |
| What is `@Published`? | A property wrapper on `ObservableObject` properties that tells SwiftUI "update the UI when this changes." |
| What does `@MainActor` do? | Guarantees all code runs on the main thread. Required for anything that updates the UI. |
| What is `@Observable`? | A macro (iOS 17+) that automatically makes a class observable by SwiftUI. Simpler than `ObservableObject` + `@Published`. |
| When to use `@EnvironmentObject`? | For app-wide state that many unrelated views need, like the current user or theme settings. |

---

## Module 4: Architecture & Project Structure

> **Priority: HIGH.** Senior engineers own codebases, not just features.

Architecture is about organizing code so it's understandable, testable, and maintainable. Interviewers want to see that you think beyond "make it work."

---

### 4.1 Common Patterns

**MVVM (Most Common in iOS):**

```
View → ViewModel → Model
       ↑              ↓
    Binding      Repository (network/database)
```

The View displays data. The ViewModel contains logic and state. The Model is raw data. The Repository fetches data from the network or database.

**Clean Architecture:**

```
Presentation → Domain → Data
   (Views,      (Business logic,    (API clients,
    ViewModels)  Use Cases)          Repositories,
                                     Database)
```

Each layer only knows about the layer "below" it. The Domain layer has no idea about UIKit, SwiftUI, or networking libraries. This makes it very testable.

**VIPER:**

```
View → Interactor → Presenter → Entity
         ↑              ↓
      Router        Repository
```

More separation than MVVM but more boilerplate. Used in large teams where clear boundaries matter.

```swift
// MVVM example — the most common and what you should default to:

// Model: just data
struct Product: Identifiable, Codable {
    let id: String
    let name: String
    let price: Double
}

// ViewModel: logic and state
@MainActor
class ProductListViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    
    private let repository: ProductRepository
    
    init(repository: ProductRepository = ProductRepository()) {
        self.repository = repository
    }
    
    func loadProducts() async {
        isLoading = true
        do {
            products = try await repository.fetchAll()
        } catch {
            print("Failed to load: \(error)")
        }
        isLoading = false
    }
}

// View: just UI
struct ProductListView: View {
    @StateObject private var viewModel = ProductListViewModel()
    
    var body: some View {
        List(viewModel.products) { product in
            HStack {
                Text(product.name)
                Spacer()  // pushes the next view to the right edge
                Text("$\(product.price, specifier: "%.2f")")
            }
        }
        .task { await viewModel.loadProducts() }
    }
}
```

> **In plain English:** Architecture patterns are just ways of organizing your files and responsibilities. MVVM (the iOS standard) separates your code into "what the user sees" (View), "what logic drives the screen" (ViewModel), and "raw data" (Model). The goal: each piece does one thing, is easy to test, and doesn't depend on things it shouldn't.

---

### 4.2 Recommended Project Structure

```
MyApp/
├── App/                    ← App entry point and setup
│   ├── MyApp.swift         ← @main struct
│   └── DIContainer.swift   ← Dependency injection setup
├── Features/               ← Each feature gets its own folder
│   ├── Auth/
│   │   ├── Views/          ← SwiftUI views
│   │   ├── ViewModels/     ← Business logic
│   │   └── Models/         ← Data structures
│   ├── Home/
│   │   └── ...
│   └── Profile/
│       └── ...
├── Core/                   ← Shared infrastructure
│   ├── Network/            ← API client, request builder
│   ├── Database/           ← Persistence (Core Data, SwiftData)
│   ├── Utils/              ← Helpers, formatters
│   └── Extensions/         ← Extensions on system types
├── Resources/              ← Non-code assets
│   ├── Assets.xcassets     ← Images, colors
│   └── Info.plist          ← App configuration
└── Tests/
    ├── UnitTests/
    └── UITests/
```

---

### 4.3 Dependency Injection

**Dependency injection (DI)** means "give an object its dependencies from outside, instead of having it create them internally." This makes testing easy because you can swap real dependencies for fakes.

```swift
// WITHOUT DI — hard to test:
class ProfileViewModel: ObservableObject {
    func loadUser() async {
        // This creates a REAL network client internally.
        // In a test, you can't prevent it from hitting the real server.
        let data = try? await URLSession.shared.data(from: someURL)
    }
}

// WITH DI — easy to test:

// First, define what the dependency can do (protocol = interface):
protocol UserRepositoryProtocol {
    func fetchCurrentUser() async throws -> User
}

// Real implementation (used in production):
class UserRepository: UserRepositoryProtocol {
    func fetchCurrentUser() async throws -> User {
        let (data, _) = try await URLSession.shared.data(from: someURL)
        return try JSONDecoder().decode(User.self, from: data)
    }
}

// Fake implementation (used in tests):
class MockUserRepository: UserRepositoryProtocol {
    var userToReturn: User?
    var errorToThrow: Error?
    
    func fetchCurrentUser() async throws -> User {
        if let error = errorToThrow { throw error }
        return userToReturn ?? User(id: "1", name: "Test", email: "test@test.com")
    }
}

// ViewModel accepts the dependency through its initializer:
@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    
    // Accept a protocol, not a concrete class
    private let repository: UserRepositoryProtocol
    
    // Default to real implementation; tests can pass a mock
    init(repository: UserRepositoryProtocol = UserRepository()) {
        self.repository = repository
    }
    
    func loadUser() async {
        user = try? await repository.fetchCurrentUser()
    }
}

// In tests:
// let mockRepo = MockUserRepository()
// mockRepo.userToReturn = User(id: "1", name: "Test User", email: "test@test.com")
// let viewModel = ProfileViewModel(repository: mockRepo)
// await viewModel.loadUser()
// XCTAssertEqual(viewModel.user?.name, "Test User")
```

> **In plain English:** Dependency injection means "don't bake in your ingredients — let the chef choose." Instead of a ViewModel creating its own network client, you pass one in. In production, you pass the real one. In tests, you pass a fake that returns predetermined data. This lets you test your logic without hitting real servers.

---

### Module 4 — Quick-Fire Answers

| Question | Answer |
|----------|--------|
| MVVM vs VIPER? | MVVM: simpler, less boilerplate, good for most apps. VIPER: more separation, better for large teams, more files to manage. |
| Why dependency injection? | Testability, flexibility, clear dependencies. You can swap implementations without changing the class. |
| Where to put business logic? | In the ViewModel (MVVM) or Use Case class (Clean Architecture). Never in the View. |
| What's a `DIContainer`? | A central place that creates and holds all your app's shared objects (network client, database, etc.) |

---

## Module 5: Concurrency — async/await, Actors & Tasks

> **Priority: CRITICAL.** Modern Swift concurrency is expected at senior level.

"Concurrency" means running multiple things at the same time — like fetching data from the network while the user scrolls through the UI. Before Swift 5.5, this was done with callbacks (completion handlers) and was messy. Modern Swift has `async/await`, which is much cleaner.

---

### 5.1 async/await Basics

`async` marks a function that does work that takes time (network calls, file I/O). `await` is how you call it — it suspends execution until the result is ready, WITHOUT blocking the thread.

```swift
// 'async' = this function does asynchronous work
// 'throws' = this function can fail
// The return type is User
func fetchUser(id: String) async throws -> User {
    // Create a URL from a string
    guard let url = URL(string: "https://api.example.com/users/\(id)") else {
        throw NetworkError.invalidURL
    }
    
    // 'URLSession.shared' is the built-in networking client.
    // '.data(from:)' downloads data from a URL.
    // 'try await' because it's async AND can fail.
    // Returns a tuple: (the data bytes, the HTTP response)
    let (data, response) = try await URLSession.shared.data(from: url)
    
    // 'as?' attempts to cast the response to HTTPURLResponse
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw NetworkError.serverError
    }
    
    // Convert JSON data into a User struct
    return try JSONDecoder().decode(User.self, from: data)
}

// CALLING async code:
// You can only use 'await' inside an async context.
// 'Task { }' creates a new async context.
Task {
    do {
        let user = try await fetchUser(id: "123")
        print("Got user: \(user.name)")
    } catch {
        print("Failed: \(error)")
    }
}
```

**In SwiftUI, use `.task` modifier:**

```swift
struct UserView: View {
    @State private var user: User?
    
    var body: some View {
        VStack {
            if let user = user {
                Text(user.name)
            } else {
                ProgressView()
            }
        }
        // '.task' creates an async context tied to the view's lifetime.
        // It's automatically cancelled when the view disappears.
        .task {
            user = try? await fetchUser(id: "123")
        }
    }
}
```

> **In plain English:** `async/await` is Swift's way of writing asynchronous code that reads like normal, top-to-bottom code. Instead of callback hell (`fetchUser { result in switch result { case .success(let user): fetchPosts(for: user) { ... } } }`), you just write `let user = try await fetchUser(...)` and the next line runs after the result arrives.

---

### 5.2 Task & TaskGroup

A **Task** is a unit of asynchronous work. You can create them, cancel them, and run groups of them in parallel.

```swift
@MainActor
class DownloadViewModel: ObservableObject {
    @Published var items: [Item] = []
    
    // Store a reference to the task so we can cancel it
    private var loadTask: Task<Void, Never>?
    // 'Task<Void, Never>' means "a task that returns nothing and never throws"
    
    func startLoading() {
        // Cancel any existing task before starting a new one
        loadTask?.cancel()
        
        loadTask = Task {
            // 'Task.isCancelled' lets you check if someone cancelled this task
            guard !Task.isCancelled else { return }
            
            let fetchedItems = await fetchItems()
            
            // Check again — the task might have been cancelled while we were fetching
            guard !Task.isCancelled else { return }
            
            items = fetchedItems
        }
    }
    
    func stopLoading() {
        loadTask?.cancel()  // cancel the in-flight request
    }
    
    private func fetchItems() async -> [Item] {
        // network call...
        return []
    }
}

// TASK GROUP — run multiple async tasks in parallel:
func fetchAllUsers(ids: [String]) async throws -> [User] {
    // 'withThrowingTaskGroup' runs tasks concurrently and collects results.
    // 'of: User.self' = each subtask returns a User.
    try await withThrowingTaskGroup(of: User.self) { group in
        // Add a task for each user ID — they all run in parallel
        for id in ids {
            group.addTask {
                try await self.fetchUser(id: id)
            }
        }
        
        // Collect results as they complete
        var users: [User] = []
        for try await user in group {
            users.append(user)
        }
        return users
    }
}
// If you have 10 user IDs, this fetches all 10 simultaneously instead of one by one!
```

> **In plain English:** A `Task` is like launching a background job. You can cancel it if the user navigates away. A `TaskGroup` is like launching many background jobs at once and waiting for all of them to finish — perfect for fetching multiple pieces of data simultaneously.

---

### 5.3 Actors — Thread-Safe Classes

An **actor** is a special kind of class that guarantees only one piece of code can access its data at a time — like a bank teller window where customers must wait in line. This prevents bugs where two threads change the same value simultaneously (called a "data race").

```swift
// 'actor' instead of 'class' — that's the only difference in declaration!
// Swift automatically makes all access sequential (one at a time).
actor ShoppingCart {
    // These properties are "isolated" — only one caller can access them at a time
    private var items: [String] = []
    private var total: Double = 0.0
    
    func addItem(_ item: String, price: Double) {
        items.append(item)
        total += price
        // No race conditions possible! The actor ensures exclusive access.
    }
    
    func getTotal() -> Double {
        return total
    }
    
    func getItems() -> [String] {
        return items
    }
}

// Using an actor — you MUST use 'await' because access might need to wait
let cart = ShoppingCart()
await cart.addItem("Widget", price: 9.99)
await cart.addItem("Gadget", price: 19.99)
let total = await cart.getTotal()  // 29.98
```

**@MainActor — the special actor for UI:**

```swift
// '@MainActor' is a built-in actor for the main thread.
// All UI updates MUST happen on the main thread (same rule as Android).
// Marking a class @MainActor ensures all its code runs on the main thread.

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var name = ""  // UI property — must be updated on main thread
    
    func loadProfile() async {
        // Even though we're calling async code, the @MainActor annotation
        // ensures that updating 'name' happens on the main thread.
        let user = try? await fetchUser()
        name = user?.name ?? "Unknown"  // safe to update UI
    }
}
```

> **In plain English:** Without actors, if two parts of your code try to modify the same data at the same time, you get random, hard-to-debug crashes called "data races." An actor prevents this by putting a bouncer at the door — only one caller gets in at a time. `@MainActor` is a special actor that means "this code must run on the main thread" (required for all UI updates).

---

### 5.4 Sendable — Thread Safety at Compile Time

**Sendable** is a protocol that marks types as safe to pass between concurrent contexts (actors, tasks, threads). It's how Swift prevents data races at compile time.

```swift
// Structs with only immutable ('let') properties are automatically Sendable:
struct User: Sendable {
    let id: String       // immutable — safe to share
    let name: String     // immutable — safe to share
}
// Because all properties are 'let', two threads can read this without conflict.

// Mutable classes are NOT Sendable by default — sharing them is unsafe:
class MutableCounter {
    var value = 0  // two threads could change this simultaneously = data race!
}

// To make a class Sendable, either:
// 1. Make it an actor (preferred)
actor SafeCounter {
    var value = 0
    func increment() { value += 1 }
}

// 2. Or manually ensure thread safety and mark it @unchecked Sendable
// '@unchecked' means "trust me, I'm handling thread safety myself"
// 'final' means "no subclass can be created from this class"
final class LockedCounter: @unchecked Sendable {
    private var value = 0
    private let lock = NSLock()  // a mutex lock for thread safety
    
    func increment() {
        lock.lock()              // acquire the lock (blocks other threads)
        defer { lock.unlock() }  // 'defer' = "run this when leaving the scope"
        value += 1
    }
}
```

> **In plain English:** `Sendable` tells the Swift compiler "this type is safe to share across threads." Structs with only constants (`let`) are automatically safe. Classes with mutable state need either an actor (recommended) or manual locking. The compiler will warn you if you try to pass non-Sendable types across concurrency boundaries.

---

### Module 5 — Quick-Fire Answers

| Question | Answer |
|----------|--------|
| What does `await` do? | Suspends execution until the async operation completes, without blocking the thread. Other work can happen while waiting. |
| What is `@MainActor`? | Ensures all code runs on the main thread. Required for any code that updates the UI. |
| How do you cancel a Task? | Call `.cancel()` on the task reference, or let it deallocate. Check `Task.isCancelled` inside the task. |
| What is `Sendable`? | A protocol marking types as safe to pass across concurrency boundaries (between actors/tasks/threads). |
| Actor vs class? | An actor is a class with automatic mutual exclusion — only one caller can access its state at a time. Prevents data races. |
| What is a data race? | A bug where two threads access the same mutable data simultaneously, causing unpredictable behavior. |

---

## Module 6: Navigation & View Controllers

> **Priority: HIGH.** Practical, frequently tested.

Navigation is how users move between screens. There are different approaches in UIKit and SwiftUI.

---

### 6.1 UIKit Navigation

In UIKit, navigation is managed by a **UINavigationController** — a container that maintains a stack of screens (view controllers). You "push" screens onto the stack to go forward, and "pop" them to go back.

```swift
class UserListViewController: UIViewController {
    
    // Navigate TO a new screen (push onto the navigation stack):
    func goToUserDetail(user: User) {
        let detailVC = UserDetailViewController()
        detailVC.user = user  // pass data to the next screen
        
        // 'navigationController?' is optional because this VC might not be
        // inside a navigation controller.
        // 'pushViewController' adds a new screen on top with a back button.
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // Navigate BACK (pop from the stack):
    func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    // Present a modal (slides up from bottom, separate from navigation stack):
    func showSettings() {
        let settingsVC = SettingsViewController()
        // '.pageSheet' is the default modal style — partial cover on iPad
        settingsVC.modalPresentationStyle = .pageSheet
        // 'present' shows a modal on top of the current screen
        present(settingsVC, animated: true)
    }
    
    // Dismiss a modal:
    func closeSettings() {
        dismiss(animated: true)
    }
}

// Receiving data in the destination screen:
class UserDetailViewController: UIViewController {
    // Set by the previous screen before navigation
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 'title' sets the text in the navigation bar
        title = user?.name ?? "User"
    }
}
```

> **In plain English:** UIKit navigation works like a stack of cards. `pushViewController` puts a new card on top (showing a new screen with a back button). `popViewController` removes the top card (going back). `present` slides a card up from the bottom (a modal, like a popup).

---

### 6.2 SwiftUI Navigation

**NavigationStack (iOS 16+) — the modern approach:**

```swift
struct ContentView: View {
    // 'NavigationPath' manages the stack of screens.
    // Like a browser's history stack.
    @State private var navigationPath = NavigationPath()
    
    let fruits = ["Apple", "Banana", "Cherry"]
    
    var body: some View {
        // 'NavigationStack' is the SwiftUI equivalent of UINavigationController.
        // 'path: $navigationPath' gives us programmatic control over the stack.
        NavigationStack(path: $navigationPath) {
            // 'List' creates a scrollable list (like UITableView)
            List(fruits, id: \.self) { fruit in
                // 'NavigationLink' makes a row tappable for navigation.
                // 'value:' specifies what data to push onto the navigation path.
                NavigationLink(value: fruit) {
                    Text(fruit)
                }
            }
            .navigationTitle("Fruits")
            // '.navigationDestination' tells NavigationStack what screen to show
            // for each type of value pushed onto the path.
            .navigationDestination(for: String.self) { fruit in
                // This view is shown when a String is pushed
                Text("You selected: \(fruit)")
                    .font(.largeTitle)
            }
        }
    }
}

// Programmatic navigation (without user tapping a link):
struct ProgrammaticNavExample: View {
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Button("Go to Settings") {
                    path.append("settings")    // push a screen
                }
                Button("Go to Profile") {
                    path.append("profile")     // push another screen
                }
                Button("Go Back to Root") {
                    path = NavigationPath()    // clear the stack = go to root
                }
            }
            .navigationDestination(for: String.self) { screen in
                Text("Screen: \(screen)")
            }
        }
    }
}
```

**Sheets (modals in SwiftUI):**

```swift
struct SheetExample: View {
    @State private var showSheet = false
    
    var body: some View {
        Button("Show Details") {
            showSheet = true
        }
        // '.sheet' presents a modal when 'showSheet' becomes true.
        // Swiping down dismisses it automatically.
        .sheet(isPresented: $showSheet) {
            DetailSheet()
        }
    }
}

struct DetailSheet: View {
    // '@Environment(\.dismiss)' gives us a function to close this sheet
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("Detail View")
            Button("Close") {
                dismiss()  // programmatically close the sheet
            }
        }
    }
}
```

> **In plain English:** In SwiftUI, `NavigationStack` manages a stack of screens. `NavigationLink` makes things tappable for navigation. `.sheet` shows a modal popup. The cool part: it's all data-driven. Push a value onto the path → a screen appears. Remove it → back to the previous screen. No manual "push this controller" code needed.

---

### 6.3 Deep Linking

Deep linking lets external sources (websites, notifications, other apps) open your app directly to a specific screen.

```swift
// SwiftUI deep linking:
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                // '.onOpenURL' is called when someone opens a URL like
                // myapp://profile/123 or https://myapp.com/profile/123
                .onOpenURL { url in
                    // 'url.pathComponents' breaks the URL into parts
                    // e.g., ["profile", "123"]
                    handleDeepLink(url)
                }
        }
    }
    
    func handleDeepLink(_ url: URL) {
        // Parse the URL and navigate to the right screen
        // e.g., if url is "myapp://profile/123", show user 123's profile
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let host = components.host else { return }
        
        switch host {
        case "profile":
            // Navigate to profile screen
            break
        case "settings":
            // Navigate to settings screen
            break
        default:
            break
        }
    }
}
```

> **In plain English:** Deep linking means your app can be opened to a specific screen from outside — like clicking a link in an email that opens directly to a product page in your app, instead of the home screen.

---

### Module 6 — Quick-Fire Answers

| Question | Answer |
|----------|--------|
| `NavigationStack` vs `NavigationView`? | `NavigationStack` (iOS 16+) is the modern replacement with better programmatic path management. `NavigationView` is deprecated. |
| How to pass data in SwiftUI navigation? | Use `NavigationLink(value:)` with `.navigationDestination(for:)`, or pass via environment/bindings. |
| Push vs present (modal)? | Push adds to the navigation stack (has back button). Present shows a modal on top (swipe to dismiss). |
| What is `@Environment(\.dismiss)`? | A built-in function to programmatically dismiss the current view (close a sheet, pop a navigation screen). |

---

## Module 7: Performance & Optimization

> **Priority: HIGH.** Shows production experience.

Performance means your app feels fast and responsive. The main enemy: doing too much work on the main thread, which freezes the UI.

---

### 7.1 Common Bottlenecks

| Issue | What it looks like | How to fix it |
|-------|-------------------|---------------|
| Main thread blocking | UI freezes, animations stutter | Move work to background with `async/await` or `Task` |
| Too many view updates | App feels sluggish when scrolling | Use `@State` properly, avoid unnecessary redraws |
| Large images in memory | App crashes or gets killed by iOS | Resize images, use thumbnails, lazy loading |
| Retain cycles | Memory keeps growing, never goes down | Use `[weak self]` in closures (see Module 1.5) |

---

### 7.2 SwiftUI Performance

```swift
// PROBLEM: Creating all views upfront for a long list
// VStack creates ALL child views immediately, even off-screen ones
VStack {
    ForEach(thousandsOfItems) { item in
        ExpensiveView(item: item)  // ALL created at once = slow
    }
}

// FIX: Use 'List' or 'LazyVStack' — they only create VISIBLE views
// 'Lazy' means "don't create views until they're about to appear on screen"
LazyVStack {
    ForEach(thousandsOfItems) { item in
        ExpensiveView(item: item)  // only created when scrolled into view
    }
}

// Or use List (which is already lazy):
List(thousandsOfItems) { item in
    Text(item.name)
}

// PROBLEM: Heavy computation in body
struct BadView: View {
    let items: [Item]
    
    var body: some View {
        // DON'T sort inside body — it runs on every re-render!
        let sorted = items.sorted { $0.name < $1.name }
        List(sorted) { item in Text(item.name) }
    }
}

// FIX: Use a computed property (SwiftUI can cache this more efficiently)
struct GoodView: View {
    let items: [Item]
    
    // Computed property — calculated once per view evaluation
    private var sortedItems: [Item] {
        items.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        List(sortedItems) { item in Text(item.name) }
    }
}
```

---

### 7.3 UIKit Performance: Cell Reuse

In UIKit, `UITableView` and `UICollectionView` reuse cells instead of creating new ones for each row. This is critical for performance with long lists.

```swift
// 'UITableViewDataSource' is a protocol that provides data to the table.
// The table asks "give me the cell for row X" and you return it.
func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath  // 'IndexPath' = section + row number
) -> UITableViewCell {
    // 'dequeueReusableCell' — instead of creating a NEW cell for each row,
    // it REUSES a cell that scrolled off-screen. Like recycling!
    // This is why UITableView can handle thousands of rows without lag.
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
    // Configure the recycled cell with the current row's data:
    cell.textLabel?.text = items[indexPath.row]
    return cell
}
```

---

### 7.4 Memory Management

iOS uses **ARC (Automatic Reference Counting)** to manage memory. Unlike garbage collection (Java/Kotlin), ARC frees objects immediately when they're no longer needed. But you need to avoid retain cycles (Module 1.5).

```swift
// Detecting memory issues:
// 1. Xcode → Debug → Memory Graph — shows all objects and their references
// 2. Instruments → Leaks — finds objects that are never freed

// Image caching to avoid loading the same image multiple times:
// 'NSCache' is a built-in cache that automatically evicts items under memory pressure.
let imageCache = NSCache<NSString, UIImage>()
imageCache.countLimit = 100                    // max 100 images
imageCache.totalCostLimit = 50 * 1024 * 1024   // max 50MB

func loadImage(url: String) async -> UIImage? {
    // Check cache first
    if let cached = imageCache.object(forKey: url as NSString) {
        return cached  // found in cache, no network needed!
    }
    
    // Not in cache — download it
    guard let imageURL = URL(string: url),
          let (data, _) = try? await URLSession.shared.data(from: imageURL),
          let image = UIImage(data: data) else {
        return nil
    }
    
    // Store in cache for next time
    imageCache.setObject(image, forKey: url as NSString)
    return image
}
```

> **In plain English:** Performance in iOS comes down to two things: (1) don't freeze the main thread (do heavy work in the background), and (2) don't waste memory (reuse cells in lists, cache images, avoid retain cycles). Use `LazyVStack` instead of `VStack` for long lists, and always use `[weak self]` in closures to prevent memory leaks.

---

### Module 7 — Quick-Fire Answers

| Question | Answer |
|----------|--------|
| How to detect retain cycles? | Xcode Memory Graph debugger — look for unexpected strong reference loops. |
| What is `dequeueReusableCell`? | Reuses table/collection cells that scrolled off-screen instead of creating new ones. Critical for performance. |
| Why `LazyVStack` over `VStack`? | `LazyVStack` only creates views when they're about to appear on screen. `VStack` creates all of them immediately. |
| What is ARC? | Automatic Reference Counting — Swift's memory management. Objects are freed when no strong references remain. |

---

## Module 8: Testing Strategy

> **Priority: HIGH.** Non-negotiable in production-grade apps.

Testing in iOS uses Apple's `XCTest` framework (built into Xcode). Tests prove your code works correctly and catch regressions when you change things.

---

### 8.1 Unit Testing ViewModels

```swift
// 'import XCTest' brings in the testing framework
import XCTest
// '@testable import MyApp' gives test access to your app's internal types
@testable import MyApp

// Test class must inherit from 'XCTestCase'
final class ProfileViewModelTests: XCTestCase {
    // '!' means these will be set in setUp() before each test
    var viewModel: ProfileViewModel!
    var mockRepository: MockUserRepository!
    
    // 'setUp' runs BEFORE each test method — set up fresh objects
    override func setUp() {
        mockRepository = MockUserRepository()
        viewModel = ProfileViewModel(repository: mockRepository)
    }
    
    // 'tearDown' runs AFTER each test — clean up
    override func tearDown() {
        viewModel = nil
        mockRepository = nil
    }
    
    // Test method names must start with 'test'
    func test_loadUser_success_updatesUserAndStopsLoading() async {
        // GIVEN — set up the test scenario
        let expectedUser = User(id: "1", name: "Test User", email: "test@test.com")
        mockRepository.userToReturn = expectedUser
        
        // WHEN — perform the action
        await viewModel.loadUser()
        
        // THEN — verify the results
        // 'XCTAssertEqual' checks that two values are equal
        XCTAssertEqual(viewModel.user?.name, "Test User")
        // 'XCTAssertFalse' checks that a value is false
        XCTAssertFalse(viewModel.isLoading)
        // 'XCTAssertNil' checks that a value is nil
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func test_loadUser_failure_setsErrorMessage() async {
        // GIVEN
        mockRepository.errorToThrow = NetworkError.serverError
        
        // WHEN
        await viewModel.loadUser()
        
        // THEN
        XCTAssertNil(viewModel.user)
        // 'XCTAssertNotNil' checks that a value is NOT nil
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
}
```

---

### 8.2 UI Testing

UI tests launch the actual app and simulate user interactions:

```swift
import XCTest

final class LoginUITests: XCTestCase {
    // 'XCUIApplication' represents the running app
    var app: XCUIApplication!
    
    override func setUp() {
        app = XCUIApplication()
        app.launch()  // starts the app fresh for each test
    }
    
    func test_loginFlow_showsWelcomeOnSuccess() {
        // Find the email text field and type in it
        let emailField = app.textFields["email"]
        emailField.tap()
        emailField.typeText("test@example.com")
        
        // Find the password field (secure = hidden text)
        let passwordField = app.secureTextFields["password"]
        passwordField.tap()
        passwordField.typeText("password123")
        
        // Tap the login button
        app.buttons["Login"].tap()
        
        // Wait for and verify the welcome text appears
        // 'waitForExistence' pauses the test until the element appears (or timeout)
        let welcomeText = app.staticTexts["Welcome"]
        XCTAssertTrue(welcomeText.waitForExistence(timeout: 5))
    }
}
```

> **In plain English:** Unit tests verify small pieces of logic work correctly (like "does the ViewModel set the user after a successful fetch?"). UI tests verify the actual app works from the user's perspective (like "can the user log in by typing email, password, and tapping Login?"). Both use `XCTAssert` methods to check expectations.

---

### Module 8 — Quick-Fire Answers

| Question | Answer |
|----------|--------|
| What is `XCTest`? | Apple's built-in testing framework. Like JUnit for Java or pytest for Python. |
| What is mocking? | Replacing real dependencies with fake ones that return predetermined data. Lets you test logic without hitting real servers. |
| `XCTAssert` vs `XCTAssertEqual`? | `XCTAssert` checks a boolean is true. `XCTAssertEqual` checks two values are equal (gives better error messages). |
| Why the Given/When/Then pattern? | Organizes tests clearly: set up the scenario, perform the action, verify the result. Makes tests readable. |

---

## Module 9: Native Features & Frameworks

> **Priority: MEDIUM-HIGH.** Differentiator for senior roles.

iOS has many built-in frameworks. Here are the ones most commonly discussed in interviews.

---

### 9.1 Data Persistence — Core Data and SwiftData

**Core Data** is Apple's older framework for storing data locally on the device. It's like a local SQLite database with an object-oriented interface.

```swift
import CoreData

class CoreDataStack {
    // 'static let shared' creates a single instance for the entire app.
    // This is the "singleton" pattern — only one CoreDataStack ever exists.
    static let shared = CoreDataStack()
    
    // 'NSPersistentContainer' is the main Core Data object.
    // It manages the database file, the schema, and the context for reading/writing.
    // Think of it as the "database manager."
    lazy var persistentContainer: NSPersistentContainer = {
        // 'lazy var' = this property is created the FIRST time it's accessed.
        // "MyApp" must match your Core Data model file name.
        let container = NSPersistentContainer(name: "MyApp")
        container.loadPersistentStores { _, error in
            if let error = error {
                // 'fatalError' crashes the app with a message.
                // In production, handle this more gracefully.
                fatalError("Core Data load failed: \(error)")
            }
        }
        return container
    }()
    
    // 'NSManagedObjectContext' is where you read and write data.
    // Think of it as a "scratchpad" — you make changes here, then save.
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func save() {
        if context.hasChanges {
            try? context.save()  // write changes to disk
        }
    }
}
```

**SwiftData (iOS 17+)** is the modern replacement for Core Data, with much simpler syntax:

```swift
import SwiftData

// '@Model' is a macro that makes this class persistable (stored in a database).
// Much simpler than Core Data's NSManagedObject!
@Model
class Todo {
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    
    init(title: String, isCompleted: Bool = false) {
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = Date()
    }
}

// Using in SwiftUI:
struct TodoListView: View {
    // '@Query' automatically fetches all Todo items from the database.
    // It updates the view whenever the data changes.
    @Query(sort: \Todo.createdAt) var todos: [Todo]
    
    // '@Environment(\.modelContext)' gives access to the database context
    @Environment(\.modelContext) var context
    
    var body: some View {
        List(todos) { todo in
            Text(todo.title)
        }
    }
    
    func addTodo(title: String) {
        let todo = Todo(title: title)
        context.insert(todo)  // add to database
        // SwiftData auto-saves!
    }
}
```

> **In plain English:** Core Data and SwiftData let your app save data locally on the device so it persists between app launches. Core Data is older and more verbose. SwiftData (iOS 17+) is newer and much simpler. Both ultimately store data in a SQLite database under the hood.

---

### 9.2 UserDefaults — Simple Key-Value Storage

`UserDefaults` is for storing small, simple preferences — NOT for large amounts of data.

```swift
// Save a value:
UserDefaults.standard.set("dark", forKey: "theme")
UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
UserDefaults.standard.set(42, forKey: "highScore")

// Read a value:
let theme = UserDefaults.standard.string(forKey: "theme")  // Optional("dark")
let seen = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")  // true
let score = UserDefaults.standard.integer(forKey: "highScore")  // 42

// A nicer approach using a property wrapper:
// (A "property wrapper" is a Swift feature that adds behavior to properties.
// The '@' syntax you've been seeing — @State, @Published — are all property wrappers.)
@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    // 'wrappedValue' is the value you get/set when using the property normally
    var wrappedValue: T {
        get { UserDefaults.standard.object(forKey: key) as? T ?? defaultValue }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}

// Usage — now reading/writing UserDefaults looks like a normal property:
struct Settings {
    @UserDefault(key: "hasSeenOnboarding", defaultValue: false)
    static var hasSeenOnboarding: Bool
    
    @UserDefault(key: "username", defaultValue: "Guest")
    static var username: String
}

// Read:
print(Settings.username)  // "Guest" (or whatever was saved)
// Write:
Settings.username = "Regis"
```

> **In plain English:** `UserDefaults` is a simple key-value store, like `SharedPreferences` in Android or `localStorage` in the browser. Use it for small settings (theme preference, "has seen onboarding"). Don't use it for large data sets or sensitive data (use Keychain for secrets, Core Data/SwiftData for structured data).

---

### 9.3 NotificationCenter — Broadcasting Messages

`NotificationCenter` is a way for parts of your app to communicate without knowing about each other directly. One part "posts" a notification, and any part that's "observing" receives it.

```swift
// Define a custom notification name:
extension Notification.Name {
    // 'static let' = a constant that belongs to the type, not instances
    static let userDidLogin = Notification.Name("userDidLogin")
}

// POST a notification (send a message):
NotificationCenter.default.post(
    name: .userDidLogin,
    object: nil,  // the sender (optional)
    userInfo: ["userId": "123"]  // extra data (optional dictionary)
)

// OBSERVE a notification (listen for the message):
// Option 1: Closure-based (preferred)
let observer = NotificationCenter.default.addObserver(
    forName: .userDidLogin,
    object: nil,
    queue: .main  // receive on the main thread
) { notification in
    // 'notification.userInfo' contains the extra data
    if let userId = notification.userInfo?["userId"] as? String {
        print("User \(userId) logged in!")
    }
}

// IMPORTANT: Remove the observer when you're done:
NotificationCenter.default.removeObserver(observer)

// In SwiftUI, you can use the '.onReceive' modifier:
struct SomeView: View {
    var body: some View {
        Text("Waiting for login...")
            .onReceive(NotificationCenter.default.publisher(for: .userDidLogin)) { notification in
                print("User logged in!")
            }
    }
}
```

> **In plain English:** `NotificationCenter` is like a radio broadcast. One part of your app sends a message ("user logged in!"), and any part that's tuned in receives it. Nobody needs to know who's sending or receiving. It's useful for app-wide events, but don't overuse it — too many notifications make code hard to follow.

---

### Module 9 — Quick-Fire Answers

| Question | Answer |
|----------|--------|
| Core Data vs SwiftData? | SwiftData (iOS 17+) is simpler and modern. Core Data is older but still in most production apps. |
| UserDefaults for what? | Small preferences only (theme, flags, simple settings). Never for large data or secrets. |
| `NotificationCenter` vs delegates? | NotificationCenter is one-to-many broadcast. Delegates are one-to-one contracts. Use delegates when you know the receiver. |
| What is `NSManagedObjectContext`? | Core Data's "scratchpad" where you read/write data before saving to disk. Not thread-safe — use one per thread. |

---

## Module 10: Security, Privacy & Compliance

> **Priority: HIGH.** Critical for any app handling sensitive user data.

---

### 10.1 Keychain — Secure Storage

The **Keychain** is iOS's secure, encrypted storage for sensitive data like passwords, tokens, and API keys. It persists across app installs and is much more secure than UserDefaults.

```swift
import Security  // Apple's security framework

class KeychainManager {
    
    // Save a token securely:
    func save(token: String, forKey key: String) throws {
        // Convert the string to raw bytes (Data)
        let data = Data(token.utf8)
        
        // Build a "query" dictionary describing what to store.
        // Keychain uses dictionaries of keys/values for everything.
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,  // type of item
            kSecAttrAccount as String: key,                 // identifier/key
            kSecValueData as String: data                   // the actual secret
        ]
        
        // Delete any existing item with this key first (update = delete + add)
        SecItemDelete(query as CFDictionary)
        
        // Add the new item to the Keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        
        // 'errSecSuccess' means it worked
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed
        }
    }
    
    // Read a token:
    func read(forKey key: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,            // we want the data back
            kSecMatchLimit as String: kSecMatchLimitOne  // only one result
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            throw KeychainError.readFailed
        }
        return token
    }
}

enum KeychainError: Error {
    case saveFailed
    case readFailed
}

// Usage:
let keychain = KeychainManager()
try keychain.save(token: "abc123secret", forKey: "authToken")
let token = try keychain.read(forKey: "authToken")  // "abc123secret"
```

> **In plain English:** The Keychain is iOS's vault for secrets. It's encrypted, persists across app reinstalls, and is the ONLY correct place to store passwords, tokens, and API keys. `UserDefaults` is NOT secure — anyone with a jailbroken phone can read it. Always use Keychain for sensitive data.

---

### 10.2 App Transport Security (ATS)

ATS is iOS's built-in security feature that forces your app to use HTTPS (encrypted connections) by default. You shouldn't disable it.

```swift
// In your Info.plist (the app's configuration file):
// ATS is ON by default — you don't need to do anything for HTTPS.

// If you need to connect to an HTTP (non-secure) server during development:
// Add this to Info.plist (but NEVER ship this to production):
// NSAppTransportSecurity → NSAllowsArbitraryLoads → YES
```

---

### 10.3 Privacy Manifest (iOS 17+)

Starting in iOS 17, apps must declare what data they collect and what APIs they use:

```swift
// This goes in a PrivacyInfo.xcprivacy file (a special plist file).
// It's required for App Store submission.
// You must declare:
// - What data you collect (email, location, etc.)
// - Whether it's linked to the user's identity
// - Whether it's used for tracking
// - Which "required reason" APIs you use (like UserDefaults, file timestamps)
```

> **In plain English:** Apple takes privacy seriously. Your app must use HTTPS (ATS enforces this), store secrets in the Keychain (not UserDefaults), and declare what data you collect (Privacy Manifest). Violating these gets your app rejected from the App Store.

---

### Module 10 — Quick-Fire Answers

| Question | Answer |
|----------|--------|
| Where to store auth tokens? | Keychain — NEVER UserDefaults. UserDefaults is not encrypted. |
| What is ATS? | App Transport Security — forces HTTPS by default. Protects users from man-in-the-middle attacks. |
| What is the Privacy Manifest? | iOS 17+ requirement: a file declaring what data your app collects and which sensitive APIs it uses. Required for App Store. |

---

## Module 11: Accessibility

> **Priority: MEDIUM.** Required in any user-facing production app.

Accessibility ensures your app works for users with disabilities — visual impairments, motor difficulties, hearing loss, etc. iOS has VoiceOver (a screen reader), Dynamic Type (adjustable text size), and more.

---

### 11.1 SwiftUI Accessibility

SwiftUI has built-in accessibility modifiers:

```swift
struct ProductCard: View {
    let product: Product
    
    var body: some View {
        VStack {
            // 'Image(systemName:)' uses SF Symbols — Apple's built-in icon library
            Image(systemName: "star.fill")
            
            Text(product.name)
                .font(.headline)
            
            Text("$\(product.price, specifier: "%.2f")")
        }
        // '.accessibilityLabel' — what VoiceOver reads aloud.
        // Without this, VoiceOver might read each element separately.
        .accessibilityLabel("\(product.name), \(product.price) dollars")
        
        // '.accessibilityHint' — tells the user what will happen if they interact
        .accessibilityHint("Double tap to view product details")
        
        // '.accessibilityAddTraits' — tells VoiceOver what kind of element this is
        .accessibilityAddTraits(.isButton)
    }
}

// Dynamic Type — respecting the user's preferred text size:
Text("Hello")
    .font(.body)  // This automatically scales with the user's text size preference!
// System fonts (.body, .headline, .title, etc.) scale automatically.
// Custom fonts need explicit support.
```

---

### 11.2 UIKit Accessibility

```swift
// Set up accessibility on a UIKit element:
let submitButton = UIButton()
submitButton.setTitle("Submit", for: .normal)

// Tell VoiceOver this is an accessibility element
submitButton.isAccessibilityElement = true

// What VoiceOver reads:
submitButton.accessibilityLabel = "Submit form"

// What happens when you interact:
submitButton.accessibilityHint = "Double tap to submit your information"

// What kind of element it is:
submitButton.accessibilityTraits = .button
```

> **In plain English:** Accessibility means making your app usable by everyone. VoiceOver reads your UI aloud for blind users — you need to provide good labels so it makes sense. Dynamic Type lets users increase text size — your app should respect that. Apple reviews accessibility during App Store review, and many companies require it.

---

### Module 11 — Quick-Fire Answers

| Question | Answer |
|----------|--------|
| What is VoiceOver? | iOS's built-in screen reader. It reads the UI aloud and lets users navigate by touch. |
| `accessibilityLabel` vs `accessibilityHint`? | Label identifies the element ("Submit button"). Hint describes what happens ("Double tap to submit"). |
| Why Dynamic Type? | Respects the user's system font size preference. Some users need larger text to read comfortably. |

---

## Module 12: CI/CD & Release Pipeline

> **Priority: MEDIUM.** Shows ownership beyond code.

CI/CD automates building, testing, and deploying your app.

---

### 12.1 Fastlane

**Fastlane** is a popular tool for automating iOS build and release tasks:

```ruby
# This is Ruby code (Fastlane uses Ruby syntax).
# The file is called 'Fastfile' and lives in the 'fastlane/' directory.

default_platform :ios

# A "lane" is an automated workflow — like a script with a name.
lane :beta do
  # Increment the build number (1 → 2 → 3...)
  increment_build_number
  # Build the app
  build_app(workspace: "MyApp.xcworkspace", scheme: "MyApp")
  # Upload to TestFlight (Apple's beta testing platform)
  upload_to_testflight
end

lane :release do
  # Increment the version number (1.0 → 1.1)
  increment_version_number
  build_app(workspace: "MyApp.xcworkspace", scheme: "MyApp")
  # Upload to the App Store
  upload_to_app_store
end

# Run with: fastlane beta    or    fastlane release
```

---

### 12.2 GitHub Actions

```yaml
# This YAML file goes in .github/workflows/ios.yml
name: iOS Build & Test

# Run on every push and pull request:
on: [push, pull_request]

jobs:
  build:
    # Must run on macOS (iOS builds require Xcode)
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3  # check out the code
    
    - name: Select Xcode version
      run: sudo xcode-select -s /Applications/Xcode_15.0.app
    
    - name: Build
      run: >
        xcodebuild
        -workspace MyApp.xcworkspace
        -scheme MyApp
        -destination 'platform=iOS Simulator,name=iPhone 15'
        build
    
    - name: Run Tests
      run: >
        xcodebuild test
        -workspace MyApp.xcworkspace
        -scheme MyApp
        -destination 'platform=iOS Simulator,name=iPhone 15'
```

> **In plain English:** CI/CD automates the boring parts. Every time you push code, it automatically builds the app and runs tests. If tests fail, you know immediately. Fastlane automates uploading to TestFlight and the App Store. GitHub Actions runs the automation in the cloud. Senior engineers are expected to set this up, not just write features.

---

### Module 12 — Quick-Fire Answers

| Question | Answer |
|----------|--------|
| What is Fastlane? | An automation tool for building, testing, and deploying iOS apps. Written in Ruby. |
| Why CI/CD? | Catch bugs early, automate releases, ensure consistent build process across the team. |
| What is TestFlight? | Apple's platform for distributing beta builds to testers before App Store release. |

---

## Module 13: Behavioral & System Design

> **Priority: HIGH.** The round that actually gets you hired.

This module covers non-coding interview rounds — system design and behavioral questions.

---

### 13.1 System Design Questions

Interviewers give you a broad problem and want to see your thinking process:

**Example: "Design an Instagram-like feed"**

```
1. CLARIFY REQUIREMENTS (always start here!)
   - Features: photos, likes, comments, infinite scroll
   - Scale: how many users? how many posts per day?
   - Priorities: is loading speed more important than real-time updates?
   
2. HIGH-LEVEL ARCHITECTURE
   Client (iOS app)
     ↓
   API Gateway (routes requests)
     ↓
   Microservices (Feed Service, User Service, Media Service)
     ↓
   Databases (PostgreSQL for users, Redis for feed cache, S3 for images)
   
3. DATA MODEL
   - User: id, name, avatar_url
   - Post: id, user_id, image_url, caption, created_at
   - Like: id, user_id, post_id
   - Follow: follower_id, following_id
   
4. KEY DECISIONS & TRADE-OFFS
   Feed generation:
   - PUSH model: pre-compute feeds when someone posts (fast reads, slow writes)
   - PULL model: build feed on request from followed users (slower reads, simpler)
   - Hybrid: push for users with few followers, pull for celebrities
   
   Image loading:
   - CDN for fast global delivery
   - Multiple resolutions (thumbnail, medium, full)
   - Progressive loading (blur → sharp)
   
   Pagination:
   - Cursor-based (not offset-based) for stable infinite scroll
```

**iOS-specific system design:**

```
"Design an offline-capable note-taking app"

1. Local storage: SwiftData or Core Data with SQLite
2. Sync strategy: 
   - Last-write-wins (simple) vs operational transforms (complex)
   - Background sync with URLSession background tasks
3. Conflict resolution: timestamp-based merge or show conflict UI
4. Architecture: MVVM with Repository pattern
   - Repository checks local DB first, then syncs with server
5. Networking: Retry with exponential backoff
```

---

### 13.2 Behavioral Framework (STAR)

For behavioral questions ("Tell me about a time when..."), use the STAR framework:

- **S**ituation: Set the context (2 sentences)
- **T**ask: What was your specific responsibility (1 sentence)
- **A**ction: What YOU did — be specific (2-3 sentences)
- **R**esult: The outcome, with metrics if possible (1-2 sentences)

**Example:**

> **Question:** "Tell me about a time you dealt with a production issue."
>
> **S:** Our app had a 40% crash rate on iOS 15 launch day, affecting 200K daily active users.
> **T:** As the senior iOS engineer, I was responsible for identifying and fixing the crashes.
> **A:** I set up crash analytics with Firebase Crashlytics, identified the top 3 crashes (all related to a deprecated UIKit API), wrote regression tests for each, and coordinated a hotfix release with the QA team.
> **R:** Crash rate dropped from 40% to 0.5% within 48 hours. App Store rating recovered from 2.1 to 4.3 stars over the following week.

---

### 13.3 Common Behavioral Questions

| Question | What they're really asking |
|----------|---------------------------|
| "Tell me about a disagreement with a teammate" | Can you handle conflict professionally? |
| "Describe a project that failed" | Can you reflect honestly and learn from mistakes? |
| "How do you prioritize with tight deadlines?" | Can you make trade-off decisions? |
| "Tell me about mentoring a junior engineer" | Are you ready for a senior/lead role? |

---

### 13.4 Questions to Ask Interviewers

Always have 2-3 questions ready. Good ones show you think like a senior engineer:

- "What does your iOS team structure look like? How many engineers, and how are features divided?"
- "How do you handle technical debt? Is there dedicated time for it?"
- "What's your release cadence? Weekly? Biweekly?"
- "How do you measure app quality? Crash rates? User metrics?"
- "What's the biggest technical challenge the team is facing right now?"

> **In plain English:** System design questions test whether you can think about the big picture — not just write code, but design a whole system. Behavioral questions test whether you're a good teammate and can handle real-world situations. For both: explain your reasoning out loud. Interviewers care more about HOW you think than the specific answer.

---

### Module 13 — Quick-Fire Answers

| Question | Answer |
|----------|--------|
| What is STAR? | Situation, Task, Action, Result — a framework for answering behavioral questions with specific examples. |
| Push vs pull for feed generation? | Push: pre-compute feeds (fast reads). Pull: build on request (simpler). Most systems use a hybrid. |
| Why cursor-based pagination? | Offset-based breaks when items are added/removed. Cursors point to a specific item, so the page stays stable. |

---

## Practice

See the [`practice/`](practice) folder for hands-on exercises:

- **challenges/** — Find the bugs in existing code
- **build/** — Implement features from scratch
- **drills/** — Focused exercises on specific concepts

---

## Additional Resources

| Resource | What it covers |
|----------|---------------|
| [Apple Swift Documentation](https://docs.swift.org) | Official language reference |
| [WWDC Videos](https://developer.apple.com/wwdc) | Latest iOS features and best practices |
| [Hacking with Swift](https://www.hackingwithswift.com) | Free Swift/SwiftUI tutorials for beginners |
| [Swift By Sundell](https://www.swiftbysundell.com) | Deep dives on Swift topics |
| [iOS Dev Weekly](https://iosdevweekly.com) | Weekly iOS development news |

---

## License

MIT — Feel free to use for interview preparation.
