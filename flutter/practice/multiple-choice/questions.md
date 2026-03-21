# Multiple Choice Questions (50 questions)

## Questions 1-10: Dart Fundamentals

### Question 1
What is the output of the following code?

```dart
void main() {
  List<int> numbers = [1, 2, 3];
  numbers.add(4);
  print(numbers.length);
}
```

A) 3
B) 4
C) Error - cannot modify list
D) null

<details>
<summary>Answer</summary>
**B) 4** - The add() method adds an element to the list, increasing its length from 3 to 4.
</details>

---

### Question 2
Which keyword is used to declare a constant variable in Dart?

A) `let`
B) `var`
C) `const` or `final`
D) `static`

<details>
<summary>Answer</summary>
**C) `const` or `final`** - `final` is for runtime constants, `const` for compile-time constants.
</details>

---

### Question 3
What is the difference between `final` and `const`?

A) No difference
B) `final` is compile-time, `const` is runtime
C) `final` is runtime, `const` is compile-time
D) `const` can be reassigned

<details>
<summary>Answer</summary>
**C) `final` is runtime, `const` is compile-time** - `final` values are set once at runtime, `const` values must be known at compile-time.
</details>

---

### Question 4
What does the `??` operator do?

A) Null check
B) Null coalescing - returns left operand if not null, otherwise right operand
C) Type cast
D) Logical OR

<details>
<summary>Answer</summary>
**B) Null coalescing** - `a ?? b` returns `a` if `a` is not null, otherwise returns `b`.
</details>

---

### Question 5
What is the output?

```dart
void main() {
  String? name;
  print(name?.length ?? 0);
}
```

A) Error
B) null
C) 0
D) undefined

<details>
<summary>Answer</summary>
**C) 0** - The `?.` returns null when name is null, then `?? 0` provides the default value.
</details>

---

### Question 6
Which collection type maintains insertion order?

A) Set
B) Map
C) List
D) All of the above

<details>
<summary>Answer</summary>
**C) List** - Lists maintain insertion order. In Dart, Maps also maintain insertion order, but Sets do not guarantee it.
</details>

---

### Question 7
What is a mixin?

A) A type of list
B) A way to reuse code in multiple class hierarchies
C) A design pattern
D) A type of constructor

<details>
<summary>Answer</summary>
**B) A way to reuse code in multiple class hierarchies** - Mixins allow code reuse without inheritance.
</details>

---

### Question 8
What does `async` keyword indicate?

A) The function runs in parallel
B) The function returns a Future
C) The function is synchronous
D) The function cannot throw errors

<details>
<summary>Answer</summary>
**B) The function returns a Future** - An `async` function always returns a Future, even if you return a plain value.
</details>

---

### Question 9
What is the purpose of `await`?

A) To pause execution for a specified time
B) To wait for a Future to complete and get its result
C) To create a new thread
D) To stop async execution

<details>
<summary>Answer</summary>
**B) To wait for a Future to complete and get its result** - `await` suspends execution until the Future completes.
</details>

---

### Question 10
What is a Stream in Dart?

A) A synchronous collection
B) A sequence of asynchronous events
C) A type of Future
D) A constant list

<details>
<summary>Answer</summary>
**B) A sequence of asynchronous events** - Streams provide a way to receive a sequence of events over time.
</details>

---

## Questions 11-20: Flutter Widgets

### Question 11
What is the base class of all widgets in Flutter?

A) Component
B) Element
C) Widget
D) StatelessWidget

<details>
<summary>Answer</summary>
**C) Widget** - All widgets extend the Widget class.
</details>

---

### Question 12
What is the difference between StatelessWidget and StatefulWidget?

A) No difference
B) StatefulWidget can rebuild when state changes
C) StatelessWidget is faster
D) StatefulWidget is deprecated

<details>
<summary>Answer</summary>
**B) StatefulWidget can rebuild when state changes** - StatefulWidgets maintain mutable state that can change over time.
</details>

---

### Question 13
When is `initState()` called?

A) Every time the widget rebuilds
B) When the widget is first created
C) When the widget is disposed
D) When the app starts

<details>
<summary>Answer</summary>
**B) When the widget is first created** - `initState()` is called once when the State object is created.
</details>

---

### Question 14
What method must be overridden in a StatelessWidget?

A) `render()`
B) `update()`
C) `build()`
D) `create()`

<details>
<summary>Answer</summary>
**C) `build()`** - All widgets must implement the `build()` method.
</details>

---

### Question 15
What is the purpose of `keys` in Flutter lists?

A) To sort the list
B) To help Flutter identify which items have changed
C) To make the list mutable
D) To add colors to items

<details>
<summary>Answer</summary>
**B) To help Flutter identify which items have changed** - Keys preserve state when widgets move in the tree.
</details>

---

### Question 16
Which widget is used for scrolling content?

A) Container
B) ListView
C) Row
D) Stack

