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

Riverpod was written by the same author as Provider (Remi Rousselet) specifically to fix Provider's fundamental limitations. Provider is built on top of `InheritedWidget` — which means it inherits all of InheritedWidget's constraints. Riverpod replaces InheritedWidget with its own global provider registry, solving those pain points at the root.

**Why Riverpod over Provider:**

| Provider problem | Riverpod solution |
|---|---|
| Needs `BuildContext` to read state — can't use in services or repositories | `ref.read(provider)` works anywhere, no context required |
| Runtime crash (`ProviderNotFoundException`) if provider missing from tree | Compile-time error — providers are global constants |
| No built-in async state (`loading` / `error` / `data`) | `AsyncValue<T>` is first-class: `.when(data, loading, error)` |
| Testing requires pumping a full widget tree | `ProviderContainer` with overrides — pure Dart, no widgets needed |
| Difficult to scope/dispose providers | `autoDispose` and `family` are built-in modifiers |

**Provider types — pick the right one:**

| Provider | Use when |
|---|---|
| `Provider` | Expose a constant value or service (e.g. `ApiClient`) |
| `StateProvider` | Simple, synchronous state with no business logic (e.g. a counter, a filter value) |
| `FutureProvider` | Expose the result of a one-time async call (e.g. initial config fetch) |
| `StreamProvider` | Expose a stream (e.g. Firebase auth state, WebSocket) |
| `NotifierProvider` | Synchronous state + methods (replaces `StateNotifierProvider`) |
| `AsyncNotifierProvider` | Async state + methods — most common for feature state |

**Declaration and usage examples for each provider type:**

```dart
// Provider — exposes a constant value or service, never changes
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// Usage: read in a notifier or widget; no rebuild triggered
final client = ref.read(apiClientProvider);


// StateProvider — simple synchronous state, no business logic
final counterProvider = StateProvider<int>((ref) => 0);

// Usage: ref.watch rebuilds widget; ref.notifier exposes the StateController
final count = ref.watch(counterProvider);           // int
ref.read(counterProvider.notifier).state++;         // mutate


// FutureProvider — wraps a one-time async call, exposes AsyncValue
final configProvider = FutureProvider<AppConfig>((ref) async {
  return ref.read(configServiceProvider).load();
});

// Usage: .when handles loading / error / data automatically
ref.watch(configProvider).when(
  data:    (cfg)  => Text(cfg.theme),
  loading: ()     => const CircularProgressIndicator(),
  error:   (e, _) => Text('$e'),
);


// StreamProvider — wraps a stream, exposes AsyncValue on every emission
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Usage: same .when API as FutureProvider
ref.watch(authStateProvider).when(
  data:    (user)  => user == null ? LoginPage() : HomePage(),
  loading: ()      => const SplashScreen(),
  error:   (e, _)  => Text('Auth error: $e'),
);


// NotifierProvider — synchronous state + methods (replaces StateNotifierProvider)
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;   // initial state

  void toggle() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}

// Usage
final mode = ref.watch(themeProvider);               // ThemeMode
ref.read(themeProvider.notifier).toggle();           // call method


// AsyncNotifierProvider — async state + methods, most common for feature state
final cartProvider = AsyncNotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

class CartNotifier extends AsyncNotifier<List<CartItem>> {
  @override
  Future<List<CartItem>> build() =>
      ref.read(cartRepositoryProvider).fetchCart();  // called once on first watch

  Future<void> addItem(Product p) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(cartRepositoryProvider).add(p),
    );
  }
}

// Usage
ref.watch(cartProvider).when(
  data:    (items) => CartList(items),
  loading: ()      => const CircularProgressIndicator(),
  error:   (e, _)  => Text('$e'),
);
```

```dart
// 1. Define a provider
final userProvider = AsyncNotifierProvider<UserNotifier, User>(() {
  return UserNotifier();
});

class UserNotifier extends AsyncNotifier<User> {
  @override
  // build() is called once on first watch — like initState for state
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

**`ref` — the three methods you must know:**

```dart
// ref.watch — subscribe: rebuilds widget when value changes. Only in build().
final user = ref.watch(userProvider);

// ref.read — one-shot read, no subscription. Use in callbacks and methods.
final repo = ref.read(userRepositoryProvider);

// ref.listen — react to changes without rebuilding. Use for side effects.
ref.listen(authProvider, (prev, next) {
  if (next is Unauthenticated) context.go('/login');
});
```

**Modifiers:**

**`family`** — by default a provider is a singleton. `family` turns it into a function: each unique argument gets its own cached instance. Think of it as a `Map<Arg, Provider>` managed automatically.

```dart
// Without family: one provider, one instance for the whole app.
// With family: one instance per id — each cached separately.
final userByIdProvider = FutureProvider.family<User, String>((ref, id) {
  return ref.read(repoProvider).getUser(id);
});

ref.watch(userByIdProvider('abc-123')); // own instance, cached
ref.watch(userByIdProvider('xyz-456')); // different instance, cached separately
```

**`autoDispose`** — normally a provider lives forever once created, even if nothing watches it. `autoDispose` destroys the provider (and its state) the moment the last watcher unmounts.

```dart
// Without autoDispose: every search string ever created stays in memory forever.
// With autoDispose: instance is disposed when you leave the screen.
final searchProvider = StateProvider.autoDispose<String>((ref) => '');
```

**Combining both** — the most common pattern for per-route data:

```dart
// Each route gets its own instance (family).
// When you navigate away, that instance cleans itself up (autoDispose).
// Navigate back → fresh fetch, no stale data.
final userByIdProvider = FutureProvider.autoDispose.family<User, String>((ref, id) {
  return ref.read(repoProvider).getUser(id);
});
```

---

### 3.5 Bloc / Cubit

Bloc implements the **unidirectional data flow** pattern strictly: UI dispatches `Events` → Bloc processes them and emits `States` → UI rebuilds. Everything goes through the event stream — you never call business logic directly from a button handler.

**Cubit** is Bloc without the event layer. You call methods directly on the Cubit (like a Riverpod Notifier), and it emits states. Use Cubit when state transitions are straightforward; use Bloc when you need auditability, replay, or the ability to log/test every discrete event.

```dart
// Cubit: method calls → state emissions
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

