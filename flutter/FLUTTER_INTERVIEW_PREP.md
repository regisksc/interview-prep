# Flutter Senior Engineer — Interview Prep Course

> **Difficulty target:** Moderate (expect depth on architecture, state, and Dart internals, not leetcode-hard algorithms)
> **Format:** Modules ordered by interview impact. Do Module 1 first, always.

---

## Table of Contents

| # | Module | Why it matters |
|---|--------|---------------|
| 1 | [Dart Language Fundamentals](#module-1-dart-language-fundamentals) | Every Flutter question assumes fluent Dart |
| 2 | [Widget Tree & Rendering Pipeline](#module-2-widget-tree--rendering-pipeline) | The mental model interviewers test most |
| 3 | [State Management](#module-3-state-management) | Biggest differentiation between mid and senior |
| 4 | [Architecture & Project Structure](#module-4-architecture--project-structure) | Senior signal: can you own a codebase? |
| 5 | [Async, Streams & Isolates](#module-5-async-streams--isolates) | Deep Dart — expected at senior level |
| 6 | [Navigation](#module-6-navigation) | Practical, frequently tested |
| 7 | [Performance & Optimization](#module-7-performance--optimization) | Shows production experience |
| 8 | [Testing Strategy](#module-8-testing-strategy) | Non-negotiable in production-grade apps |
| 9 | [Platform Channels & Native Integration](#module-9-platform-channels--native-integration) | Differentiator for senior roles |
| 10 | [Security, Privacy & Compliance](#module-10-security-privacy--compliance) | Critical for any app handling sensitive user data |
| 11 | [Accessibility](#module-11-accessibility) | Required in any user-facing production app |
| 12 | [CI/CD & Release Pipeline](#module-12-cicd--release-pipeline) | Shows ownership beyond code |
| 13 | [Behavioral & System Design](#module-13-behavioral--system-design) | The round that actually gets you hired |

---

## Module 1: Dart Language Fundamentals

> **Priority: CRITICAL.** Flutter is Dart. If you stumble on Dart basics, nothing else matters.

---

### 1.1 Null Safety

Dart has sound null safety since Dart 2.12. Every type is non-nullable by default.

```dart
String name = 'Regis';   // never null
String? nickname;         // nullable

// Safe navigation
int? length = nickname?.length;

// Null assertion (throws if null at runtime — avoid in production)
int len = nickname!.length;

// Null-coalescing
String display = nickname ?? 'anonymous';

// Null-coalescing assignment
nickname ??= 'default';
```

**What interviewers ask:**
- "What's the difference between `late` and nullable `?`?"

```dart
// late: non-nullable but initialized after declaration
// Use when you KNOW it will be set before use (e.g., initState)
late String userId;

// Dangerous: throws LateInitializationError if accessed before set
```

- "What is `required` in constructors?"

```dart
class User {
  final String id;
  final String? email;

  const User({required this.id, this.email});
}
```

---

### 1.2 `const` vs `final` vs `var`

| Keyword | When resolved | Mutable |
|---------|--------------|---------|
| `const` | Compile time | No |
| `final` | Runtime (once) | No |
| `var` | Runtime | Yes |

```dart
const pi = 3.14159;             // compile-time constant
final now = DateTime.now();     // runtime, set once
var count = 0;                  // mutable
```

**In Flutter context:** `const` widgets are never rebuilt. Always prefer `const` for static UI.

---

### 1.3 Generics

Generics allow you to write reusable, type-safe code that works with any type. Instead of duplicating `UserRepository`, `OrderRepository`, etc., you define one generic `Repository<T>` and the compiler enforces the correct type at every call site. `<T>` is a type parameter — a placeholder substituted at compile time by the concrete type you provide.

```dart
class Repository<T> {
  Future<T> findById(String id) async { ... }
  Future<List<T>> findAll() async { ... }
}

// Usage
final userRepo = Repository<User>();
```

---

### 1.4 Extensions

Add methods to existing types without subclassing:

```dart
extension StringCasing on String {
  String toTitleCase() =>
    split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
}

'hello world'.toTitleCase(); // 'Hello World'
```

---

### 1.5 Mixins

Share behavior across class hierarchies without inheritance:

```dart
mixin Loggable {
  void log(String message) => debugPrint('[${runtimeType}] $message');
}

class AuthService with Loggable {
  void login() {
    log('Login called');
  }
}
```

---

### 1.6 Callable Classes & `typedef`

A `typedef` creates a named alias for a function type, making signatures more readable and allowing functions to be passed as first-class values — the foundation of callback and strategy patterns in Dart.

```dart
typedef Predicate<T> = bool Function(T value);

bool isAdult(int age) => age >= 18;
Predicate<int> check = isAdult;
```

A **callable class** implements `call()` so that instances can be invoked with function syntax. Useful when a "function" needs to carry state or configuration.

```dart
class RangeValidator {
  final int min;
  final int max;
  const RangeValidator(this.min, this.max);

  bool call(int value) => value >= min && value <= max;
}

final inRange = RangeValidator(0, 100);
inRange(42); // true — called exactly like a function
```

---

### 1.7 Pattern Matching (Dart 3+)

Dart 3 introduced first-class pattern matching — the ability to match on the *shape and content* of values, not just equality. This eliminates verbose `if`/`else` chains and `is`/`as` casts, producing code that is both shorter and safer.

**Switch expressions** replace multi-branch if-else chains with a concise, exhaustive form:

```dart
// Switch expressions
String describe(Object obj) => switch (obj) {
  int n when n < 0 => 'negative',
  int n => 'positive int: $n',
  String s => 'string: $s',
  _ => 'unknown',
};

// Destructuring records unpacks multiple values at once — no positional indexing needed
final (name, age) = ('Regis', 30);

// Sealed classes define a *closed* type hierarchy — only subclasses in the same
// library are allowed. The compiler then makes switch exhaustive: every subtype
// must be handled or it's a compile-time error, not a runtime crash.
sealed class AuthState {}
class Authenticated extends AuthState { final String userId; Authenticated(this.userId); }
class Unauthenticated extends AuthState {}
class Loading extends AuthState {}

String label(AuthState state) => switch (state) {
  Authenticated(:final userId) => 'User: $userId',
  Unauthenticated() => 'Please log in',
  Loading() => 'Loading...',
};
```

> **Interviewers love this.** Dart 3 sealed classes + exhaustive switch is a senior signal.

---

### Module 1 — Quick fire answers

| Question | Answer |
|----------|--------|
| What is sound null safety? | Compiler guarantees no null dereference unless you use `?` or `!` |
| Difference between `is` and `as`? | `is` checks type, `as` casts (throws if wrong) |
| What is `dynamic`? | Opts out of type checking — avoid unless necessary |
| What is a record? | Anonymous, fixed-size tuple: `(String, int) pair = ('a', 1)` |

---

## Module 2: Widget Tree & Rendering Pipeline

> **Priority: CRITICAL.** The most common technical deep-dive area.

---

### 2.1 The Three Trees

Flutter maintains three parallel trees:

```
Widget Tree          Element Tree          RenderObject Tree
(configuration)      (identity/lifecycle)  (layout/paint)

Text("Hi")     →    StatelessElement  →   RenderParagraph
  │                      │                      │
Column(...)    →    MultiChildElement →   RenderFlex
```

- **Widget**: immutable config. Cheap to create and throw away.
- **Element**: mutable, long-lived. Holds the actual state and matches widgets across rebuilds.
- **RenderObject**: does the heavy work — layout (`performLayout`) and painting (`paint`).

**Key insight for interviews:** When you call `setState`, Flutter rebuilds the Widget subtree cheaply, then the Element tree reconciles (diffs) to update only the RenderObjects that actually changed.

---

### 2.2 StatelessWidget vs StatefulWidget

```dart
// StatelessWidget: pure function of its inputs
class Greeting extends StatelessWidget {
  final String name;
  const Greeting({super.key, required this.name});

  @override
  Widget build(BuildContext context) => Text('Hello, $name');
}

// StatefulWidget: holds mutable state across rebuilds
class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => setState(() => _count++),
      child: Text('Count: $_count'),
    );
  }
}
```

**When does `build()` run?**
1. First time the widget is inserted
2. `setState()` is called
3. Parent rebuilds and passes new configuration
4. An `InheritedWidget` it depends on changes (`context.dependOnInheritedWidgetOfExactType`)

---

### 2.3 Widget Keys

Keys tell Flutter how to match elements across rebuilds, especially in lists.

```dart
// Without keys: Flutter matches by position → bugs when reordering
// With keys: Flutter matches by identity

ListView(
  children: items.map((item) => ItemCard(key: ValueKey(item.id), item: item)).toList(),
)
```

Key types:
- `ValueKey(value)` — most common, match by value
- `ObjectKey(object)` — match by object identity
- `UniqueKey()` — forces recreation every rebuild (use sparingly)
- `GlobalKey` — access a widget's state from outside its subtree (heavy, avoid)

---

### 2.4 InheritedWidget

The low-level mechanism behind `Theme`, `MediaQuery`, `Navigator`, and all state management solutions.

```dart
class AppConfig extends InheritedWidget {
  final String apiUrl;

  const AppConfig({required this.apiUrl, required super.child});

  static AppConfig of(BuildContext context) =>
    context.dependOnInheritedWidgetOfExactType<AppConfig>()!;

  @override
  bool updateShouldNotify(AppConfig old) => apiUrl != old.apiUrl;
}

// Consumer
final url = AppConfig.of(context).apiUrl;
```

`updateShouldNotify` controls whether descendants rebuild when the `InheritedWidget` changes.

---

### 2.5 BuildContext

`BuildContext` is a reference to the Element in the tree. It knows the widget's position — used to look up ancestors (`Theme.of(context)`, `Navigator.of(context)`).

**Common mistake:** Using context after `async` gap without checking `mounted`.

```dart
Future<void> _save() async {
  await repository.save(data);

  if (!mounted) return; // ALWAYS check this
  ScaffoldMessenger.of(context).showSnackBar(...);
}
```

---

### 2.6 Layout System in 60 Seconds

Flutter layout rule: **constraints go down, sizes go up, parent positions children.**

```
Parent: "You can be 0–300px wide"
Child:  "I want to be 150px wide"
Parent: positions child at (x, y)
```

Key widgets:
- `Flexible` / `Expanded` — flex children inside Row/Column
- `ConstrainedBox` — adds min/max constraints
- `SizedBox` — forces a specific size
- `LayoutBuilder` — lets you build based on available constraints

---

### Module 2 — Quick fire answers

| Question | Answer |
|----------|--------|
| Why are widgets immutable? | Rebuilding cheap config objects is faster than mutating a complex tree |
| What is `const` doing to a widget? | Creates it at compile-time; Flutter skips diffing it entirely |
| What is a `RenderObject`? | Handles layout and painting; expensive to create |
| When would you use `GlobalKey`? | Form validation across subtrees, accessing State from outside |

---

## Module 3: State Management

> **Priority: CRITICAL.** This is where senior vs mid engineers are separated.

---

### 3.1 The Spectrum

```
Local ←————————————————————————————→ Global
setState  ValueNotifier  Provider  Riverpod  Bloc
  │            │            │         │        │
Simple UI   Reactive    Context-   Compile-  Event-
 changes    listeners   based DI    safe     driven
```

No single right answer — the senior answer is knowing **when to use which.**

---

### 3.2 setState — Know its limits

`setState` is the built-in mechanism for triggering a rebuild of a `StatefulWidget`. It schedules a rebuild of the widget's subtree by marking the element dirty — Flutter then calls `build()` again on the next frame. It is synchronous (the callback runs immediately), but the actual rebuild is deferred to the next frame.

```dart
setState(() => _isLoading = true);
```

- Only rebuilds the subtree of the current `StatefulWidget`
- Fine for local UI state (toggle, form field focus, animation trigger)
- Anti-pattern: lifting all state into a root `StatefulWidget`

---

### 3.3 ValueNotifier + ValueListenableBuilder

For reactive local state without a full state management library:

```dart
final counter = ValueNotifier<int>(0);

// In widget tree:
ValueListenableBuilder<int>(
  valueListenable: counter,
  builder: (context, value, _) => Text('$value'),
);

// Update:
counter.value++;
```

---

### 3.4 Riverpod (Modern Standard)

Riverpod is compile-safe, testable, and doesn't require `BuildContext` for logic.

```dart
// 1. Define a provider
final userProvider = AsyncNotifierProvider<UserNotifier, User>(() {
  return UserNotifier();
});

class UserNotifier extends AsyncNotifier<User> {
  @override
  Future<User> build() => ref.read(userRepositoryProvider).getCurrentUser();

  Future<void> logout() async {
    state = const AsyncLoading();
    await ref.read(authServiceProvider).logout();
    state = AsyncError('Logged out', StackTrace.current);
  }
}

// 2. Consume it
class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      data: (user) => Text(user.name),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
```

**Key Riverpod concepts:**
- `ref.watch` — rebuild on change (use in `build`)
- `ref.read` — one-time read, no rebuild (use in callbacks)
- `ref.listen` — react to changes without rebuilding (side effects)
- `Provider.family` — parameterized providers
- `Provider.autoDispose` — clean up when no longer watched

---

### 3.5 Bloc / Cubit

```dart
// Cubit: simpler, emits states directly
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepo) : super(AuthInitial());

  final AuthRepository _authRepo;

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authRepo.login(email, password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}

// Bloc: events → states (more explicit, better for complex flows)
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepo) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    // ...
  }
}
```

**When to use Bloc over Cubit?**
> When state transitions are complex, auditable, or need to be logged/replayed. Bloc's event stream is fully serializable.

---

### 3.6 How to answer "Which state management do you use?"

> "I evaluate based on three things: **scope** (is this local or global state?), **team familiarity**, and **testability requirements**. For local UI state I use `setState` or `ValueNotifier`. For feature-level shared state I lean on **Riverpod** because it's compile-safe and doesn't require a context to read state in business logic. For teams already on Bloc, I'm comfortable there too — the explicitness of events is valuable in complex, auditable flows like auth or payment."

---

### Module 3 — Quick fire answers

| Question | Answer |
|----------|--------|
| What is `ChangeNotifier`? | Base class that notifies listeners. Foundation of Provider |
| Provider vs Riverpod? | Riverpod: no context in logic, compile-safe, better scoping, testable without app |
| Can Bloc replace Riverpod? | Yes for state, but they solve slightly different problems. Bloc is pure state machine; Riverpod is also a DI container |
| What is `BlocBuilder` vs `BlocListener`? | Builder: rebuilds UI. Listener: one-time side effects (snackbar, nav) |

---

## Module 4: Architecture & Project Structure

> **Priority: HIGH.** Interviewers want to know if you can own a production codebase.

---

### 4.1 Clean Architecture in Flutter

```
Presentation Layer    →  Widgets, screens, state (Bloc/Riverpod)
Domain Layer          →  Entities, use cases, repository interfaces
Data Layer            →  Repository implementations, data sources, DTOs
```

```
lib/
  features/
    auth/
      data/
        datasources/    # remote_auth_datasource.dart, local_auth_datasource.dart
        models/         # user_model.dart  (JSON ↔ entity conversion)
        repositories/   # auth_repository_impl.dart
      domain/
        entities/       # user.dart  (pure Dart, no Flutter/JSON)
        repositories/   # auth_repository.dart  (abstract)
        usecases/       # login_usecase.dart
      presentation/
        screens/        # login_screen.dart
        widgets/        # login_form.dart
        state/          # auth_cubit.dart / auth_provider.dart
    therapy/
      ...
  core/
    network/            # dio_client.dart, interceptors
    di/                 # injection_container.dart
    router/             # app_router.dart
    theme/              # app_theme.dart
    error/              # failures.dart, exceptions.dart
```

---

### 4.2 Repository Pattern

Abstract the data source behind an interface:

```dart
// Domain layer — pure Dart interface
abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, void>> logout();
}

// Data layer — knows about HTTP, local DB, etc.
class AuthRepositoryImpl implements AuthRepository {
  final RemoteAuthDataSource _remote;
  final LocalAuthDataSource _local;

  AuthRepositoryImpl(this._remote, this._local);

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final userModel = await _remote.login(email, password);
      await _local.cacheUser(userModel);
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
```

**Why `Either`?** From `fpdart` or `dartz`. Forces callers to handle both success and failure without exceptions leaking across layers.

---

### 4.3 Dependency Injection

Dependency Injection (DI) is the practice of providing a class's dependencies from outside rather than letting it create them internally. This decouples components: a `LoginScreen` doesn't know whether it's talking to a real HTTP server or a fake in-memory one — it just receives whatever satisfies the `AuthRepository` interface. In Flutter, the two common approaches are `get_it` (a service locator) and Riverpod (where providers double as a DI container).

```dart
// get_it + injectable
@module
abstract class NetworkModule {
  @singleton
  Dio get dio => Dio(BaseOptions(baseUrl: Env.apiUrl));
}

@singleton
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._local);
  // ...
}

// Register
configureDependencies();

// Resolve
final repo = getIt<AuthRepository>();
```

With Riverpod: providers ARE your DI container. No separate setup needed.

---

### 4.4 Feature Flags

Feature flags decouple feature releases from code deployments. You ship code disabled by default, then enable it progressively — by user percentage, user segment, or A/B test — without a new app store submission. This reduces risk (easy rollback: just flip the flag), enables experimentation, and lets you test in production with a subset of real users before a full rollout.

```dart
// Simple: remote config (Firebase Remote Config, LaunchDarkly)
final isFeatureEnabled = remoteConfig.getBool('feature_v2');

// In widget tree
if (featureFlags.isEnabled('new_onboarding'))
  const NewOnboardingScreen()
else
  const LegacyOnboardingScreen()
```

---

### Module 4 — Quick fire answers

| Question | Answer |
|----------|--------|
| What is the domain layer? | Pure Dart — no Flutter, no HTTP, no JSON. Business logic only |
| Why separate data models from entities? | Models handle JSON parsing (fragile). Entities represent truth. Keeps domain clean |
| What is a use case? | Single-responsibility class: one action, one entry point |
| How do you handle environment configs? | `.env` files + `--dart-define` at build time, or `flutter_dotenv` |

---

## Module 5: Async, Streams & Isolates

> **Priority: HIGH.** Expected depth at senior level.

---

### 5.1 Future & async/await

A `Future<T>` represents a value that will be available at some point in the future — Dart's equivalent of a Promise. `async/await` is syntactic sugar over Future chaining (`.then`/`.catchError`) that makes asynchronous code read like synchronous code. Because Dart is single-threaded, Futures don't run in parallel — they interleave on the event loop. To truly run things in parallel, combine multiple Futures with `.wait` or use isolates.

```dart
Future<User> getUser(String id) async {
  final response = await http.get(Uri.parse('/users/$id'));
  if (response.statusCode != 200) throw ServerException();
  return User.fromJson(jsonDecode(response.body));
}

// Error handling
try {
  final user = await getUser('123');
} on ServerException {
  // handle
} catch (e, stackTrace) {
  // unexpected error
  debugPrint('$e\n$stackTrace');
}

// Parallel futures
final (user, config) = await (getUser(id), getAppConfig()).wait;
```

---

### 5.2 Streams

A `Stream<T>` is an asynchronous sequence of events — think of it as an async `Iterable`. Unlike a `Future` (one value, then done), a Stream can deliver zero, one, or many values over time. Common real-world streams: Firebase auth state changes, Bluetooth device events, WebSocket messages, or location updates.

**Single-subscription streams** can only have one listener at a time and buffer events until that listener is attached — suited for one-off operations like reading a file. **Broadcast streams** support multiple simultaneous listeners and don't buffer — suited for event buses and state changes.

```dart
// Single subscription (default) — like a pipe
final stream = Stream<int>.periodic(
  const Duration(seconds: 1),
  (count) => count,
).take(5);

// Broadcast stream — multiple listeners
final controller = StreamController<AuthState>.broadcast();
controller.add(AuthState.authenticated);

// Transform
stream
  .where((n) => n.isEven)
  .map((n) => 'Even: $n')
  .listen(debugPrint);

// async* generator
Stream<int> countdown(int from) async* {
  for (var i = from; i >= 0; i--) {
    yield i;
    await Future.delayed(const Duration(seconds: 1));
  }
}
```

**StreamBuilder in Flutter** subscribes to a stream when the widget is inserted and automatically unsubscribes when it is removed — you don't manage the subscription lifecycle manually. Each new event triggers a rebuild with an updated `AsyncSnapshot`:

```dart
StreamBuilder<User?>(
  stream: authRepository.authStateChanges,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const SplashScreen();
    }
    if (snapshot.hasData) return const HomeScreen();
    return const LoginScreen();
  },
)
```

---

### 5.3 Isolates

Dart is single-threaded (one event loop). Isolates are true threads with separate heaps.

```dart
// Simple offload with compute()
final parsed = await compute(parseHeavyJson, rawJsonString);

List<Item> parseHeavyJson(String json) {
  // runs in a separate isolate
  return (jsonDecode(json) as List).map(Item.fromJson).toList();
}

// Long-running isolate with bidirectional communication
final receivePort = ReceivePort();
await Isolate.spawn(heavyTask, receivePort.sendPort);

receivePort.listen((message) {
  debugPrint('Got: $message');
});
```

**When to use isolates:**
- JSON parsing of large payloads
- Image processing
- Encryption/decryption
- Complex algorithms over big datasets

---

### 5.4 Event Loop

```
Main Isolate
  ├── MicroTask Queue (highest priority — Future completions)
  └── Event Queue (lower priority — I/O, timers, user input)
```

```dart
void main() {
  debugPrint('1');
  Future(() => debugPrint('3')); // event queue
  Future.microtask(() => debugPrint('2')); // microtask queue
  debugPrint('4');
}
// Output: 1, 4, 2, 3
```

---

### Module 5 — Quick fire answers

| Question | Answer |
|----------|--------|
| `async` vs `async*`? | `async` returns a Future; `async*` returns a Stream |
| `yield` vs `yield*`? | `yield` emits one value; `yield*` delegates to another stream/iterable |
| Can two isolates share memory? | No. They communicate only via messages (SendPort/ReceivePort) |
| What is `unawaited`? | Utility to explicitly fire-and-forget a Future without warning |

---

## Module 6: Navigation

> **Priority: MEDIUM-HIGH.** Practical and almost always discussed.

---

### 6.1 GoRouter (Recommended)

```dart
final router = GoRouter(
  initialLocation: '/home',
  redirect: (context, state) {
    final isLoggedIn = ref.read(authProvider).isAuthenticated;
    if (!isLoggedIn && !state.location.startsWith('/auth')) return '/auth/login';
    return null;
  },
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'profile/:userId',
          builder: (context, state) {
            final userId = state.pathParameters['userId']!;
            return ProfileScreen(userId: userId);
          },
        ),
      ],
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [ /* bottom nav routes */ ],
    ),
  ],
);
```

**Deep linking:** Add `GoRouter` handles it automatically on iOS (Universal Links) and Android (App Links) when configured in `AndroidManifest.xml` and `Info.plist`.

---

### 6.2 Navigation Patterns

Understanding the distinction between navigation methods is a common interview question. The key difference: `go` replaces the entire navigation stack (the user cannot go back), while `push` adds to the stack (the back button remains). Use `go` for top-level route changes (e.g., post-login redirect), `push` for modal or detail screens, and `replace` when you want to swap the current route without adding to history.

```dart
// Push
context.go('/home/profile/123');

// Replace (no back button)
context.replace('/login');

// Push on stack
context.push('/modal');

// Pass extra data (not in URL)
context.push('/details', extra: myObject);

// Pop with result
context.pop(result);
```

---

### Module 6 — Quick fire answers

| Question | Answer |
|----------|--------|
| Navigator 1 vs 2? | 1 is imperative stack. 2 is declarative (pages list). GoRouter wraps 2 |
| How to protect routes? | `redirect` callback in GoRouter; check auth state before allowing navigation |
| How to handle nested navigation? | `ShellRoute` in GoRouter; each shell has its own Navigator |

---

## Module 7: Performance & Optimization

> **Priority: MEDIUM-HIGH.** Shows production experience.

---

### 7.1 Avoiding Unnecessary Rebuilds

```dart
// BAD: new instance every build
Widget build(BuildContext context) {
  return MyWidget(callback: () => doSomething()); // new closure each build
}

// GOOD: extract to method or use const
Widget build(BuildContext context) {
  return const MyWidget(); // const: never rebuilt
}

// GOOD: use callbacks stored in state
class _State extends State<MyWidget> {
  late final VoidCallback _onTap = () => doSomething();

  @override
  Widget build(BuildContext context) {
    return MyWidget(callback: _onTap);
  }
}
```

**Riverpod — select to limit rebuilds:**
```dart
// Rebuilds only when name changes, not the whole User object
final name = ref.watch(userProvider.select((u) => u.name));
```

---

### 7.2 List Performance

`ListView` without a builder instantiates every child widget upfront, even those off-screen — fine for 5 items, catastrophic for 500. `ListView.builder` renders only the items currently visible (plus a small cache margin), making scroll performance O(visible items) instead of O(total items). When all items have the same height, providing `itemExtent` gives Flutter an additional win: it can calculate each item's position mathematically and skip the per-item layout pass entirely.

```dart
// BAD: builds all items upfront
ListView(children: items.map((i) => ItemCard(i)).toList())

// GOOD: builds lazily as user scrolls
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemCard(items[index]),
)

// For dynamic sizes: ListView.builder is fine
// For known equal heights: ListView + itemExtent (faster layout)
ListView.builder(
  itemExtent: 72,
  itemCount: items.length,
  itemBuilder: (_, i) => ItemTile(items[i]),
)
```

---

### 7.3 RepaintBoundary

Isolates a subtree from repaints caused by ancestors:

```dart
RepaintBoundary(
  child: AnimatedCounter(), // only this repaints on animation, not the whole screen
)
```

---

### 7.4 Image Optimization

```dart
// Resize images to display size — avoid loading 4K images for 50x50 thumbnails
Image.network(
  url,
  width: 50,
  height: 50,
  cacheWidth: 100,  // decode at 2x for retina, not full resolution
  cacheHeight: 100,
)

// Use cached_network_image for disk + memory cache
CachedNetworkImage(imageUrl: url)
```

---

### 7.5 DevTools Profiling

- **Widget Inspector**: find unnecessary rebuilds (check "Track widget build counts")
- **Performance overlay**: two graphs — UI thread (Dart) and Raster thread (GPU). Both should stay below 16ms for 60fps.
- **Timeline**: find jank, identify slow frames

---

### Module 7 — Quick fire answers

| Question | Answer |
|----------|--------|
| What causes jank? | Work on the UI thread > 16ms. Typically: heavy synchronous computation, excessive rebuilds, large images decoded at full res |
| What is the raster thread? | GPU thread. Responsible for compositing layers. Blocked by complex shaders or too many layers |
| How to check if a widget rebuilds? | Add `debugPrint` in `build`, or use `flutter_hooks` / Widget Inspector |
| What is `Sliver`? | Low-level, lazy scroll primitive. Powers all scrollable widgets |

---

## Module 8: Testing Strategy

> **Priority: HIGH.** Quality is non-negotiable in production apps.

---

### 8.1 Three Test Levels

| Level | Speed | Scope | Package |
|-------|-------|-------|---------|
| Unit | Fast | Single class/function | `flutter_test` |
| Widget | Medium | Widget subtree | `flutter_test` |
| Integration | Slow | Full app | `integration_test` |

**Target ratio:** ~70% unit, ~20% widget, ~10% integration.

---

### 8.2 Unit Tests

```dart
// Test the use case in isolation
group('LoginUseCase', () {
  late MockAuthRepository mockRepo;
  late LoginUseCase useCase;

  setUp(() {
    mockRepo = MockAuthRepository();
    useCase = LoginUseCase(mockRepo);
  });

  test('returns user on success', () async {
    when(() => mockRepo.login(any(), any()))
        .thenAnswer((_) async => Right(tUser));

    final result = await useCase(LoginParams(email: 'a@b.com', password: '123'));

    expect(result, Right(tUser));
    verify(() => mockRepo.login('a@b.com', '123')).called(1);
  });

  test('returns failure on error', () async {
    when(() => mockRepo.login(any(), any()))
        .thenAnswer((_) async => Left(ServerFailure('error')));

    final result = await useCase(LoginParams(email: 'a@b.com', password: '123'));

    expect(result.isLeft(), true);
  });
});
```

---

### 8.3 Widget Tests

Widget tests render a widget tree in a test environment (no real device needed) and let you interact with it programmatically. `pumpWidget` inserts the widget into the test harness and renders one frame. When using Riverpod, you provide a `ProviderContainer` with overrides so the widget uses fakes instead of real services — keeping tests fast and deterministic without network calls.

```dart
testWidgets('shows loading indicator while logging in', (tester) async {
  // Arrange
  final container = ProviderContainer(
    overrides: [authProvider.overrideWith(() => FakeAuthNotifier())],
  );

  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(home: LoginScreen()),
  ));

  // Act
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump(); // one frame after tap

  // Assert
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

---

### 8.4 Mocking with mocktail

`mocktail` is preferred over `mockito` because it requires **no code generation** — you extend `Mock` directly and stub with `when`/`verify` without running `build_runner`. In clean architecture, you mock at the repository boundary: the use case (or cubit) under test receives a `MockAuthRepository` and you verify that the right methods are called with the right arguments.

```dart
// Define mock
class MockAuthRepository extends Mock implements AuthRepository {}

// Stub
when(() => mockRepo.login(any(), any()))
    .thenAnswer((_) async => Right(fakeUser));

// Verify
verify(() => mockRepo.login('email', 'password')).called(1);
verifyNever(() => mockRepo.logout());
```

---

### 8.5 Golden Tests

Snapshot tests for UI — catch visual regressions:

```dart
testWidgets('ProfileCard matches golden', (tester) async {
  await tester.pumpWidget(const ProfileCard(name: 'Regis'));
  await expectLater(find.byType(ProfileCard), matchesGoldenFile('goldens/profile_card.png'));
});
```

---

### Module 8 — Quick fire answers

| Question | Answer |
|----------|--------|
| What is `pump` vs `pumpAndSettle`? | `pump`: one frame. `pumpAndSettle`: pumps until no more frames (waits for animations) |
| How to test navigation in widget tests? | Use `mockGoRouter` package or provide a real `GoRouter` in the test widget tree |
| How do you test Riverpod providers? | `ProviderContainer` with overrides — no Flutter app required |

---

## Module 9: Platform Channels & Native Integration

> **Priority: MEDIUM.** Differentiator for senior roles.

---

### 9.1 MethodChannel

Flutter → Native call (one-shot):

```dart
// Dart side
const channel = MethodChannel('com.myapp.app/biometric');

Future<bool> authenticate() async {
  return await channel.invokeMethod<bool>('authenticate') ?? false;
}

// iOS (Swift)
let channel = FlutterMethodChannel(name: "com.myapp.app/biometric", binaryMessenger: controller.binaryMessenger)
channel.setMethodCallHandler { call, result in
  if call.method == "authenticate" {
    // Local auth logic
    result(true)
  }
}
```

---

### 9.2 EventChannel

Use `EventChannel` when native code needs to push a **continuous stream of events** to Dart — for example, sensor readings, Bluetooth device discoveries, or network connectivity changes. Unlike `MethodChannel` (one request → one response), an EventChannel establishes a persistent subscription: the native side calls `eventSink.success(data)` repeatedly, and Dart receives each emission as a stream event.

```dart
// Dart
const eventChannel = EventChannel('com.myapp.app/sensor_data');

Stream<SensorData> get sensorStream =>
    eventChannel.receiveBroadcastStream().map((e) => SensorData.fromMap(e));
```

---

### 9.3 Pigeon (Recommended for new code)

Pigeon is Google's code generator for platform channels. You define the API once in Dart using annotations, then run `dart run pigeon --input pigeons/biometric.dart` to generate type-safe Swift, Kotlin, and Dart glue code. This eliminates stringly-typed method names (the root cause of most channel bugs) and gives you compile-time verification that both sides of the channel agree on method signatures and argument types.

```dart
// Define in Dart, generates Swift/Kotlin stubs
@HostApi()
abstract class BiometricApi {
  bool authenticate(String reason);
}
```

---

### 9.4 FFI (Dart Foreign Function Interface)

FFI lets Dart call C/C++ functions directly, bypassing the platform channel serialization overhead entirely — no message encoding, no round-trip to the platform thread. Use it for performance-critical native code (image codecs, cryptography, ML inference runtimes) where the channel overhead would be prohibitive. The trade-off: FFI is more complex (you manage C memory and pointer types manually) and platform channel safety guarantees don't apply.

`DynamicLibrary.open` loads a native shared library; `lookupFunction` resolves a symbol by name and binds it to a Dart function type. The two type parameters are: `<NativeType, DartType>`.

```dart
final dylib = DynamicLibrary.open('libcrypto.so');
final sha256 = dylib.lookupFunction<Pointer Function(Pointer), Pointer Function(Pointer)>('SHA256');
```

---

### Module 9 — Quick fire answers

| Question | Answer |
|----------|--------|
| MethodChannel vs EventChannel? | Method: one-shot call. Event: continuous stream from native |
| What is Pigeon? | Code-gen for type-safe platform channels. Preferred over raw strings |
| What is a Flutter plugin? | A package that wraps native platform functionality for Dart consumption |

---

## Module 10: Security, Privacy & Compliance

> **Priority: HIGH.** Any app handling personal or sensitive user data must get this right.

---

### 10.1 Secure Storage

```dart
// flutter_secure_storage — uses Keychain (iOS) and EncryptedSharedPreferences (Android)
const storage = FlutterSecureStorage();

await storage.write(key: 'auth_token', value: token);
final token = await storage.read(key: 'auth_token');
await storage.delete(key: 'auth_token');

// NEVER use SharedPreferences for tokens or PII
```

---

### 10.2 Certificate Pinning

Prevents MITM attacks even if device has rogue CA:

```dart
// With dio + dio_pinning or http_certificate_pinning
(_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) {
    return _isValidCertificate(cert); // check SHA-256 fingerprint
  };
  return client;
};
```

---

### 10.3 Biometric Auth

```dart
// local_auth package
final auth = LocalAuthentication();
final didAuthenticate = await auth.authenticate(
  localizedReason: 'Authenticate to access your account',
  options: const AuthenticationOptions(biometricOnly: true),
);
```

---

### 10.4 What to Never Do

- Never log PII: no `debugPrint(user.email)` or `debugPrint(user.sensitiveField)`
- Never store tokens in plain SharedPreferences
- Never trust user input without validation
- Never hardcode API keys or secrets in Dart code (use `--dart-define` + CI secrets)
- Never disable SSL verification in production (`badCertificateCallback = true` is a red flag)

---

### 10.5 Regulatory Awareness (HIPAA, GDPR, etc.)

> "Mobile apps dealing with sensitive user data must encrypt data at rest and in transit, implement access controls, have audit logging, and support remote wipe. On iOS, OS-level data protection (`FileProtectionType.complete`) handles encryption at rest when the device is locked. On Android, we rely on EncryptedSharedPreferences and the Android Keystore. For regulated industries (healthcare = HIPAA, EU users = GDPR), these are legal requirements, not optional best practices."

---

### Module 10 — Quick fire answers

| Question | Answer |
|----------|--------|
| How do you store auth tokens? | `flutter_secure_storage` — never plain SharedPreferences |
| How do you prevent screenshot capture of sensitive screens? | `FlutterWindowManager` (Android) FLAG_SECURE; iOS prevents screenshots in secure text fields |
| What is jailbreak/root detection? | `flutter_jailbreak_detection` — warn users that their device security is compromised |

---

## Module 11: Accessibility

> **Priority: HIGH.** Users may have cognitive, visual, or physical disabilities — accessibility is a baseline requirement, not a bonus.

---

### 11.1 Semantics Widget

```dart
Semantics(
  label: 'Start session',
  hint: 'Double tap to begin',
  button: true,
  child: GestureDetector(
    onTap: _startSession,
    child: const SessionCard(),
  ),
)
```

Most built-in widgets (`ElevatedButton`, `Text`, `Image`) set semantics automatically.

---

### 11.2 Touch Target Size

Material spec: minimum 48×48 dp touch target.

```dart
// If the visual element is smaller, wrap it
SizedBox(
  width: 48,
  height: 48,
  child: IconButton(icon: const Icon(Icons.close), onPressed: _close),
)
// Or use: IconButton already provides 48dp minimum by default
```

---

### 11.3 Color Contrast

WCAG 2.1 AA: 4.5:1 contrast ratio for normal text, 3:1 for large text.

Check with: `Colors.white` on `Color(0xFF5C6BC0)` — use a contrast checker tool.

---

### 11.4 Text Scaling

```dart
// Respect user's font size preference — never hardcode textScaleFactor
// Test at 200% text scale — your layouts must not overflow
Text(
  'Hello',
  maxLines: 2,
  overflow: TextOverflow.ellipsis, // graceful degradation
)
```

---

### Module 11 — Quick fire answers

| Question | Answer |
|----------|--------|
| How to test accessibility? | TalkBack (Android) / VoiceOver (iOS). Also: `flutter_accessibility_service` in tests |
| What is `ExcludeSemantics`? | Removes a widget from the accessibility tree (decorative images) |
| What is `MergeSemantics`? | Merges child semantics into one node (e.g., icon + label as one button) |

---

## Module 12: CI/CD & Release Pipeline

> **Priority: MEDIUM.** Shows you think beyond feature code.

---

### 12.1 Typical Flutter CI Pipeline

```yaml
# GitHub Actions example
jobs:
  test:
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: dart format --check .
      - run: flutter analyze
      - run: flutter test --coverage
      - run: genhtml coverage/lcov.info -o coverage/html

  build-android:
    needs: test
    steps:
      - run: flutter build appbundle --release --dart-define=ENV=production

  build-ios:
    needs: test
    runs-on: macos-latest
    steps:
      - run: flutter build ipa --release --dart-define=ENV=production
```

---

### 12.2 Versioning

```yaml
# pubspec.yaml
version: 2.4.1+47
#        │   │
#        │   └── Build number (auto-incremented in CI)
#        └────── Semantic version shown to users
```

---

### 12.3 Flavors / Build Variants

```
flutter build apk --flavor development -t lib/main_dev.dart
flutter build apk --flavor production  -t lib/main_prod.dart
```

Different API URLs, app icons, bundle IDs per flavor.

---

### Module 12 — Quick fire answers

| Question | Answer |
|----------|--------|
| How to manage secrets in CI? | GitHub Secrets → `--dart-define` at build time. Never in repo |
| What is Fastlane? | Automation for signing, building, and publishing to App Store / Play Store |
| What is Shorebird? | Over-the-air (OTA) Dart code updates without app store resubmission |

---

## Module 13: Behavioral & System Design

> **Priority: CRITICAL.** At moderate difficulty, behavioral rounds carry significant weight.

---

### 13.1 STAR Format

Every behavioral answer: **Situation → Task → Action → Result**

Practice answers for:
- "Tell me about a time you made a technical decision you later regretted"
- "Describe a conflict with a teammate over architecture"
- "Tell me about a feature you're most proud of"
- "How do you handle technical debt?"
- "Tell me about a time you mentored a junior developer"

---

### 13.2 System Design: Real-Time Video Call Feature

If asked "Design a real-time video call feature in Flutter":

```
1. Transport layer
   - WebRTC for video (Agora SDK / Daily.co / Twilio)
   - WebSocket for signaling

2. State machine for call
   - idle → connecting → connected → ended
   - Bloc is ideal here (explicit states, auditable)

3. Privacy considerations
   - End-to-end encrypted media (WebRTC mandates DTLS-SRTP)
   - No recording without explicit consent
   - Session data never logged

4. Connection quality
   - Monitor RTT, packet loss via WebRTC stats API
   - Adaptive bitrate
   - Graceful degradation: video off → audio only

5. Accessibility
   - Closed captions option
   - High contrast mode
   - Large touch targets for mute/end call buttons
```

---

### 13.3 Questions to Ask the Interviewer

These show seniority:

- "What does the Flutter team's release cadence look like — how often do you ship?"
- "What's the biggest technical challenge the mobile team is facing right now?"
- "How do you handle feature flags and gradual rollouts?"
- "What does a code review culture look like on the mobile team?"
- "How is mobile testing integrated into the CI pipeline currently?"
- "How do you think about the boundary between mobile and backend responsibility?"

---

## Cheat Sheet: One-Liners to Have Ready

| Topic | One-liner |
|-------|-----------|
| Why Flutter? | "Single codebase, compiled to native ARM, 60/120fps via Skia/Impeller, hot reload for speed" |
| Dart vs JS async | "Dart's event loop is similar but has a microtask queue that runs before the event queue" |
| Widget vs Component | "Widgets are immutable descriptions. Elements are the mutable instances. RenderObjects do layout." |
| Why Riverpod over Provider? | "Compile-safe, no context required outside build, trivially overridable in tests" |
| Clean Architecture value | "Each layer can be tested in isolation and replaced without touching the others" |
| Sensitive data on mobile | "Encrypt at rest (Keychain/Keystore), enforce TLS in transit, no PII in logs" |
| Jank definition | "A frame taking > 16ms on the UI thread or raster thread, causing missed vsync" |

---

## Study Plan

**Day before / morning of the interview:**

1. **First session:** Re-read Modules 1, 2, 3 out loud. Say the answers, don't just read.
2. **Second session:** Module 4 (architecture) + Module 10 (security).
3. **30 min before:** Module 13 — prepare 3 STAR stories from real experience.
4. **During interview:** When you don't know something, say: *"I haven't used that specifically, but here's how I'd approach it..."* — never bluff.