<details>
<summary>Answer</summary>
**B) ListView** - ListView provides a scrollable list of widgets.
</details>

---

### Question 17
What does `setState()` do?

A) Creates a new widget
B) Schedules a rebuild of the widget
C) Disposes the widget
D) Changes the app theme

<details>
<summary>Answer</summary>
**B) Schedules a rebuild of the widget** - `setState()` notifies Flutter that the internal state has changed.
</details>

---

### Question 18
What is a GlobalKey?

A) A key for the entire app
B) A key that uniquely identifies a widget across the entire widget tree
C) A key for global variables
D) A deprecated feature

<details>
<summary>Answer</summary>
**B) A key that uniquely identifies a widget across the entire widget tree** - GlobalKeys maintain state when widgets move.
</details>

---

### Question 19
Which widget is best for displaying a large scrollable list efficiently?

A) Column
B) ListView
C) ListView.builder
D) SingleChildScrollView

<details>
<summary>Answer</summary>
**C) ListView.builder** - It lazily loads items as they become visible.
</details>

---

### Question 20
What is the purpose of `SafeArea` widget?

A) To add padding to buttons
B) To avoid system intrusions like notches and status bars
C) To make content secure
D) To add borders

<details>
<summary>Answer</summary>
**B) To avoid system intrusions** - SafeArea adds padding to avoid notches, status bars, etc.
</details>

---

## Questions 21-30: State Management

### Question 21
What is the simplest form of state management in Flutter?

A) Riverpod
B) Bloc
C) setState
D) Provider

<details>
<summary>Answer</summary>
**C) setState** - setState is built into StatefulWidget.
</details>

---

### Question 22
What pattern does Bloc use?

A) MVC
B) BLoC (Business Logic Component)
C) Singleton
D) Factory

<details>
<summary>Answer</summary>
**B) BLoC (Business Logic Component)** - Uses streams to separate business logic from UI.
</details>

---

### Question 23
What is Provider?

A) A database
B) A state management solution using InheritedWidget
C) A navigation library
D) A testing framework

<details>
<summary>Answer</summary>
**B) A state management solution using InheritedWidget** - Provider simplifies dependency injection.
</details>

---

### Question 24
In Riverpod, what is a Provider?

A) A widget
B) A class that creates and exposes dependencies
C) A type of stream
D) A navigation route

<details>
<summary>Answer</summary>
**B) A class that creates and exposes dependencies** - Providers manage object creation and lifecycle.
</details>

---

### Question 25
What is the main advantage of Riverpod over Provider?

A) Faster performance
B) Compile-time safety and no context dependency
C) Better UI
D) More widgets

<details>
<summary>Answer</summary>
**B) Compile-time safety and no context dependency** - Riverpod solves Provider's limitations.
</details>

---

### Question 26
What does `ValueNotifier` do?

A) Notifies listeners when value changes
B) Creates a new thread
C) Manages navigation
D) Handles HTTP requests

<details>
<summary>Answer</summary>
**A) Notifies listeners when value changes** - ValueNotifier is a simple observable value.
</details>

---

### Question 27
What is `InheritedWidget`?

A) A base widget class
B) A widget that efficiently propagates information down the tree
C) A deprecated widget
D) A state management package

<details>
<summary>Answer</summary>
**B) A widget that efficiently propagates information down the tree** - Foundation for Provider.
</details>

---

### Question 28
What is the purpose of `StreamBuilder`?

A) To build static widgets
B) To rebuild widgets when stream data changes
C) To create streams
D) To navigate between screens

<details>
<summary>Answer</summary>
**B) To rebuild widgets when stream data changes** - StreamBuilder listens to streams.
</details>

---

### Question 29
What is `FutureBuilder` used for?

A) Building widgets from Future results
B) Creating Futures
C) Handling errors
D) Navigation

<details>
<summary>Answer</summary>
**A) Building widgets from Future results** - FutureBuilder builds UI based on Future state.
</details>

---

### Question 30
What is "lifting state up"?

A) Moving state to a parent widget
B) Using global variables
C) Using a database
D) Moving state to child widgets

<details>
<summary>Answer</summary>
**A) Moving state to a parent widget** - Sharing state between siblings by moving it to common ancestor.
</details>

---

## Questions 31-40: Async & Navigation

### Question 31
What does `Future.then()` do?

A) Creates a delay
B) Registers a callback for when the Future completes
C) Cancels the Future
D) Creates a new thread

<details>
<summary>Answer</summary>
**B) Registers a callback for when the Future completes** - Alternative to await.
</details>

---

### Question 32
What is `async*`?

A) An async function that returns a Stream
B) A synchronous function
C) An error type
D) A deprecated feature

<details>
<summary>Answer</summary>
**A) An async function that returns a Stream** - Uses `yield` to emit values.
</details>

---

### Question 33
What does `StreamController` do?