// Bloc: events → states (each transition is explicit and traceable)
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepo) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepo.login(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
```

**Consuming Bloc in the UI:**

```dart
// BlocBuilder — rebuilds on every new state
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    return switch (state) {
      AuthLoading()        => const CircularProgressIndicator(),
      AuthAuthenticated(user: final u) => HomeScreen(user: u),
      AuthError(message: final m)      => Text(m),
      _                    => const LoginScreen(),
    };
  },
)

// BlocListener — side effects only, no rebuild (navigation, snackbars)
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthAuthenticated) context.go('/home');
  },
  child: const LoginForm(),
)

// BlocConsumer — both (use sparingly; split into Builder + Listener if possible)
```

**When to use Bloc over Cubit?**
> When state transitions need to be **auditable** (logged, replayed, or tested as a sequence of events). Bloc's event objects are serialisable — you can record every user action and replay them deterministically, which is invaluable for bug reports and analytics.

---

### 3.6 Riverpod vs Provider vs Bloc — The Decision Table

| Dimension | Provider | Riverpod | Bloc |
|---|---|---|---|
| **Context required?** | Yes — `context.read/watch` | No — `ref` works anywhere | No — events dispatched via `add()` |
| **Async state built-in?** | No — manual handling | Yes — `AsyncValue<T>` | No — manual `Loading/Error/Data` states |
| **DI container?** | Yes (via tree) | Yes (global registry) | No — needs get_it or Riverpod alongside |
| **Testability** | Needs widget tree | `ProviderContainer` alone | `bloc_test` package; no widgets needed |
| **Compile safety** | Runtime errors | Compile-time errors | Compile-time (typed events/states) |
| **Learning curve** | Low | Medium | Medium-High |
| **Best for** | Simple apps, legacy | Modern apps, any scale | Complex flows, event sourcing, auditability |

**The mental model:**
- **Provider** = `InheritedWidget` with ergonomics. Good start, hits limits fast.
- **Riverpod** = Provider reimagined. State management **and** DI container. Default choice.
- **Bloc** = strict event machine. More boilerplate, but every state transition is traceable. Ideal when the product team or compliance needs an audit trail (payments, auth, medical).

---

### 3.7 How to answer "Which state management do you use?"

> "I evaluate based on three things: **scope** (is this local or global state?), **team familiarity**, and **testability requirements**. For local UI state I use `setState` or `ValueNotifier`. For feature-level shared state I reach for **Riverpod** — it's compile-safe, doesn't need a `BuildContext` in business logic, handles async state out of the box, and doubles as a DI container so I don't need a separate `get_it` setup. For teams already on Bloc I'm comfortable there too — the explicitness of events is genuinely valuable in complex, auditable flows like auth or payments. I'd only reach for plain Provider in a legacy codebase where a migration isn't justified."

---

### Module 3 — Quick fire answers

| Question | Answer |
|----------|--------|
| What is `ChangeNotifier`? | Base class that notifies listeners on `notifyListeners()`. Foundation of Provider; Riverpod's `Notifier` replaces it |
| Provider vs Riverpod? | Riverpod: no context in logic, compile-safe, `AsyncValue` built-in, `ProviderContainer` for tests, better scoping |
| Cubit vs Bloc? | Cubit: direct method calls, simpler. Bloc: event objects, fully serialisable state machine, better for audit trails |
| Can Bloc replace Riverpod? | For state yes, but not for DI — Bloc has `BlocProvider` but it only injects Blocs into the widget tree; repositories, services, and other dependencies still need `get_it`. Riverpod covers both with the same system. They can coexist |
| What is `BlocBuilder` vs `BlocListener`? | Builder: rebuilds UI on state change. Listener: one-time side effects only (navigation, snackbars) |
| What is `ref.watch` vs `ref.read`? | `watch`: subscribes, widget rebuilds on change — use in `build()`. `read`: one-shot, no subscription — use in callbacks |

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

Dependency Injection (DI) is the practice of providing a class's dependencies from outside rather than letting it create them internally. Without DI, a `LoginViewModel` that creates its own `AuthRepository` is tightly coupled to the concrete implementation — you can't swap it for a fake in tests without modifying the class. With DI, the class declares what it needs (via constructor or interface), and something external wires the real or fake implementation in.

**Why it matters:**
- **Testability** — swap real HTTP clients for in-memory fakes without changing business logic
- **Replaceability** — change `FirebaseAuthRepository` to `SupabaseAuthRepository` in one place
- **Separation of concerns** — classes don't know how their dependencies are constructed

**Service locator vs true DI:**

A service locator (`get_it`) is a global registry — classes pull their dependencies out of it. It works but it's technically an inversion of control, not strict DI (dependencies aren't pushed in via constructor). True constructor injection makes dependencies explicit and visible in the class signature.

```dart
// Bad — hard-coded dependency, untestable
class LoginViewModel {
  final _repo = AuthRepositoryImpl(Dio()); // tightly coupled
}

// Good — dependency injected via constructor
class LoginViewModel {
  LoginViewModel(this._repo);
  final AuthRepository _repo; // depends on abstraction, not implementation
}
```

**Approach 1: `get_it` + `injectable`**

`get_it` is a service locator. `injectable` adds code generation to eliminate manual registration boilerplate. Annotate classes, run `build_runner`, call `configureDependencies()` at startup.

```dart
// Annotate your module and classes
@module
abstract class NetworkModule {
  @singleton
  Dio get dio => Dio(BaseOptions(baseUrl: Env.apiUrl));
}

@singleton
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dio);  // get_it resolves Dio automatically
  final Dio _dio;
}

// main.dart — one-time setup
await configureDependencies();

// Anywhere in the app — pull from the registry
final repo = getIt<AuthRepository>();
```

Scopes:
- `@singleton` — one instance for the app lifetime
- `@lazySingleton` — created on first access, not at startup
- `@injectable` — new instance every time it's resolved

**Approach 2: Riverpod as DI**

With Riverpod, providers ARE the DI container. No separate setup, no global registry to configure. The dependency graph is expressed as provider references — Riverpod resolves and caches them automatically.

```dart
// Infrastructure layer
final dioProvider = Provider<Dio>((ref) => Dio(BaseOptions(baseUrl: Env.apiUrl)));

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(dioProvider)); // Riverpod wires the graph
});

// Feature layer — no knowledge of how AuthRepository is built
final loginProvider = NotifierProvider<LoginNotifier, LoginState>(LoginNotifier.new);

