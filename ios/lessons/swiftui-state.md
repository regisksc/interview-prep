# SwiftUI State Management: A Beginner-Friendly Guide

Before we dive in, let's cover the Swift basics you need to make sense of this page. If you already know Swift, skip to [Contents](#contents).

---

## Swift Crash Course (Read This First)

### struct vs class

Swift has two main ways to define a "thing": `struct` and `class`.

- A **struct** is a **value type**. When you pass it around, Swift makes a **copy**. Think of it like **photocopying a document** — the original and the copy are independent. Changing one doesn't affect the other.
- A **class** is a **reference type**. When you pass it around, everyone shares the **same object**. Think of it like **sharing a Google Doc link** — everyone edits the same document.

```swift
struct Point { var x: Int }   // Value type — gets copied
class  Score { var value: Int = 0 } // Reference type — shared
```

SwiftUI views are **structs**. This matters a lot (see [@State](#state--a-reactive-variable-this-view-owns) below).

### protocol

A **protocol** is like an **interface** in Java, Kotlin, or TypeScript. It's a **contract** — a list of properties and methods a type promises to provide.

```swift
// "Anything that conforms to Greetable MUST have a greet() method."
protocol Greetable {
    func greet() -> String
}

// This struct fulfills the contract.
struct Person: Greetable {
    func greet() -> String { "Hi!" }
}
```

When you see `struct CounterView: View`, it means "CounterView is a struct that follows the `View` contract." The `View` protocol requires one thing: a `body` property.

### Property wrappers (the `@` annotations)

In Swift, the `@Something` annotations in front of a variable are **property wrappers**. They change how a variable **stores or behaves** — similar to **decorators** in Python or annotations in Java/Kotlin.

```swift
@State private var count = 0
//  ^---- this @ annotation tells SwiftUI:
//        "watch this variable and re-render the view when it changes"
```

Every section in this guide explains a different `@` wrapper and when to use it.

### What `some View` means

When you see `some View`, it just means **"returns some kind of View — Swift figures out the exact type."** You don't need to spell out the specific type. The compiler handles it.

### What `var body: some View { ... }` is

`body` is a **computed property** — it's not a stored value but a block of code that **runs every time SwiftUI needs the current look of your view**. Think of it as the `render()` method in React.

```swift
var body: some View {
    Text("Hello")   // This is what the view currently looks like
}
```

### What `#Preview` is

`#Preview` is a macro that creates a **live preview** of your view inside Xcode. You don't have to build and run the whole app just to see your UI:

```swift
#Preview {
    CounterView()   // Shows CounterView in the Xcode canvas
}
```

On older Xcode versions (< 15), you may see `PreviewProvider` instead. Same idea, more boilerplate.

---

## Contents

| Section | What You'll Learn | Practice |
|---------|-------------------|----------|
| [Decision Tree](#quick-decision-tree) | "Which wrapper do I use?" — the flowchart | Start here |
| [@State](#state--a-reactive-variable-this-view-owns) | Local state a single view owns | [Mood Tracker step 1](../practice/apps/01-mood-tracker/steps/step-1-local-state.md) |
| [@Binding](#binding--a-remote-control-for-someone-elses-state) | Let a child modify a parent's state | [Mood Tracker step 2](../practice/apps/01-mood-tracker/steps/step-2-extract-binding.md) |
| [@StateObject](#stateobject--a-viewmodel-this-view-owns) | ViewModel you create and own | [Mood Tracker step 3](../practice/apps/01-mood-tracker/steps/step-3-viewmodel.md) |
| [@ObservedObject](#observedobject--a-viewmodel-someone-else-owns) | ViewModel someone else created | [Mood Tracker step 3](../practice/apps/01-mood-tracker/steps/step-3-viewmodel.md) (child views) |
| [@EnvironmentObject](#environmentobject--the-wifi-router) | Shared state across entire app | [Mood Tracker step 5](../practice/apps/01-mood-tracker/steps/step-5-environment.md) |
| [@Environment](#environment--reading-system-settings) | System values (dark mode, locale) | [Mood Tracker step 5](../practice/apps/01-mood-tracker/steps/step-5-environment.md) |
| [@AppStorage](#appstorage--the-fridge-whiteboard) | Simple values that survive app restart | [Mood Tracker step 4](../practice/apps/01-mood-tracker/steps/step-4-persistence.md) |
| [@SceneStorage](#scenestorage--remembering-where-the-user-left-off) | Per-window UI state restoration | [Mood Tracker step 7](../practice/apps/01-mood-tracker/steps/step-7-adapt-restore.md) |
| [Comparison Table](#comparison-table) | Side-by-side cheat sheet | — |
| [State Flow Diagram](#state-flow-diagram) | Visual mental model | — |
| [Real-World Example](#real-world-example-complete-feature) | Full feature using all wrappers | — |
| [Testing Tips](#testing-tips) | How to test state in SwiftUI | — |
| [Performance](#performance-considerations) | Avoid unnecessary re-renders | — |

---

## Quick Decision Tree

```
Is the state local to ONE view and a simple value (Int, Bool, String)?
  → @State                (a reactive variable this view owns)

Does a child view need to MODIFY a parent's state?
  → @Binding              (a remote control for someone else's variable)

Is the state a class (ViewModel) that THIS view CREATES?
  → @StateObject          (you bought the TV and plugged it in — you own it)

Is the state a class (ViewModel) that someone ELSE created and passed in?
  → @ObservedObject       (you're watching someone else's TV)

Do MANY views across the app need the same shared data?
  → @EnvironmentObject    (the WiFi router — every device in the house uses it)

Do you want a simple value (Bool, String, Int) to survive app restart?
  → @AppStorage           (writing on the fridge whiteboard — survives a power outage)

Do you need to READ a system setting (dark mode, font size, locale)?
  → @Environment          (checking the thermostat — you can read it but not control it)
```

---

## @State — A Reactive Variable This View Owns

> **What is `@State`?** In SwiftUI, views are structs. Normally a struct can't change its own properties after creation — that's just how Swift works. `@State` is a special annotation that says "this property CAN change, and when it does, redraw the screen." Think of it like marking a variable as "reactive" — when its value changes, the UI updates automatically.
>
> **Analogy:** A light switch on a wall. The wall (your view) owns the switch. Flipping it (changing the value) changes what you see (the UI re-renders).

### Example A — Simplest possible case

```swift
// 'struct' = a value type (gets copied when passed around, like a photocopy).
// ': View' = this struct conforms to the View protocol ("I can be displayed on screen").
struct CounterView: View {
    // '@State' = "watch this variable. When it changes, redraw the view."
    // 'private' = only this view can modify it directly.
    @State private var count = 0

    // 'body' is a computed property. Runs every time @State changes.
    // 'some View' = "returns some kind of view, Swift figures out the type."
    var body: some View {
        // Button = a tappable element. The string is the label.
        // The { } closure is the action that runs when tapped.
        Button("Count is \(count)") {
            count += 1   // This changes @State, which re-runs body
        }
    }
}

#Preview {
    CounterView()   // Live preview in Xcode
}
```

### Example B — Real-world: a toggle and an alert

```swift
struct SettingsRow: View {
    // Two separate @State variables, both local to this view.
    @State private var notificationsOn = true
    @State private var showingConfirmation = false

    var body: some View {
        // VStack = arranges child views vertically (top to bottom).
        VStack(alignment: .leading, spacing: 12) {
            // Toggle = a switch (like a UISwitch). 'isOn:' expects a Binding.
            // '$notificationsOn' creates a Binding from the @State variable.
            Toggle("Enable notifications", isOn: $notificationsOn)

            Button("Reset settings") {
                showingConfirmation = true   // Shows the alert below
            }
            // .alert = a popup dialog. 'isPresented:' takes a Binding<Bool>.
            .alert("Are you sure?", isPresented: $showingConfirmation) {
                Button("Reset", role: .destructive) {
                    notificationsOn = true   // Reset to default
                }
                Button("Cancel", role: .cancel) { }
            }
        }
        .padding()
    }
}
```

### Key points

- Only use `@State` inside a `struct` that conforms to `View`.
- It's for **value types** — Int, String, Bool, or your own structs.
- SwiftUI manages the storage behind the scenes. You don't allocate memory yourself.
- When the value changes, SwiftUI automatically re-runs `body` and updates the UI.
- **Never share** `@State` between views. If a child needs to modify it, use `@Binding`.

### Common mistakes

```swift
// ❌ WRONG: Using @State in a class — it only works in struct views.
class MyViewModel {
    @State var count = 0   // This does nothing useful!
}

// ❌ WRONG: Passing @State directly — the child gets a COPY, not the live value.
struct ParentView: View {
    @State private var count = 0

    var body: some View {
        // 'count' here is just an Int copy. The child can't change the parent's state.
        ChildView(count: count)
    }
}

// ✅ CORRECT: Pass a Binding with '$' so the child can modify the parent's state.
struct ParentView: View {
    @State private var count = 0

    var body: some View {
        // '$count' creates a two-way connection to the @State.
        ChildView(count: $count)
    }
}
```

---

## @Binding — A Remote Control for Someone Else's State

> **What is `@Binding`?** A `@Binding` is a **two-way connection** to a piece of state that lives somewhere else (usually a parent view's `@State`). The child view can **read and write** the value, but it doesn't **own** the value.
>
> **Analogy:** A remote control for someone else's light switch. You didn't install the switch (the parent owns the `@State`), but you can flip it on and off from the couch (the child modifies it through the `@Binding`).

### Example A — Simplest possible case

```swift
struct ParentView: View {
    // The parent OWNS the state.
    @State private var isOn = false

    var body: some View {
        // '$isOn' creates a Binding and passes it to the child.
        ToggleChild(isOn: $isOn)
    }
}

struct ToggleChild: View {
    // '@Binding' = "I can read and write this, but I don't own it."
    @Binding var isOn: Bool

    var body: some View {
        Toggle("Switch", isOn: $isOn)   // Changes flow back to the parent
    }
}
```

### Example B — Real-world: a form with text fields

```swift
// A reusable text-field row. It doesn't own the text — the parent does.
struct LabeledField: View {
    let label: String
    // This view can read AND edit the text, but the parent owns the actual value.
    @Binding var text: String

    var body: some View {
        // HStack = arranges child views horizontally (left to right).
        HStack {
            Text(label)
                .frame(width: 80, alignment: .leading)
            // TextField = a text input. 'text:' expects a Binding<String>.
            TextField("Enter \(label.lowercased())", text: $text)
                .textFieldStyle(.roundedBorder)
        }
    }
}

struct SignUpForm: View {
    // The form OWNS both pieces of state.
    @State private var name = ""
    @State private var email = ""

    var body: some View {
        VStack(spacing: 16) {
            LabeledField(label: "Name", text: $name)
            LabeledField(label: "Email", text: $email)

            // The parent can still read the latest values.
            Button("Submit") {
                print("Signing up \(name) with \(email)")
            }
            .disabled(name.isEmpty || email.isEmpty)
        }
        .padding()
    }
}
```

### The `$` dollar sign

The `$` prefix turns a `@State` (or any property wrapper) into a `Binding`. You'll see it everywhere:

| You write | You get | Why |
|-----------|---------|-----|
| `count` | The plain `Int` value | For reading |
| `$count` | A `Binding<Int>` | For two-way connection (reading + writing) |

You can also bind to a **property inside a struct**:

```swift
struct User {
    var name: String
    var email: String
}

struct ProfileForm: View {
    @State private var user = User(name: "", email: "")

    var body: some View {
        VStack {
            // '$user.name' binds to the 'name' field inside the User struct.
            TextField("Name", text: $user.name)
            TextField("Email", text: $user.email)
        }
    }
}
```

---

## @StateObject — A ViewModel This View Owns

> **What is `@StateObject`?** When your state gets too complex for a simple `@State` variable (you need network calls, multiple related properties, business logic), you move it into a **class** called a ViewModel. `@StateObject` tells SwiftUI: "I'm **creating** this ViewModel here, and I **own** it. Keep it alive as long as this view exists."
>
> **Analogy:** You bought a TV and plugged it in. You **own** it. Even if SwiftUI repaints the room (re-renders the view), the TV stays — it doesn't get unplugged and replaced every time.

Before we look at examples, we need two building blocks:

1. **`ObservableObject`** — a protocol for classes. It says: "I have properties that views should watch."
2. **`@Published`** — a property wrapper inside that class. It says: "when this specific property changes, notify all watching views."

### Example A — Simplest possible case

```swift
// 'class' = a reference type (shared, not copied). Required for ObservableObject.
// ': ObservableObject' = "views can watch me for changes."
class CounterModel: ObservableObject {
    // '@Published' = "when 'count' changes, tell all watching views to re-render."
    @Published var count = 0
}

struct CounterView: View {
    // '@StateObject' = "I CREATE this object and OWN it."
    @StateObject private var model = CounterModel()

    var body: some View {
        Button("Count: \(model.count)") {
            model.count += 1
        }
    }
}
```

### Example B — Real-world: a profile editor with async save

```swift
// The ViewModel — holds data and business logic.
// '@MainActor' = "run everything on the main thread" (required for UI updates).
@MainActor
class ProfileViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    // 'async' = this function can pause and wait (e.g., for a network call).
    func save() async {
        isLoading = true
        errorMessage = nil

        // Simulate a network delay.
        try? await Task.sleep(for: .seconds(1))

        if name.isEmpty {
            errorMessage = "Name can't be empty"
        }

        isLoading = false
    }
}

struct ProfileView: View {
    // This view CREATES and OWNS the ViewModel.
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        // Form = a grouped list of controls, like a settings page.
        Form {
            // Section = a visual group with an optional header.
            Section("Your Info") {
                TextField("Name", text: $viewModel.name)
                TextField("Email", text: $viewModel.email)
            }

            if let error = viewModel.errorMessage {
                // .foregroundStyle = sets the text color.
                Text(error).foregroundStyle(.red)
            }

            Button("Save") {
                // 'Task { }' = run async code from a synchronous context.
                Task { await viewModel.save() }
            }
            // .disabled = grays out the button when true.
            .disabled(viewModel.isLoading)
        }
    }
}
```

### Key points

- Use `@StateObject` when the **current view creates** the object (typically a ViewModel).
- SwiftUI creates the object **once** and keeps it alive as long as the view exists.
- Even if `body` re-runs 100 times, the `@StateObject` is **not** re-created.
- If someone else created the object and passes it to you, use `@ObservedObject` instead.

### Common mistake: using @ObservedObject when you mean @StateObject

```swift
// ❌ WRONG: @ObservedObject with inline creation.
// The ViewModel gets DESTROYED and RECREATED every time the parent re-renders.
struct ProfileView: View {
    @ObservedObject var viewModel = ProfileViewModel()
    var body: some View { /* ... */ }
}

// ✅ CORRECT: @StateObject preserves the ViewModel across re-renders.
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    var body: some View { /* ... */ }
}
```

---

## @ObservedObject — A ViewModel Someone Else Owns

> **What is `@ObservedObject`?** It's like `@StateObject`, but you **don't create the object** — someone else (a parent view) created it and passed it to you. You can read it, react to its changes, and even modify its properties, but you don't control its lifetime.
>
> **Analogy:** You're watching someone else's TV. If they unplug it (the parent view disappears), you lose the picture. You didn't buy the TV — you're just watching what's on.

### Example A — Simplest possible case

```swift
class TimerModel: ObservableObject {
    @Published var seconds = 0
}

struct TimerDisplay: View {
    // '@ObservedObject' = "I'm BORROWING this. Someone else created it."
    @ObservedObject var timer: TimerModel

    var body: some View {
        Text("\(timer.seconds) seconds")
    }
}

// The parent creates and owns the model, then passes it.
struct ParentView: View {
    @StateObject private var timer = TimerModel()

    var body: some View {
        TimerDisplay(timer: timer)
    }
}
```

### Example B — Real-world: parent and child sharing a ViewModel

```swift
@MainActor
class ShoppingCart: ObservableObject {
    @Published var items: [String] = []

    func add(_ item: String) {
        items.append(item)
    }

    var totalItems: Int { items.count }
}

// The parent OWNS the cart.
struct ShopView: View {
    @StateObject private var cart = ShoppingCart()

    var body: some View {
        // NavigationStack = a navigation container (think UINavigationController).
        NavigationStack {
            VStack {
                Text("Items in cart: \(cart.totalItems)")

                // Pass the cart to the child. The child BORROWS it.
                CartItemList(cart: cart)

                Button("Add Apple") {
                    cart.add("Apple")
                }
            }
            .navigationTitle("Shop")
        }
    }
}

// The child BORROWS the cart.
struct CartItemList: View {
    @ObservedObject var cart: ShoppingCart

    var body: some View {
        // List = a scrollable list of rows.
        // 'id: \.self' = use each string as its own identifier.
        List(cart.items, id: \.self) { item in
            Text(item)
        }
    }
}
```

### When to use which?

| Scenario | Use this |
|----------|----------|
| This view **creates** the ViewModel | `@StateObject` |
| This view **receives** the ViewModel from a parent | `@ObservedObject` |
| The ViewModel is injected from the top of the app | `@EnvironmentObject` |

---

## @EnvironmentObject — The WiFi Router

> **What is `@EnvironmentObject`?** It's a way to share an `ObservableObject` across your **entire view hierarchy** without passing it manually from parent to child to grandchild. You inject it once at the top, and any descendant view can grab it.
>
> **Analogy:** The WiFi router in your house. You set it up once (inject at the top). Every device in every room (every view in the hierarchy) can connect to it without running wires between them.

### Example A — Simplest possible case

```swift
class UserSettings: ObservableObject {
    @Published var isDarkMode = false
}

// The app entry point injects the shared object.
@main
struct MyApp: App {
    // The app OWNS the settings.
    @StateObject private var settings = UserSettings()

    var body: some Scene {
        // WindowGroup = the main window of the app.
        WindowGroup {
            ContentView()
                // '.environmentObject()' = inject into the entire view tree below.
                .environmentObject(settings)
        }
    }
}

// ANY view in the tree can access it — no need to pass it manually.
struct ContentView: View {
    // '@EnvironmentObject' = "grab the UserSettings from the environment."
    @EnvironmentObject var settings: UserSettings

    var body: some View {
        Toggle("Dark Mode", isOn: $settings.isDarkMode)
    }
}
```

### Example B — Real-world: app-wide auth state

```swift
@MainActor
class AuthState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var username = ""

    func logIn(as user: String) {
        username = user
        isLoggedIn = true
    }

    func logOut() {
        username = ""
        isLoggedIn = false
    }
}

@main
struct SocialApp: App {
    @StateObject private var auth = AuthState()

    var body: some Scene {
        WindowGroup {
            // If logged in, show main content. Otherwise, show login.
            if auth.isLoggedIn {
                HomeView()
                    .environmentObject(auth)
            } else {
                LoginView()
                    .environmentObject(auth)
            }
        }
    }
}

struct LoginView: View {
    @EnvironmentObject var auth: AuthState
    @State private var name = ""

    var body: some View {
        VStack(spacing: 20) {
            TextField("Username", text: $name)
                .textFieldStyle(.roundedBorder)
            Button("Log In") {
                auth.logIn(as: name)
            }
            .disabled(name.isEmpty)
        }
        .padding()
    }
}

// This view is DEEPLY nested, but it can still access auth directly.
struct ProfileBadge: View {
    @EnvironmentObject var auth: AuthState

    var body: some View {
        Text("Hello, \(auth.username)")
    }
}
```

### Key points

- Inject with `.environmentObject(myObject)` at or near the top of the tree.
- Access with `@EnvironmentObject var myObject: MyType` anywhere below.
- **If you forget to inject it, the app will crash at runtime** with: `"No ObservableObject of type X found."` This is the #1 bug with `@EnvironmentObject`.
- Best for truly **app-wide** state: auth, theme, user settings, shopping cart.

### When @EnvironmentObject vs. passing @ObservedObject?

| @EnvironmentObject | @ObservedObject |
|-------------------|-----------------|
| App-wide state (auth, theme) | Feature-specific state |
| Deeply nested views need it | Only the direct child needs it |
| Avoid "prop drilling" | Keep dependencies explicit |

---

## @Environment — Reading System Settings

> **What is `@Environment`?** It gives you **read access to system-level values** that SwiftUI manages — things like whether the user is in dark mode, the current locale, the font size preference, or a dismiss action. You don't create these values; the system provides them.
>
> **Analogy:** Checking the thermostat on the wall. You can **read** the temperature (dark mode? large text?), but you can't set it from your view. The system (or the user's settings) controls it.

Note: `@Environment` and `@EnvironmentObject` sound similar but are different. `@Environment` is for **system values** (dark mode, locale). `@EnvironmentObject` is for **your own shared objects** (auth state, shopping cart).

### Example A — Simplest possible case

```swift
struct ThemeAwareText: View {
    // '\.colorScheme' is a key path to a system-provided value.
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Text(colorScheme == .dark ? "Dark mode is on" : "Light mode is on")
    }
}
```

### Example B — Real-world: dismissing a sheet and adapting layout

```swift
struct DetailSheet: View {
    // '\.dismiss' is an action provided by the system — call it to close the sheet.
    @Environment(\.dismiss) var dismiss
    // '\.horizontalSizeClass' tells you if the device is compact (phone) or regular (iPad).
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        VStack(spacing: 20) {
            Text("Detail View")
                // Use a larger font on iPad.
                .font(sizeClass == .regular ? .largeTitle : .title)

            Text("This is a modal sheet.")

            Button("Close") {
                dismiss()   // Dismisses this sheet — no need for a @Binding<Bool>
            }
        }
        .padding()
    }
}

struct ParentView: View {
    @State private var showSheet = false

    var body: some View {
        Button("Show Detail") {
            showSheet = true
        }
        // '.sheet' presents a modal view.
        .sheet(isPresented: $showSheet) {
            DetailSheet()
        }
    }
}
```

### Commonly used environment keys

```swift
@Environment(\.colorScheme) var colorScheme           // .light or .dark
@Environment(\.dismiss) var dismiss                   // Action to close current view
@Environment(\.openURL) var openURL                   // Action to open a URL
@Environment(\.horizontalSizeClass) var hSizeClass    // .compact (phone) or .regular (iPad)
@Environment(\.verticalSizeClass) var vSizeClass      // .compact (landscape) or .regular
@Environment(\.locale) var locale                     // User's language/region
@Environment(\.isEnabled) var isEnabled               // Whether this view is interactive
```

---

## @AppStorage — The Fridge Whiteboard

> **What is `@AppStorage`?** It reads and writes simple values to `UserDefaults` — a tiny key-value database that comes with every iOS app. The value survives app restarts. It also triggers view updates, just like `@State`.
>
> **Analogy:** Writing something on the fridge whiteboard. Everyone in the kitchen can see it, and it **survives a power outage** (app restart). But you can only write short notes — not entire books.

### Example A — Simplest possible case

```swift
struct OnboardingCheck: View {
    // "hasSeenOnboarding" is the KEY in UserDefaults.
    // 'false' is the default if the key doesn't exist yet.
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        if hasSeenOnboarding {
            Text("Welcome back!")
        } else {
            Button("Complete Onboarding") {
                hasSeenOnboarding = true   // Saved to disk immediately
            }
        }
    }
}
```

### Example B — Real-world: a settings screen

```swift
struct SettingsView: View {
    @AppStorage("username") private var username = ""
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("fontSize") private var fontSize = 16.0

    var body: some View {
        Form {
            Section("Account") {
                TextField("Username", text: $username)
            }

            Section("Preferences") {
                Toggle("Notifications", isOn: $notificationsEnabled)

                // Slider = a draggable bar to pick a value in a range.
                VStack(alignment: .leading) {
                    Text("Font size: \(Int(fontSize))pt")
                    Slider(value: $fontSize, in: 12...24, step: 1)
                }
            }

            Section {
                Button("Reset All", role: .destructive) {
                    username = ""
                    notificationsEnabled = true
                    fontSize = 16.0
                }
            }
        }
        .navigationTitle("Settings")
    }
}
```

### Key points

- Works only with **simple types**: `String`, `Int`, `Double`, `Bool`, `URL`, `Data`.
- You **cannot** store complex objects (custom structs/classes) directly.
- The string you pass (e.g., `"username"`) is the UserDefaults key.
- Changes are written to disk **immediately** and survive app restarts.

### Common mistake

```swift
// ❌ WRONG: Trying to store a custom struct — won't compile.
@AppStorage("user") private var user: User

// ✅ CORRECT: Store a simple identifier, load the full object separately.
@AppStorage("userId") private var userId = ""
```

---

## @SceneStorage — Remembering Where the User Left Off

> **What is `@SceneStorage`?** Similar to `@AppStorage`, but it's tied to the current **scene** (window). On iPad, each window can have its own `@SceneStorage` values. iOS uses it for **state restoration** — if the system kills your app in the background, the values come back when the user returns.
>
> **Analogy:** A bookmark in a book. If someone takes the book away (the system kills the app) and gives it back, your bookmark is still there. But each reader (each window on iPad) has their own bookmark.

### Example A — Simplest possible case

```swift
struct ContentView: View {
    // Restores the selected tab when the app re-launches.
    @SceneStorage("selectedTab") private var selectedTab = 0

    var body: some View {
        // TabView = a tab bar at the bottom of the screen.
        TabView(selection: $selectedTab) {
            Text("Home").tag(0)
            Text("Search").tag(1)
            Text("Profile").tag(2)
        }
    }
}
```

### Example B — Real-world: restoring a draft

```swift
struct NoteEditorView: View {
    @SceneStorage("draftText") private var draftText = ""
    @SceneStorage("scrollPosition") private var scrollPosition = 0.0

    var body: some View {
        VStack {
            // TextEditor = a multi-line text input (like a text area).
            TextEditor(text: $draftText)
                .frame(minHeight: 200)

            Text("\(draftText.count) characters")
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("Note")
    }
}
```

### Key points

- **Per-scene** (per-window on iPad), unlike `@AppStorage` which is global.
- Survives app termination and relaunch.
- Use for **UI state only** (selected tab, scroll position, draft text) — not for important data.
- Same type restrictions as `@AppStorage` (simple types only).

---

## Comparison Table

| Wrapper | What it stores | Who owns it | Survives restart? | Analogy |
|---------|---------------|-------------|-------------------|---------|
| `@State` | Simple values (Int, Bool, String) | This view | No | Light switch on the wall |
| `@Binding` | Reference to someone else's `@State` | Parent view | No | Remote control for parent's switch |
| `@StateObject` | A ViewModel (class) | This view creates it | No | TV you bought and plugged in |
| `@ObservedObject` | A ViewModel (class) | Passed in by parent | No | Watching someone else's TV |
| `@EnvironmentObject` | A shared ViewModel (class) | Injected at top of tree | No | WiFi router — whole house uses it |
| `@Environment` | System values (dark mode, locale) | The system | N/A | Thermostat — read-only |
| `@AppStorage` | Simple value in UserDefaults | UserDefaults (disk) | **Yes** | Fridge whiteboard |
| `@SceneStorage` | Simple value per window | Scene restoration | **Yes** | Bookmark in a book |

---

## State Flow Diagram

This shows how state typically flows through a SwiftUI app, from the top (app-wide) to the bottom (individual views):

```
┌──────────────────────────────────────────────────────────────────┐
│                        App Level                                  │
│                                                                    │
│  @StateObject creates app-wide objects (AuthState, UserSettings)  │
│          ↓                                                         │
│  .environmentObject() injects them into the entire view tree       │
└──────────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────────┐
│                     Feature Level                                  │
│                                                                    │
│  @StateObject creates a ViewModel for this feature                │
│          ↓                                                         │
│  Passed to child views as @ObservedObject                         │
└──────────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────────┐
│                      View Level                                    │
│                                                                    │
│  @State for local UI state (isExpanded, showAlert, searchText)    │
│          ↓                                                         │
│  Passed to child views as $binding                                │
└──────────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────────┐
│                     Child View Level                               │
│                                                                    │
│  @Binding to modify parent's @State                               │
│  @ObservedObject to read/write parent's ViewModel                 │
│  @EnvironmentObject to access app-wide shared state               │
│  @Environment to read system settings (dark mode, locale, etc.)   │
└──────────────────────────────────────────────────────────────────┘
```

---

## Real-World Example: Complete Feature

This pulls together all the wrappers into one mini-feature — a user profile screen.

```swift
import SwiftUI

// ── Model ──────────────────────────────────────────────────────

// 'Codable' = can be converted to/from JSON.
// 'Identifiable' = has a unique 'id', required for Lists.
struct User: Codable, Identifiable {
    let id: String
    var name: String
    var email: String
}

// ── App-Wide State (injected via .environmentObject) ──────────

class AppState: ObservableObject {
    @Published var currentUser: User?
    @Published var theme: Theme = .system

    // 'enum' = a fixed set of options (like an enum in Java/Kotlin/TS).
    enum Theme: String {
        case light, dark, system
    }
}

// ── Feature ViewModel (created with @StateObject) ─────────────

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load(from user: User?) {
        guard let user = user else { return }
        name = user.name
        email = user.email
    }

    func save() async {
        isLoading = true
        errorMessage = nil

        try? await Task.sleep(for: .seconds(1))

        if name.isEmpty {
            errorMessage = "Name cannot be empty."
        }

        isLoading = false
    }
}

// ── Main Screen ────────────────────────────────────────────────

struct ProfileScreen: View {
    // @StateObject — this view CREATES and OWNS the ViewModel.
    @StateObject private var viewModel = ProfileViewModel()

    // @EnvironmentObject — grabs the app-wide state from the environment.
    @EnvironmentObject var appState: AppState

    // @AppStorage — remembers whether the user completed their profile.
    @AppStorage("profileComplete") private var profileComplete = false

    // @State — local UI toggle for edit mode.
    @State private var isEditing = false

    var body: some View {
        Form {
            Section("Profile") {
                if isEditing {
                    // @Binding via $viewModel.name — the text field can modify the ViewModel.
                    TextField("Name", text: $viewModel.name)
                    TextField("Email", text: $viewModel.email)
                } else {
                    Text(viewModel.name)
                    Text(viewModel.email)
                        .foregroundStyle(.secondary)
                }
            }

            if let error = viewModel.errorMessage {
                Text(error).foregroundStyle(.red)
            }

            Section {
                if isEditing {
                    Button("Save") {
                        Task { await viewModel.save() }
                    }
                    .disabled(viewModel.isLoading)

                    Button("Cancel", role: .cancel) {
                        isEditing = false
                        viewModel.load(from: appState.currentUser)
                    }
                } else {
                    Button("Edit") { isEditing = true }
                }
            }

            // Pass state to a child via @Binding and @ObservedObject.
            ProfileFooter(isEditing: $isEditing, viewModel: viewModel)
        }
        .navigationTitle("Profile")
        .onAppear {
            viewModel.load(from: appState.currentUser)
        }
    }
}

// ── Child View ─────────────────────────────────────────────────

struct ProfileFooter: View {
    // @Binding — can toggle the parent's edit mode.
    @Binding var isEditing: Bool

    // @ObservedObject — borrows the parent's ViewModel (doesn't own it).
    @ObservedObject var viewModel: ProfileViewModel

    // @Environment — reads the system color scheme.
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Section {
            HStack {
                // 'Image(systemName:)' = an SF Symbol icon.
                Image(systemName: isEditing ? "pencil.circle.fill" : "pencil.circle")
                Text(isEditing ? "Editing..." : "View mode")
                    .foregroundStyle(colorScheme == .dark ? .white : .primary)
            }
        }
    }
}
```

---

## Testing Tips

You don't test `@State` directly — you test the **ViewModel** (the class with `ObservableObject`) in isolation, and use **Xcode Previews** or **UI tests** for the view itself.

### Testing a ViewModel

```swift
import XCTest

// '@testable import YourApp' makes internal types visible in tests.
@testable import YourApp

final class ProfileViewModelTests: XCTestCase {
    // 'func test...' = a test method. Xcode runs all methods starting with 'test'.
    func testSaveShowsErrorWhenNameEmpty() async {
        let viewModel = ProfileViewModel()
        viewModel.name = ""

        await viewModel.save()

        // XCTAssertEqual checks that two values are the same.
        XCTAssertEqual(viewModel.errorMessage, "Name cannot be empty.")
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLoadPopulatesFields() {
        let viewModel = ProfileViewModel()
        let user = User(id: "1", name: "Alice", email: "alice@test.com")

        viewModel.load(from: user)

        XCTAssertEqual(viewModel.name, "Alice")
        XCTAssertEqual(viewModel.email, "alice@test.com")
    }
}
```

### Testing a @Binding

```swift
func testBindingModifiesParentValue() {
    var value = 0
    // Create a Binding manually for testing.
    let binding = Binding(
        get: { value },
        set: { value = $0 }
    )

    // Simulate the child changing the binding.
    binding.wrappedValue = 42

    XCTAssertEqual(value, 42)
}
```

### Previews as visual tests

```swift
// Use #Preview to visually check different states.
#Preview("Editing mode") {
    ProfileScreen()
        .environmentObject(AppState())
}

#Preview("Dark mode") {
    ProfileScreen()
        .environmentObject(AppState())
        .preferredColorScheme(.dark)
}
```

---

## Performance Considerations

SwiftUI re-runs `body` every time a `@State`, `@Binding`, `@StateObject`, etc. changes. Here's how to keep that fast.

### 1. Don't do heavy work inside `body`

```swift
// ❌ BAD: Filtering and sorting runs EVERY time body is called.
var body: some View {
    let active = items.filter { $0.isActive }.sorted { $0.name < $1.name }
    Text("\(active.count) items")
}

// ✅ GOOD: Move it to a computed property so the intent is clear
//    and you can cache it later if needed.
private var activeItems: [Item] {
    items.filter { $0.isActive }.sorted { $0.name < $1.name }
}

var body: some View {
    Text("\(activeItems.count) items")
}
```

### 2. Use @StateObject, not @ObservedObject, for owned ViewModels

```swift
// ❌ BAD: @ObservedObject with inline creation → ViewModel is destroyed
//    and recreated every time the PARENT re-renders.
struct MyView: View {
    @ObservedObject var viewModel = MyViewModel()
    var body: some View { /* ... */ }
}

// ✅ GOOD: @StateObject keeps the ViewModel alive across parent re-renders.
struct MyView: View {
    @StateObject private var viewModel = MyViewModel()
    var body: some View { /* ... */ }
}
```

### 3. Break large views into smaller ones

When a `@State` changes, only the view that **owns** it (and its children) re-render. Splitting your UI into smaller views means fewer things re-render on each change.

```swift
// ❌ BAD: One giant view — everything re-renders when ANY @State changes.
struct GiantView: View {
    @State private var searchText = ""
    @State private var selectedTab = 0
    @State private var showFilter = false

    var body: some View {
        // 300 lines of UI...
    }
}

// ✅ GOOD: Split into focused sub-views.
struct SearchBar: View {
    @Binding var text: String
    var body: some View { TextField("Search", text: $text) }
}
```

### 4. Use EquatableView for expensive views

If a view is expensive to render, you can tell SwiftUI to skip re-rendering unless specific data actually changed:

```swift
// 'Equatable' = lets SwiftUI compare old vs new to skip unnecessary redraws.
struct ExpensiveChart: View, Equatable {
    let dataPoints: [Double]

    // Only re-render if the number of points changed.
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.dataPoints.count == rhs.dataPoints.count
    }

    var body: some View {
        // Complex chart rendering...
        Text("Chart with \(dataPoints.count) points")
    }
}
```