A) Controls stream subscription
B) Creates a stream that you can add values to
C) Stops streams
D) Converts streams to Futures

<details>
<summary>Answer</summary>
**B) Creates a stream that you can add values to** - Sink for adding data, stream for listening.
</details>

---

### Question 34
What is `Navigator.push()`?

A) Navigate back
B) Navigate to a new screen
C) Replace current screen
D) Open a dialog

<details>
<summary>Answer</summary>
**B) Navigate to a new screen** - Pushes a route onto the navigation stack.
</details>

---

### Question 35
How do you navigate back in Flutter?

A) Navigator.back()
B) Navigator.pop()
C) Navigator.return()
D) Navigator.goBack()

<details>
<summary>Answer</summary>
**B) Navigator.pop()** - Pops the current route off the stack.
</details>

---

### Question 36
What is GoRouter?

A) A navigation package
B) A routing solution built on top of Navigator 2.0
C) A web router
D) A deprecated library

<details>
<summary>Answer</summary>
**B) A routing solution built on top of Navigator 2.0** - Declarative routing.
</details>

---

### Question 37
What is deep linking?

A) Linking to databases
B) Navigating to specific screens via URLs
C) Creating hyperlinks
D) Network requests

<details>
<summary>Answer</summary>
**B) Navigating to specific screens via URLs** - Direct navigation to app content.
</details>

---

### Question 38
What is a Route in Flutter?

A) A network path
B) A screen or page
C) An abstraction for a "screen" in navigation
D) A database query

<details>
<summary>Answer</summary>
**C) An abstraction for a "screen" in navigation** - Represents a destination.
</details>

---

### Question 39
What does `Navigator.pushReplacement()` do?

A) Adds a new route
B) Replaces the current route with a new one
C) Removes all routes
D) Goes back

<details>
<summary>Answer</summary>
**B) Replaces the current route with a new one** - Useful for login screens.
</details>

---

### Question 40
How do you pass data back when popping?

A) Navigator.pop(context, data)
B) Navigator.return(data)
C) Navigator.send(data)
D) Cannot pass data back

<details>
<summary>Answer</summary>
**A) Navigator.pop(context, data)** - Second parameter is the return value.
</details>

---

## Questions 41-50: Advanced Topics

### Question 41
What is an Isolate?

A) A widget
B) A separate thread of execution with its own memory
C) A type of stream
D) A database

<details>
<summary>Answer</summary>
**B) A separate thread of execution with its own memory** - Dart's approach to concurrency.
</details>

---

### Question 42
How do isolates communicate?

A) Shared memory
B) Message passing via SendPort/ReceivePort
C) Global variables
D) Direct method calls

<details>
<summary>Answer</summary>
**B) Message passing via SendPort/ReceivePort** - No shared memory.
</details>

---

### Question 43
What is `compute()` in Flutter?

A) A math function
B) A helper to spawn isolates for CPU-intensive tasks
C) A widget
D) A network function

<details>
<summary>Answer</summary>
**B) A helper to spawn isolates** - Simplifies running code in background.
</details>

---

### Question 44
What is a Platform Channel?

A) A YouTube channel
B) A way to communicate with native code
C) A streaming service
D) A debug tool

<details>
<summary>Answer</summary>
**B) A way to communicate with native code** - MethodChannel, EventChannel, etc.
</details>

---

### Question 45
What is the purpose of `CustomPainter`?

A) Custom widgets
B) Low-level custom drawing on canvas
C) State management
D) Navigation

<details>
<summary>Answer</summary>
**B) Low-level custom drawing on canvas** - Direct canvas access.
</details>

---

### Question 46
What is `RepaintBoundary`?

A) A widget that creates a separate rendering layer
B) A border widget
C) A painting tool
D) Deprecated

<details>
<summary>Answer</summary>
**A) A widget that creates a separate rendering layer** - Performance optimization.
</details>

---

### Question 47
What is tree shaking?

A) Removing unused code during compilation
B) A debugging technique
C) A state management pattern
D) An animation type

<details>
<summary>Answer</summary>
**A) Removing unused code during compilation** - Reduces app size.
</details>

---

### Question 48
What does `const` constructor enable?

A) Faster runtime
B) Widget can be created as compile-time constant
C) Mutable state
D) Network calls

<details>
<summary>Answer</summary>
**B) Widget can be created as compile-time constant** - Enables widget reuse.
</details>

---

### Question 49
What is hot reload?

A) Restarting the app
B) Injecting updated code without losing state
C) Full app rebuild
D) Network refresh

<details>
<summary>Answer</summary>
**B) Injecting updated code without losing state** - Fast development iteration.
</details>

---

### Question 50
What is the widget tree?

A) A data structure
B) The hierarchical arrangement of widgets
C) A navigation concept
D) A state management pattern

<details>
<summary>Answer</summary>
**B) The hierarchical arrangement of widgets** - Foundation of Flutter UI.
</details>

---