class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() => LoginInitial();

  Future<void> login(String email, String password) async {
    final repo = ref.read(authRepositoryProvider); // resolved from graph
    // ...
  }
}
```

**Testing with Riverpod** — override any provider in the graph without touching the class:

```dart
final container = ProviderContainer(
  overrides: [
    authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
  ],
);
final notifier = container.read(loginProvider.notifier);
await notifier.login('a@b.com', '123');
```

**Approach 3: `get_it` + Riverpod together**

Common in large codebases migrating incrementally. `get_it` handles infrastructure (Dio, SharedPreferences, third-party SDKs). Riverpod handles feature-level state and business logic. A thin bridge connects them:

```dart
final authRepositoryProvider = Provider<AuthRepository>(
  (_) => getIt<AuthRepository>(), // bridge: pull from get_it into Riverpod
);
```

**Comparison:**

| | `get_it` | Riverpod |
|---|---|---|
| Setup | `configureDependencies()` at startup | Zero setup — providers are top-level constants |
| Resolving | `getIt<T>()` anywhere | `ref.read(provider)` — only where `ref` is available |
| Test overrides | `getIt.unregister` + re-register | `ProviderContainer(overrides: [...])` — clean and scoped |
| Lazy loading | `@lazySingleton` | `autoDispose` |
| Scoping | Named scopes (manual) | `autoDispose` + `family` |
| Async init | `getIt.isReady<T>()` | `FutureProvider` |

In greenfield Flutter projects, Riverpod alone is sufficient. `get_it` is worth adding when you have platform-channel dependencies that must be initialised before `runApp` (e.g. `FlutterLocalNotificationsPlugin`), or when integrating with non-Flutter Dart packages that have no `ref` access.

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

A `Future<T>` represents a computation that will produce a value (or error) at some point. It has three states: uncompleted, completed with data, completed with error. `async/await` is syntactic sugar over `.then`/`.catchError` chaining — it makes async code read linearly, but the execution model is unchanged underneath.

**Critical mental model:** Dart is single-threaded. `await` does not block the thread — it suspends the current function, returns control to the event loop, and resumes when the Future completes. This is why the UI stays responsive during `await`: other events (touches, renders) can run in between.

```dart
Future<User> getUser(String id) async {
  final response = await http.get(Uri.parse('/users/$id'));
  if (response.statusCode != 200) throw ServerException(response.statusCode);
  return User.fromJson(jsonDecode(response.body));
}

// Typed error handling — catch specific exceptions before the general catch
try {
  final user = await getUser('123');
} on ServerException catch (e) {
  log('Server error: ${e.statusCode}');
} on SocketException {
  log('No internet');
} catch (e, stackTrace) {
  // Unexpected — log fully
  FirebaseCrashlytics.instance.recordError(e, stackTrace);
}
```

**Parallel execution** — `await` in sequence means each call waits for the previous to finish. Use records + `.wait` to run independent Futures concurrently:

```dart
// Sequential — total time = A + B
final user   = await getUser(id);
final config = await getAppConfig();

// Parallel — total time = max(A, B)
final (user, config) = await (getUser(id), getAppConfig()).wait;
```

**Completer** — manually control when a Future completes. Useful for bridging callback-based APIs into async/await:

```dart
Future<String> waitForBluetooth() {
  final completer = Completer<String>();
  bluetoothDevice.onConnect = (deviceId) => completer.complete(deviceId);
  bluetoothDevice.onError   = (e)        => completer.completeError(e);
  return completer.future;
}
```

**`unawaited`** — explicitly fire-and-forget a Future. Without it, Dart tools warn you about unawaited Futures (which silently swallow errors):

```dart
unawaited(analyticsService.logEvent('screen_view')); // intentional, no need to await
```

---

### 5.2 Streams

A `Stream<T>` is an asynchronous sequence of values — like an async `Iterable`. A `Future` gives you one value and completes; a Stream gives you zero, one, or many values over time and may or may not terminate. Real-world examples: Firebase auth state, WebSocket messages, location updates, file reads.

**Single-subscription vs Broadcast:**

| | Single-subscription | Broadcast |
|---|---|---|
| Listeners | One at a time | Many simultaneously |
| Buffering | Buffers until listener attaches | No buffering — late listeners miss past events |
| Use for | File reads, HTTP response body | Auth state, event buses, sensor data |

```dart
// Single-subscription — only one listener allowed
final fileStream = File('data.csv').openRead();

// Broadcast — multiple widgets can listen simultaneously
final authController = StreamController<AuthState>.broadcast();
authController.add(AuthState.authenticated);
authController.stream.listen((s) => debugPrint('Widget A: $s'));
authController.stream.listen((s) => debugPrint('Widget B: $s'));
```

**Stream operators** — composable, chainable transformations:

```dart
Stream.fromIterable([1, 2, 3, 4, 5, 6])
  .where((n) => n.isEven)   // filter: 2, 4, 6
  .map((n) => n * 10)       // transform: 20, 40, 60
  .take(2)                  // limit: 20, 40
  .listen(print);
```

**`async*` generator** — produce a stream lazily with `yield`. Each `yield` emits one value; `yield*` delegates to another stream or iterable:

```dart
Stream<int> countdown(int from) async* {
  for (var i = from; i >= 0; i--) {
    yield i;                                          // emit one value
    await Future.delayed(const Duration(seconds: 1)); // pause between emissions
  }
}

// yield* — emit everything from another stream/iterable
Stream<int> merged(Stream<int> a, Stream<int> b) async* {
  yield* a; // all of a, then all of b
  yield* b;
}
```

**Managing subscriptions manually** — if you call `stream.listen()` outside a `StreamBuilder`, you must cancel it or you leak it:

```dart
class _MyWidgetState extends State<MyWidget> {
  late final StreamSubscription<AuthState> _sub;

  @override
  void initState() {
    super.initState();
    _sub = authRepo.authStateChanges.listen((state) {
      if (state is Unauthenticated) context.go('/login');
    });
  }

  @override
  void dispose() {
    _sub.cancel(); // ALWAYS cancel or you leak the listener
    super.dispose();
  }
}
```

**`StreamBuilder`** handles the subscription lifecycle automatically — subscribes on insert, cancels on remove, rebuilds on every event:

```dart
StreamBuilder<User?>(
  stream: authRepository.authStateChanges,
  builder: (context, snapshot) {
    return switch (snapshot.connectionState) {
      ConnectionState.waiting => const SplashScreen(),
      ConnectionState.active  => snapshot.hasData
          ? HomeScreen(user: snapshot.data!)
          : const LoginScreen(),
      _                       => const LoginScreen(),
    };
  },
)
```

**`StreamController` pitfalls:**
- Forgetting `close()` leaks the controller
- Adding to a closed controller throws a `StateError`
- Adding a second listener to a single-subscription stream throws — use `.broadcast()` if you need multiple listeners

---

### 5.3 Isolates

Dart runs on a single thread — every widget build, animation frame, gesture, and async callback runs on that same thread. If you do heavy CPU work on the main thread, you block the event loop: Flutter can't produce frames while it's blocked → jank.

**Isolates are true parallel threads** with completely separate memory heaps. They don't share objects — they communicate by passing messages through `SendPort`/`ReceivePort`. Messages are copied (primitives, standard types) or transferred with zero-copy (via `TransferableTypedData`).

**`Isolate.run`** — the simplest API (Dart 2.19+). Spawns an isolate, runs the closure, returns the result, exits:

```dart
// UI stays responsive — heavy work runs in parallel
final items = await Isolate.run(() {
  final raw = jsonDecode(heavyJsonString) as List;
  return raw.map(Item.fromJson).toList();
});
```

**`compute`** — Flutter's thin wrapper around `Isolate.run`. Only accepts top-level or static functions with a single argument:

```dart
final items = await compute(parseHeavyJson, rawJsonString);

// Must be top-level or static — closures capturing outer context don't work
List<Item> parseHeavyJson(String json) =>
    (jsonDecode(json) as List).map(Item.fromJson).toList();
```

**Long-running isolate with bidirectional communication** — when you need an isolate that stays alive and processes multiple requests (e.g. background image processing, ongoing ML inference):

```dart
void main() async {
  final receivePort = ReceivePort();
  await Isolate.spawn(_workerIsolate, receivePort.sendPort);

  final sendPort = await receivePort.first as SendPort;

  final responsePort = ReceivePort();
  sendPort.send(['process', largeData, responsePort.sendPort]);
  final result = await responsePort.first;
}

void _workerIsolate(SendPort mainSendPort) {
  final port = ReceivePort();
  mainSendPort.send(port.sendPort); // hand back our SendPort

  port.listen((message) {
    final [task, data, SendPort replyTo] = message as List;
    replyTo.send(_heavyProcess(data));
  });
}
```

**`TransferableTypedData`** — normally, sending a message between isolates **copies** the data. For a 10 MB image buffer, that means 10 MB gets duplicated in memory during the transfer. `TransferableTypedData` avoids the copy by transferring **ownership** of the underlying memory buffer instead: the receiving isolate gets it, the sending isolate's reference becomes invalid. Think of it as moving a file rather than duplicating it.

```dart
// Without TransferableTypedData: imageBytes is COPIED — both isolates
// briefly hold the full buffer in memory simultaneously
sendPort.send(imageBytes);

// With TransferableTypedData: ownership is MOVED — no duplication at all
final transferable = TransferableTypedData.fromList([imageBytes]);
sendPort.send(transferable);
// imageBytes is now invalid — accessing it after this point throws

// Receiving isolate: materialise back into a typed list
port.listen((message) {
  final bytes = (message as TransferableTypedData).materialize().asUint8List();
  // bytes points to the original buffer — no copy happened
});
```

Use it when passing large `Uint8List` buffers (camera frames, audio samples, decoded images) to a worker isolate and you don't need the original anymore.

**When to use isolates:**

| Scenario | Approach |
|---|---|
| One-off JSON parsing > ~1 MB | `Isolate.run` or `compute` |
| Image decoding / pixel manipulation | `Isolate.run` |
| Encryption / hashing | `Isolate.run` |
| Ongoing background work (audio, ML) | Long-lived isolate with ports |
| Network calls, DB queries | Plain `async/await` — already non-blocking, no isolate needed |

> Common mistake: using isolates for I/O. Network and disk I/O are already async and non-blocking — the OS handles them. `await` is sufficient. Isolates only help with CPU-bound work.

---

### 5.4 Event Loop

Understanding the event loop is the foundation for explaining why `await` doesn't block the UI, what order callbacks run in, and why `Future.microtask` behaves differently from `Future`.

```
Main Isolate
  ├── Microtask Queue  (highest priority)
  │     └── Future.microtask, scheduleMicrotask, .then/.whenComplete callbacks
  └── Event Queue  (lower priority)
        └── Timer, I/O callbacks, user input, platform messages, new Futures
```

**Execution order:**
1. Run all synchronous code until the call stack is empty
2. Drain the entire microtask queue (every pending microtask runs before moving on)
3. Take one event from the event queue and run its callback
4. Repeat from step 2

```dart
void main() {
  print('1'); // sync — runs immediately, call stack not empty yet

  Future(() => print('5'));
  // Schedules a new event in the event queue — will run after sync code
  // and after ALL microtasks are drained

  Future.microtask(() => print('3'));
  // Schedules in the microtask queue — higher priority than event queue,
  // runs before any event queue callbacks

  scheduleMicrotask(() => print('4'));
  // Also microtask queue — queued after the Future.microtask above,
  // so it runs second among microtasks

  print('2'); // sync — still in the synchronous block, runs before any async callbacks
}
// Output: 1, 2, 3, 4, 5
//
// Step-by-step:
//   print('1')              → sync, runs now
//   Future(...)             → enqueues a callback in the event queue
//   Future.microtask(...)   → enqueues a callback in the microtask queue
//   scheduleMicrotask(...)  → enqueues a second callback in the microtask queue
//   print('2')              → sync, still in main(), runs now
//   --- call stack empty ---
//   Drain microtask queue:
//     print('3')            → first microtask
//     print('4')            → second microtask
//   Microtask queue empty — take next event:
//     print('5')            → event queue callback runs last
```

**Why this matters in practice:**

```dart
// A tight loop blocks the event loop entirely — no frames, no touches
for (var i = 0; i < 1_000_000; i++) { heavyCompute(i); }

// Yielding to the event queue each iteration lets renders happen between steps
// — but it's slow; use an isolate for truly heavy CPU work
for (var i = 0; i < 1000; i++) {
  await Future(() => heavyCompute(i)); // each iteration goes through the event queue
}
```

**Microtask starvation** — microtasks have higher priority than events. If a microtask schedules another microtask, and that one schedules another, the event queue never runs — the UI freezes. Never use `scheduleMicrotask` for work that should yield to rendering.

---

### Module 5 — Quick fire answers

| Question | Answer |
|----------|--------|
| `async` vs `async*`? | `async` returns a `Future`; `async*` returns a `Stream` |
| `yield` vs `yield*`? | `yield` emits one value; `yield*` delegates to another stream or iterable, emitting all its values |
| Does `await` block the thread? | No — it suspends the current function and returns control to the event loop |
| Can two isolates share memory? | No — separate heaps; communicate only via message passing (SendPort/ReceivePort) |
| `Isolate.run` vs `compute`? | `Isolate.run` accepts any closure; `compute` only accepts top-level/static functions with a single argument |
| Single-subscription vs broadcast stream? | Single: one listener, buffers events. Broadcast: many listeners, no buffering — late listeners miss past events |
| What is `unawaited`? | Marks a Future as intentionally fire-and-forget — suppresses the unawaited-future lint warning |
| What fills the microtask queue? | `.then`/`.whenComplete` callbacks and explicit `Future.microtask`/`scheduleMicrotask` calls |
| When would you use a `Completer`? | To wrap a callback-based API into a Future — complete it manually when the callback fires |
| Why avoid isolates for I/O? | I/O is handled by the OS asynchronously — `await` is enough. Isolates only help with CPU-bound work |

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

Flutter rebuilds a widget when its parent rebuilds and passes different arguments — or when `setState`, a `ChangeNotifier`, or a Riverpod provider it watches changes. The rebuild itself is cheap; the problem is when it causes heavy layout/paint work or propagates unnecessarily far down the tree.

**`const` constructors** — Flutter short-circuits the rebuild entirely for `const` widgets. The element is preserved and `build()` is never called again. This is the single highest-return optimization.

```dart
// BAD: new closure instance every build → Flutter sees a new widget → rebuilds child
Widget build(BuildContext context) {
  return MyButton(onTap: () => doSomething()); // new lambda each time
}

// GOOD: const — widget is identical every build, no rebuild ever
Widget build(BuildContext context) {
  return const MyButton(); // Flutter reuses the element
}

// GOOD: store callbacks in state so the reference is stable
class _MyState extends State<MyWidget> {
  late final VoidCallback _onTap = () => doSomething();

  @override
  Widget build(BuildContext context) {
    return MyButton(onTap: _onTap); // same reference, no unnecessary rebuild
  }
}
```

**Split large `build` methods** — a single `build()` that returns 200 lines of widget tree means the whole tree rebuilds whenever any dependency changes. Extract subtrees into separate `StatelessWidget` or `ConsumerWidget` classes — Flutter then only rebuilds the subtree that actually depends on changed state.

**Riverpod `select`** — watch only the field you need, not the whole object:

```dart
// Rebuilds whenever the entire User object changes (any field)
final user = ref.watch(userProvider);

// Rebuilds only when user.name changes — other field changes are ignored
final name = ref.watch(userProvider.select((u) => u.name));
```

**`ValueListenableBuilder`** — rebuilds only its own subtree, not the parent:

```dart
ValueListenableBuilder<int>(
  valueListenable: _counter,   // ValueNotifier<int>
  builder: (context, value, child) {
    return Text('$value');     // only this Text rebuilds on change
  },
)
```

**`AnimatedBuilder`** — the canonical way to limit animation rebuilds to the animated subtree. Pass a static `child` for the parts that don't animate:

```dart
AnimatedBuilder(
  animation: _animationController,
  child: const HeavyStaticWidget(), // built once, passed through
  builder: (context, child) {
    return Transform.scale(
      scale: _animation.value,
      child: child,           // reuses the pre-built static widget
    );
  },
)
```

---

### 7.2 List Performance

`ListView` without a builder creates all child widgets immediately, including those far off-screen. For any list longer than ~20 items, use `ListView.builder` — it creates only the items currently in the viewport plus a small cache zone.

```dart
// BAD — builds everything upfront, O(n) memory regardless of scroll position
ListView(children: items.map((i) => ItemCard(i)).toList())

// GOOD — lazily builds as user scrolls, O(visible) memory
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemCard(items[index]),
)

// itemExtent — when items have equal height, Flutter skips per-item layout math
// and calculates positions directly. Significant speedup for long lists.
ListView.builder(
  itemExtent: 72.0,
  itemCount: items.length,
  itemBuilder: (_, i) => ItemTile(items[i]),
)

// ListView.separated — adds dividers without wrapping each item
ListView.separated(
  itemCount: items.length,
  separatorBuilder: (_, __) => const Divider(),
  itemBuilder: (_, i) => ItemTile(items[i]),
)
```

**Slivers** — the low-level primitive behind all scrollable widgets. Use `CustomScrollView` when you need to mix a pinned header, a grid, and a list in a single scroll:

```dart
CustomScrollView(
  slivers: [
    const SliverAppBar(pinned: true, title: Text('Feed')),
    SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (_, i) => GridTile(item: featured[i]),
        childCount: featured.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
    ),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => ItemTile(items[i]),
        childCount: items.length,
      ),
    ),
  ],
)
```

**`SliverPrototypeExtentList`** — like `itemExtent` but measures extent from a prototype widget instead of a hardcoded number. Useful when you can't hardcode the height but it's uniform:

```dart
SliverPrototypeExtentList(
  prototypeItem: const ItemTile(item: Item.empty()), // measured once
  delegate: SliverChildBuilderDelegate(
    (_, i) => ItemTile(item: items[i]),
    childCount: items.length,
  ),
)
```

**`keepAlive`** — by default, scrolled-off pages in a `PageView` or `TabBarView` are destroyed. Mark a state with `AutomaticKeepAliveClientMixin` to preserve it:

```dart
class _FeedState extends State<FeedScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // required
    return ListView.builder(/* ... */);
  }
}
```

---

### 7.3 RepaintBoundary

Every widget that changes state potentially triggers a repaint up the render tree. `RepaintBoundary` creates a new compositing layer — its subtree repaints independently of its ancestors and siblings.

Use it when:
- A subtree animates continuously (e.g. a ticker, a particle effect) and the rest of the screen is static
- A subtree changes frequently while expensive ancestors remain stable

Avoid overuse — each boundary creates an additional GPU layer. Too many layers (>10–15 on most devices) causes raster thread pressure and can *hurt* performance more than it helps. Profile before adding.

```dart
// Without RepaintBoundary: every animation frame repaints the entire screen
// With RepaintBoundary: only the AnimatedCounter layer is repainted
RepaintBoundary(
  child: AnimatedCounter(value: _count),
)

// Complex particle effect on a static screen — isolate it
RepaintBoundary(
  child: ParticleField(),
)
```

**How to check if boundaries are helping:** in DevTools → Performance → Timeline, look at "Raster" frame times. Enable "Show repaint rainbow" in the Flutter inspector — areas that repaint show a cycling color border. If the entire screen is cycling, you likely need a boundary somewhere.

---

### 7.4 Image Optimization

Images are one of the most common sources of memory pressure and jank in Flutter apps.

```dart
// Decode at display size, not full resolution
// A 4K image decoded at full res for a 50x50 avatar wastes ~50MB of texture memory
Image.network(
  url,
  width: 50,
  height: 50,
  cacheWidth: 100,   // decode at 2× display size for retina; the image cache stores this smaller version
  cacheHeight: 100,
)

// cached_network_image — memory + disk cache, placeholder and error widgets
CachedNetworkImage(
  imageUrl: url,
  placeholder: (_, __) => const CircularProgressIndicator(),
  errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
  memCacheWidth: 100,
)

// Preload images before the screen opens — eliminates the loading flash
await precacheImage(NetworkImage(url), context);
```

**`ResizeImage`** — explicitly decode at a smaller resolution directly from the image provider, useful when you control the provider:

```dart
Image(
  image: ResizeImage(
    NetworkImage(url),
    width: 100,
    height: 100,
  ),
)
```

**Format and compression:**
- Prefer WebP over PNG/JPEG for assets — smaller file, lossless or lossy
- Use SVG (via `flutter_svg`) for icons and illustrations — resolution-independent, no memory scaling cost
- For local assets, declare `2.0x` / `3.0x` variants so Flutter picks the right resolution per device

---

### 7.5 DevTools Profiling

Flutter DevTools is the primary tool for diagnosing performance issues. Run with `flutter run --profile` (not debug — debug mode disables optimisations and is not representative).

**Performance overlay** — two bars in the top-right corner:
- Upper bar: UI thread (Dart). If this exceeds 16ms, your Dart code is the bottleneck.
- Lower bar: Raster thread (GPU/compositor). If this exceeds 16ms, you have compositing issues (too many layers, complex shaders).
- Green = fine. Yellow = approaching budget. Red = janky frame.

**Widget Inspector → Track rebuilds** — shows a rebuild counter per widget. Any counter that climbs rapidly while scrolling or animating is a rebuild optimisation target.

**CPU profiler** — flame chart of Dart call stacks sampled during a recording. Look for wide blocks (long time spent) in your own code vs framework code. Good for finding synchronous work that should be in an isolate.

**Memory tab** — shows heap usage over time. A continuously rising heap with no drops = memory leak. Common causes: stream subscriptions never cancelled, image cache not bounded, listeners not removed in `dispose`.

**Timeline events** — individual frame breakdown. Each frame shows: Animate → Build → Layout → Paint → Composite. If "Build" is wide, you have rebuild issues. If "Paint" is wide, you have RepaintBoundary or overdraw issues.

**Enabling additional diagnostics in code:**

```dart
// In main() or a debug flag — logs every widget build to the console
debugProfileBuildsEnabled = true;

// Highlights overdraw (painting the same pixel multiple times)
debugRepaintRainbowEnabled = true;

// Logs every layout pass
debugPrintLayouts = true;
```

---

### 7.6 Shader Compilation Jank

On first run, Flutter must compile GLSL shaders to GPU machine code at runtime. This causes one-time jank (dropped frames) the first time certain animations or widgets render — visible as a stutter on first scroll or transition.

**SkSL shader warmup** — capture shaders during a profile run, bundle them with the app, and pre-compile at startup:

```bash
# Record shaders during a profile run on a device
flutter run --profile --cache-sksl --purge-persistent-cache

# Interact with the app to exercise all animations, then press 'M' to save
# The shaders are saved to flutter_01.sksl.json

# Bundle on build
flutter build apk --bundle-sksl-path flutter_01.sksl.json
```

Impeller (the new Flutter rendering backend, default on iOS since Flutter 3.10, Android since 3.16) eliminates shader compilation jank entirely by pre-compiling shaders at engine build time. On targets running Impeller, SkSL warmup is unnecessary.

---

### Module 7 — Quick fire answers

| Question | Answer |
|----------|--------|
| What causes jank? | Work on the UI thread > 16ms per frame: heavy sync computation, excessive rebuilds, large images decoded at full resolution, shader compilation |
| What is the raster thread? | The GPU compositor thread. Blocked by too many layers, complex shaders, or overdraw |
| How do you find unnecessary rebuilds? | Widget Inspector → "Track widget build counts"; or `debugProfileBuildsEnabled = true` |
| What is a Sliver? | Low-level lazy scroll primitive. All Flutter scrollable widgets are built on Slivers |
| When does `const` help performance? | When the widget is `const`, Flutter skips `build()` on rebuild — the element is reused entirely |
| When to use `RepaintBoundary`? | When a subtree repaints frequently (animations) while the rest is stable. Avoid overuse — each boundary is a GPU layer |
| What is Impeller? | Flutter's new rendering backend. Pre-compiles shaders at engine build time, eliminating shader compilation jank. Default on iOS (3.10+) and Android (3.16+) |
| How do you limit Riverpod rebuilds? | `ref.watch(provider.select((s) => s.field))` — only rebuilds when that specific field changes |

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

`MethodChannel` is for one-shot calls: Dart invokes a method, waits for a single response. Think of it as an async RPC between Dart and the native layer. The channel name is a namespace string — by convention `com.company.app/feature`.

**Threading model:** MethodChannel handlers are always called on the platform's main thread (UI thread on Android, main thread on iOS). Never do blocking work there — dispatch to a background thread for anything slow.

```dart
// Dart side
const _channel = MethodChannel('com.myapp/biometric');

Future<bool> authenticate(String reason) async {
  try {
    return await _channel.invokeMethod<bool>('authenticate', {'reason': reason}) ?? false;
  } on PlatformException catch (e) {
    // Native threw — e.code and e.message are set by the native handler
    throw AuthException(e.message ?? 'Authentication failed');
  }
}
```

```swift
// iOS — AppDelegate.swift or a FlutterPlugin
let channel = FlutterMethodChannel(
  name: "com.myapp/biometric",
  binaryMessenger: controller.binaryMessenger
)

channel.setMethodCallHandler { call, result in
  guard call.method == "authenticate" else {
    result(FlutterMethodNotImplemented)
    return
  }
  let reason = (call.arguments as? [String: Any])?["reason"] as? String ?? "Authenticate"
  LAContext().evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
    DispatchQueue.main.async {
      success ? result(true) : result(FlutterError(code: "AUTH_FAILED", message: error?.localizedDescription, details: nil))
    }
  }
}
```

```kotlin
// Android — MainActivity.kt
MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.myapp/biometric")
  .setMethodCallHandler { call, result ->
    if (call.method == "authenticate") {
      val reason = call.argument<String>("reason") ?: "Authenticate"
      // BiometricPrompt setup ...
      result.success(true)
    } else {
      result.notImplemented()
    }
  }
```

---

### 9.2 EventChannel

Use `EventChannel` when native code needs to push a **continuous stream of events** to Dart — sensor readings, Bluetooth scans, connectivity changes, location updates. Unlike `MethodChannel` (one request → one response), `EventChannel` establishes a persistent subscription: native calls `eventSink.success(data)` on each event, and Dart receives each as a stream emission.

```dart
// Dart side
const _channel = EventChannel('com.myapp/accelerometer');

Stream<AccelerometerData> get accelerometerStream =>
    _channel
        .receiveBroadcastStream()
        .map((e) => AccelerometerData.fromMap(Map<String, double>.from(e)));
```

```swift
// iOS — StreamHandler
class AccelerometerStreamHandler: NSObject, FlutterStreamHandler {
  private let motionManager = CMMotionManager()

  func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
    motionManager.accelerometerUpdateInterval = 0.1
    motionManager.startAccelerometerUpdates(to: .main) { data, _ in
      guard let data = data else { return }
      eventSink(["x": data.acceleration.x, "y": data.acceleration.y, "z": data.acceleration.z])
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    motionManager.stopAccelerometerUpdates() // ALWAYS stop when unsubscribed
    return nil
  }
}

// Register
FlutterEventChannel(name: "com.myapp/accelerometer", binaryMessenger: controller.binaryMessenger)
  .setStreamHandler(AccelerometerStreamHandler())
```

Key points:
- `onCancel` is called when Dart cancels the stream subscription — always release native resources there
- The `eventSink` must only be called on the main thread; wrap background callbacks with `DispatchQueue.main.async`
- `eventSink(FlutterError(...))` sends an error event; `eventSink(FlutterEndOfEventStream)` closes the stream

---

### 9.3 Pigeon (Recommended for new code)

Raw platform channels use string method names and untyped `dynamic` arguments — a typo in the method name causes a runtime crash, and mismatched argument types are invisible until runtime. Pigeon generates type-safe Dart, Swift, and Kotlin code from a single Dart definition, so mismatches are compile-time errors.

**Define the API once in Dart:**

```dart
// pigeons/biometric.dart
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/platform/biometric.g.dart',
  swiftOut: 'ios/Runner/Biometric.g.swift',
  kotlinOut: 'android/app/src/main/kotlin/com/myapp/Biometric.g.kt',
))

class AuthRequest {
  AuthRequest({required this.reason});
  String reason;
}

class AuthResult {
  AuthResult({required this.success, this.errorMessage});
  bool success;
  String? errorMessage;
}

@HostApi()  // native implements this, Dart calls it
abstract class BiometricHostApi {
  @async
  AuthResult authenticate(AuthRequest request);
}

@FlutterApi()  // Dart implements this, native calls it
abstract class BiometricFlutterApi {
  void onAuthStateChanged(bool isAuthenticated);
}
```

```bash
dart run pigeon --input pigeons/biometric.dart
```

**Generated usage — fully typed, no strings:**

```dart
// Dart call site — no strings, no dynamic, compile-time safe
final api = BiometricHostApi();
final result = await api.authenticate(AuthRequest(reason: 'Access your account'));
if (!result.success) showError(result.errorMessage);
```

```swift
// Swift — implement the generated protocol
class BiometricApiImpl: BiometricHostApi {
  func authenticate(request: AuthRequest, completion: @escaping (AuthResult) -> Void) {
    // typed — AuthRequest and AuthResult are generated Swift classes
    completion(AuthResult(success: true, errorMessage: nil))
  }
}

// Register
BiometricHostApiSetup.setUp(binaryMessenger: controller.binaryMessenger, api: BiometricApiImpl())
```

**When to use Pigeon vs raw channels:**
- New code: always Pigeon — safer, easier to maintain, required by Google's internal Flutter style guide
- Simple one-off integrations in prototypes: raw `MethodChannel` is fine
- Existing plugin: raw channels are already there; migrate when touching the channel anyway

---

### 9.4 FFI (Dart Foreign Function Interface)

FFI lets Dart call C/C++ functions directly, bypassing platform channel serialization entirely — no message encoding, no round-trip to the platform main thread. Use it for performance-critical native code: image codecs, cryptography, ML inference, audio DSP.

The trade-off: you manage C memory manually (allocate, read, free). Mistakes cause memory leaks or crashes — no Dart garbage collector to save you.

```dart
import 'dart:ffi';
import 'package:ffi/ffi.dart';

// Define the native function signature
typedef NativeSha256 = Pointer<Uint8> Function(Pointer<Uint8> data, Int32 length);
typedef DartSha256  = Pointer<Uint8> Function(Pointer<Uint8> data, int length);

// Load the shared library and resolve the symbol
final dylib    = DynamicLibrary.open('libcrypto.so');   // Android
// DynamicLibrary.process() — for symbols already in the process (iOS static libs)
final sha256Fn = dylib.lookupFunction<NativeSha256, DartSha256>('SHA256');

Uint8List hashBytes(Uint8List input) {
  // Allocate native memory
  final inputPtr  = calloc<Uint8>(input.length);
  final outputPtr = calloc<Uint8>(32); // SHA-256 output is 32 bytes

  try {
    inputPtr.asTypedList(input.length).setAll(0, input);
    sha256Fn(inputPtr, input.length);
    return Uint8List.fromList(outputPtr.asTypedList(32));
  } finally {
    calloc.free(inputPtr);   // ALWAYS free — no GC for native memory
    calloc.free(outputPtr);
  }
}
```

**`dart:ffi` key types:**

| Type | Purpose |
|---|---|
| `Pointer<T>` | Typed pointer to native memory |
| `NativeFunction<F>` | Represents a C function type |
| `calloc` / `malloc` | Allocate native memory (must be freed manually) |
| `using(arena, ...)` | Arena allocator — frees all allocations when the block exits |
| `Struct` / `Union` | Map C structs/unions to Dart classes |
| `TransferableTypedData` | Zero-copy binary data transfer (isolates, not FFI) |

**`Arena` allocator** — preferred over manual `calloc.free` for multiple allocations:

```dart
final result = using((Arena arena) {
  final ptr = arena<Uint8>(32);
  // arena frees ptr automatically when this block exits, even on exception
  sha256Fn(ptr, 32);
  return Uint8List.fromList(ptr.asTypedList(32));
});
```

**When to use FFI vs MethodChannel:**

| | MethodChannel / Pigeon | FFI |
|---|---|---|
| Overhead | Serialization + platform thread hop | Near-zero |
| Safety | Platform guarantees, typed with Pigeon | Manual memory management |
| Threading | Always called on platform main thread | Called on current Dart thread |
| Use for | UI-level native APIs (auth, camera, sensors) | CPU-intensive native libs (codecs, crypto, ML) |

---

### 9.5 Plugins vs Packages

- **Package** — pure Dart, no native code. Works on all platforms.
- **Plugin** — contains platform-specific code (Swift/Kotlin/C++) alongside Dart. Registered with the Flutter plugin system.
- **Federated plugin** — the modern structure: `foo` (interface), `foo_android`, `foo_ios`, `foo_web` are separate packages. Platform teams can update their implementations independently.

When writing a plugin: prefer Pigeon for the channel interface, implement `FlutterPlugin` on Android and `FlutterPlugin` protocol on iOS, and register in the plugin's `registerWith` method — not in the app's `AppDelegate`.

---

### Module 9 — Quick fire answers

| Question | Answer |
|----------|--------|
| MethodChannel vs EventChannel? | Method: one-shot call, one response. Event: persistent subscription, native pushes a stream of events |
| What is Pigeon? | Google's code generator for type-safe platform channels — eliminates stringly-typed method names, generates Swift/Kotlin/Dart stubs from a single Dart definition |
| FFI vs MethodChannel? | FFI: near-zero overhead, direct C call, manual memory. MethodChannel: serialization cost, always on platform main thread, safer |
| What is a federated plugin? | A plugin split into interface + per-platform packages (`foo`, `foo_android`, `foo_ios`) — platforms can be maintained independently |
| What thread do MethodChannel handlers run on? | The platform's main thread (UI thread). Never block it — dispatch heavy work to a background thread first |
| When would you use `DynamicLibrary.process()`? | On iOS, where static libraries are linked into the main binary — there's no `.so` file to open |
| What is `Arena` in FFI? | A scoped allocator — all native memory allocated within its block is freed when the block exits, preventing leaks |

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

The `local_auth` package delegates to the OS biometric stack: Face ID / Touch ID on iOS, and fingerprint / face unlock on Android (via BiometricPrompt). It never accesses the biometric data itself — authentication happens entirely inside the secure enclave. Always plan for a fallback: if no biometrics are enrolled, or the user fails too many attempts, the OS falls back to PIN or password. Check `auth.canCheckBiometrics` and `auth.getAvailableBiometrics()` before showing the biometric prompt.

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

The `Semantics` widget provides metadata to the OS accessibility layer — TalkBack on Android and VoiceOver on iOS — so screen readers can describe your UI to visually impaired users. You only need `Semantics` manually for **custom widgets** built with `GestureDetector`, `InkWell`, or custom painting, where Flutter can't infer intent automatically.

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

Most built-in widgets (`ElevatedButton`, `Text`, `Image`) set semantics automatically — use `Semantics` only when the built-in behaviour is insufficient.

---

### 11.2 Touch Target Size

Small touch targets directly harm motor-impaired users, people with tremors, and anyone using a phone one-handed. The Material Design spec mandates a minimum 48×48 dp touch area — even if the visual element is smaller — to ensure comfortable tapping without precision. When the visual and touch areas differ, Flutter handles the extra tap area invisibly via `MaterialTapTargetSize`.

```dart
// If the visual element is smaller, wrap it
SizedBox(
  width: 48,
  height: 48,
  child: IconButton(icon: const Icon(Icons.close), onPressed: _close),
)
```

Note: `IconButton` already enforces a 48dp minimum touch target by default — you only need the `SizedBox` wrapper for fully custom hit areas.

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

A CI pipeline automates quality gates so no broken code reaches production. The structure follows a **fail-fast** principle: the `test` job runs first and cheaper checks (format, analyse, test) happen before expensive ones (build). The `needs: test` declaration on build jobs means they don't start — and don't waste build minutes — if tests fail. Coverage is measured with `lcov` and converted to HTML for human review.

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

Flutter uses a two-part version string: the **semantic version** (`2.4.1`) is shown to users in app stores and follows semver (major.minor.patch). The **build number** (`+47`) is an integer used by the stores to identify submissions — it must be strictly monotonically increasing with each upload. In CI, you typically set it automatically using the pipeline run number (`--build-number=$GITHUB_RUN_NUMBER`) so you never manually track it.

```yaml
# pubspec.yaml
version: 2.4.1+47
#        │   │
#        │   └── Build number (auto-incremented in CI)
#        └────── Semantic version shown to users
```

---

### 12.3 Flavors / Build Variants

Flavors are named build configurations defined at the platform level — **product flavors** in Android's Gradle and **schemes/targets** in Xcode. Each flavor can have its own bundle ID, app icon, display name, and environment configuration. The `-t lib/main_dev.dart` flag selects a separate entry point per flavor, which typically calls `runApp` with environment-specific configuration (API URL, feature flags, analytics keys). This is how you avoid accidentally shipping dev endpoints to production users.

```
flutter build apk --flavor development -t lib/main_dev.dart
flutter build apk --flavor production  -t lib/main_prod.dart
```

Common flavor set: `development` (local / debug), `staging` (QA / internal), `production` (app store release).

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
