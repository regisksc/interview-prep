# State Management in Flutter — Practical Course

A progressive course on the three state management approaches most used in production Flutter:
**Riverpod**, **Bloc / Cubit**, and **RxDart**.

Each section goes from zero to production-ready, with code, common mistakes, and interview Q&A.

**Practice exercises:** `practice/build/todos/`, `practice/build/live_search/`, `practice/build/stopwatch/`
**Interview reference:** `FLUTTER_INTERVIEW_PREP.md` → Module 3 & 5

---

## Table of Contents

1. [Mental model — what is state management?](#1-mental-model)
2. [Riverpod](#2-riverpod)
3. [Bloc / Cubit](#3-bloc--cubit)
4. [RxDart](#4-rxdart)
5. [Choosing between them](#5-choosing-between-them)

---

## 1. Mental model

Before touching any package, internalize the core problem:

```
User action → State change → UI rebuild
```

Every state management solution is just a different answer to:
- **Where** does state live?
- **How** does a change propagate to the UI?
- **Who** is allowed to mutate it?

| Approach | State lives in | Change propagates via | Mutation API |
|----------|---------------|-----------------------|--------------|
| `setState` | `State` object | Explicit `setState()` call | Direct mutation + setState |
| Riverpod | Provider container | `ref.watch` subscriptions | Notifier methods |
| Bloc | `Bloc`/`Cubit` | `Stream<State>` | Events (Bloc) / methods (Cubit) |
| RxDart | `Subject` | `Stream` operators | `subject.add(value)` |

---

## 2. Riverpod

### 2.1 Why Riverpod?

Provider (the old package) had three hard problems:
1. `ProviderNotFoundException` at runtime — no compile-time safety
2. Needed a `BuildContext` to read providers anywhere
3. Combining providers was awkward

Riverpod solves all three. It is the de-facto standard for new Flutter apps as of 2024.

### 2.2 Setup

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
```

```dart
void main() => runApp(const ProviderScope(child: MyApp()));
```

`ProviderScope` is the container for all providers. There is exactly one per app.

---

### 2.3 Provider types — choosing the right one

```
What are you storing?

  A synchronous value you never change?   → Provider<T>
  A simple mutable scalar?                → StateProvider<T>
  A complex object with methods?          → NotifierProvider<N, T>
  A Future (one-shot async load)?         → FutureProvider<T>
  A Stream (continuous data)?             → StreamProvider<T>
  An async object with methods?           → AsyncNotifierProvider<N, T>
```

#### `Provider<T>` — read-only derived value

```dart
final greetingProvider = Provider<String>((ref) => 'Hello, world');

// In a widget:
final greeting = ref.watch(greetingProvider); // 'Hello, world'
```

Use for constants and derived/computed values. Never has a notifier.

---

#### `StateProvider<T>` — simple mutable scalar

```dart
final counterProvider = StateProvider<int>((ref) => 0);

// Read:
final count = ref.watch(counterProvider);

// Write (in a callback):
ref.read(counterProvider.notifier).state++;
```

Good for: selected tab, search query string, toggle switches.
Avoid for: objects with multiple fields — use `NotifierProvider` instead.

---

#### `NotifierProvider<N, T>` — complex synchronous state

```dart
class CartNotifier extends Notifier<List<Item>> {
  @override
  List<Item> build() => []; // initial state

  void add(Item item) {
    state = [...state, item]; // emit new list — do NOT mutate in place
  }

  void remove(String id) {
    state = state.where((i) => i.id != id).toList();
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<Item>>(CartNotifier.new);

// In widget:
final items = ref.watch(cartProvider);
ref.read(cartProvider.notifier).add(item);
```

**Critical rule:** `state = newValue` triggers a rebuild. `state.add(x)` (mutating in place) does **not** — Riverpod uses reference equality.

---

#### `FutureProvider<T>` — one-shot async load

```dart
final userProvider = FutureProvider<User>((ref) async {
  return await api.fetchUser();
});

// In widget:
final asyncUser = ref.watch(userProvider);
return asyncUser.when(
  loading: () => const CircularProgressIndicator(),
  error: (e, _) => Text('Error: $e'),
  data: (user) => Text(user.name),
);
```

Riverpod automatically wraps the result in `AsyncValue<T>` with three states: `loading`, `error`, `data`.

---

#### `StreamProvider<T>` — continuous data source

```dart
final messagesProvider = StreamProvider<List<Message>>((ref) {
  return firestore.collection('messages').snapshots().map(...);
});
```

Behaves like `FutureProvider` but rebuilds on every new stream event.

---

#### `AsyncNotifierProvider<N, T>` — async state with mutations

The most powerful type. Combines `FutureProvider` (async init) with `NotifierProvider` (mutation methods).

```dart
class TodosNotifier extends AsyncNotifier<List<Todo>> {
  @override
  Future<List<Todo>> build() async {
    // Runs on first watch. Return value becomes AsyncData.
    await Future.delayed(const Duration(milliseconds: 600));
    return [const Todo(id: '1', title: 'Buy milk')];
  }

  Future<void> add(String title) async {
    final current = await future; // wait for build() if still loading
    state = AsyncData([
      ...current,
      Todo(id: _uuid(), title: title),
    ]);
    // No loading flash — state stays AsyncData during mutation
  }
}

final todosProvider =
    AsyncNotifierProvider<TodosNotifier, List<Todo>>(TodosNotifier.new);
```

**`await future` vs `state.value!`:**
- `state.value!` throws if `build()` hasn't completed yet
- `await future` waits safely — always prefer this in mutation methods

---

### 2.4 ref.watch vs ref.read vs ref.listen

| Method | Where | What it does |
|--------|-------|--------------|
| `ref.watch(p)` | inside `build()` | Subscribes — widget rebuilds when `p` changes |
| `ref.read(p)` | inside callbacks, methods | Reads once — no subscription |
| `ref.listen(p, cb)` | inside `build()` | Runs `cb` on change — no rebuild |

```dart
// ✅ correct
Widget build(BuildContext context, WidgetRef ref) {
  final count = ref.watch(counterProvider); // reactive
  return FilledButton(
    onPressed: () => ref.read(counterProvider.notifier).state++, // one-shot
    child: Text('$count'),
  );
}

// ❌ wrong — ref.watch in a callback throws
onPressed: () {
  final count = ref.watch(counterProvider); // Bad state exception
}
```

---

### 2.5 Derived providers

Derived providers compute a value from one or more other providers. They update automatically.

```dart
final filterProvider = StateProvider<Filter>((ref) => Filter.all);

final filteredTodosProvider = Provider<AsyncValue<List<Todo>>>((ref) {
  final todos = ref.watch(todosProvider);       // re-runs when todos change
  final filter = ref.watch(filterProvider);    // re-runs when filter changes
  return todos.whenData((list) => switch (filter) {
    Filter.all    => list,
    Filter.active => list.where((t) => !t.done).toList(),
    Filter.done   => list.where((t) => t.done).toList(),
  });
});
```

`whenData` runs the transform only when data is available — loading/error states pass through unchanged.

---

### 2.6 Modifiers: autoDispose and family

#### `autoDispose`

```dart
final searchProvider = FutureProvider.autoDispose.family<List<User>, String>(
  (ref, query) => api.search(query),
);
```

- `.autoDispose` — provider is destroyed when no widget watches it anymore
- `.family<T, Arg>` — parameterises a provider (like a function argument)
- Combine: `.autoDispose.family`

```dart
// Keep alive even when unwatched (e.g. during navigation)
final expensiveProvider = FutureProvider.autoDispose<Data>((ref) async {
  final link = ref.keepAlive(); // prevents auto-dispose
  ref.onDispose(link.close);
  return await heavyComputation();
});
```

---

### 2.7 Testing

Riverpod is designed to be tested without widgets.

```dart
test('add todo increments list length', () async {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  // Override a provider for isolation
  final container = ProviderContainer(overrides: [
    apiProvider.overrideWithValue(FakeApi()),
  ]);

  await container.read(todosProvider.future); // wait for build()
  await container.read(todosProvider.notifier).add('Test');

  final todos = container.read(todosProvider).value!;
  expect(todos.length, 2);
});
```

No `pumpWidget`, no `BuildContext` — pure Dart tests.

---

### 2.8 Common mistakes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| `state.add(x)` in Notifier | UI never updates | `state = [...state, x]` |
| `ref.watch` in a callback | `Bad state` exception | Use `ref.read` |
| `ref.read` in a derived provider | Derived value stuck at initial | Use `ref.watch` |
| `state.value!` in mutation | Throws during loading | `await future` |
| `AsyncLoading()` before every mutation | Loading spinner flash | Set `AsyncData` directly |

---

### 2.9 Interview Q&A

**Q: Why can't you use `ref.watch` outside `build`?**
`ref.watch` registers a listener that schedules a widget rebuild. Outside `build`, there is no rebuild context to schedule against — Riverpod throws immediately.

**Q: Why does mutating a `List` in place not update the UI?**
Riverpod compares old and new `state` with `==`. A mutated list is the same object, so `oldState == newState` → no notification.

**Q: What is `whenData` and why use it on a derived provider?**
`whenData` applies a transform only when the `AsyncValue` is `data`, passing `loading` and `error` through unchanged. Without it you'd have to pattern-match in the derived provider, re-implementing the async scaffolding yourself.

**Q: When would you use `autoDispose`?**
Whenever the provider's data is scoped to a screen or user session — search results, paginated feeds, per-route data. Without `autoDispose`, providers live forever in the container even after the screen is gone.

---

## 3. Bloc / Cubit

### 3.1 Why Bloc?

Riverpod is excellent for most apps. Bloc earns its complexity when you need:
- **Auditability** — every state transition is an explicit, logged event
- **Complex async flows** — `EventTransformer` lets you debounce, throttle, or drop events at the Bloc level
- **Large teams** — the event/state contract forces a clear boundary between UI and logic

### 3.2 Cubit — Bloc without events

Cubit is a simplified Bloc where methods replace events. Start here.

```yaml
dependencies:
  flutter_bloc: ^9.0.0
```

```dart
// State
class CounterState {
  final int count;
  const CounterState(this.count);
}

// Cubit
class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(const CounterState(0));

  void increment() => emit(CounterState(state.count + 1));
  void decrement() => emit(CounterState(state.count - 1));
}
```

`emit` is the only way to change state. The new state is broadcast to all `BlocBuilder`s.

---

### 3.3 BlocProvider, BlocBuilder, BlocListener

```dart
// Provide the cubit to the subtree
BlocProvider(
  create: (_) => CounterCubit(),
  child: const CounterScreen(),
)

// Rebuild UI on state change
BlocBuilder<CounterCubit, CounterState>(
  builder: (context, state) => Text('${state.count}'),
)

// Run side-effects (navigation, snackbars) on state change — no rebuild
BlocListener<CounterCubit, CounterState>(
  listenWhen: (previous, current) => current.count == 10,
  listener: (context, state) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Reached 10!')));
  },
  child: const CounterScreen(),
)

// Combine: rebuild + side effects
BlocConsumer<CounterCubit, CounterState>(
  listenWhen: ...,
  listener: ...,
  buildWhen: ...,
  builder: ...,
)
```

**`buildWhen`** and **`listenWhen`** are optimisation hooks — return `false` to suppress a rebuild or callback when the relevant part of state hasn't changed.

---

### 3.4 Full Bloc — events + states

Use Bloc (not Cubit) when a single user action can produce multiple different state transitions depending on context, or when you need event transformers.

#### Sealed state hierarchy

```dart
sealed class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
```

Sealed classes give you exhaustive `switch` — the compiler tells you when you've missed a case.

#### Events

```dart
sealed class AuthEvent {}
class LoginRequested extends AuthEvent {
  final String email, password;
  LoginRequested(this.email, this.password);
}
class LogoutRequested extends AuthEvent {}
```

#### Bloc

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;

  AuthBloc(this._repo) : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _repo.login(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await _repo.logout();
    emit(AuthInitial());
  }
}
```

#### Dispatching events

```dart
context.read<AuthBloc>().add(LoginRequested(email, password));
```

#### Consuming state

```dart
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) => switch (state) {
    AuthInitial()         => const LoginForm(),
    AuthLoading()         => const CircularProgressIndicator(),
    AuthAuthenticated(user: final u) => HomeScreen(user: u),
    AuthError(message: final m)      => ErrorView(message: m),
  },
)
```

---

### 3.5 Event transformers

Event transformers let you control how events are processed at the Bloc level.

```yaml
dependencies:
  bloc_concurrency: ^0.3.0
```

```dart
import 'package:bloc_concurrency/bloc_concurrency.dart';

// Only process one event at a time — drop new events while busy
on<SearchRequested>(_onSearch, transformer: droppable());

// Cancel the current handler when a new event arrives
on<SearchRequested>(_onSearch, transformer: restartable());

// Queue events — process them one by one
on<SaveRequested>(_onSave, transformer: sequential());
```

`restartable()` is the Bloc equivalent of RxDart's `switchMap` — ideal for search.

---

### 3.6 Testing

```dart
import 'package:bloc_test/bloc_test.dart';

blocTest<CounterCubit, CounterState>(
  'increment emits incremented state',
  build: () => CounterCubit(),
  act: (cubit) => cubit.increment(),
  expect: () => [const CounterState(1)],
);

blocTest<AuthBloc, AuthState>(
  'login success emits loading then authenticated',
  build: () => AuthBloc(FakeAuthRepo()),
  act: (bloc) => bloc.add(LoginRequested('a@b.com', 'pass')),
  expect: () => [
    AuthLoading(),
    isA<AuthAuthenticated>(),
  ],
);
```

---

### 3.7 Common mistakes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| `emit` after `await` when bloc is closed | `Bad state: emit called after close` | Check `!isClosed` before emitting, or use `Emitter.forEach` |
| Direct state mutation | No rebuild | Always create a new state object |
| `context.read` in `initState` | Provider not found | Use `BlocProvider` higher up or pass the bloc explicitly |
| One giant state class | All widgets rebuild on any change | Split into multiple Blocs by feature |
| Bloc for simple toggle | Unnecessary boilerplate | Use Cubit or even `StateProvider` |

---

### 3.8 Interview Q&A

**Q: When would you choose Bloc over Cubit?**
When you need event transformers (`restartable`, `droppable`) or when the same event can transition to different states depending on which handler receives it. For everything else, Cubit is simpler and preferred.

**Q: What is `Emitter` and why is it passed to event handlers?**
`Emitter` is a scoped emission handle. When the Bloc is closed or a new `restartable` event arrives, the current `Emitter` is cancelled — any `emit` after that is a no-op. If you held a direct reference to the Bloc instead, you'd risk emitting stale state.

**Q: Why use sealed classes for states?**
Exhaustive `switch` — the compiler forces you to handle every state. This is especially valuable as state hierarchies grow; a new state class that isn't handled becomes a compile error, not a silent runtime bug.

**Q: How does `bloc_concurrency`'s `restartable` work?**
Each new event cancels the previous event handler's `Future`. Under the hood it's a `switchMap` on the event stream — the new handler starts fresh while the old one is disposed.

---

## 4. RxDart

### 4.1 What is ReactiveX?

ReactiveX is a model for composing asynchronous event streams using functional operators. RxDart extends Dart's native `Stream` with:
- **Subjects** — `StreamController`s that also cache and replay values
- **Operators** — `debounceTime`, `switchMap`, `combineLatest`, etc.
- **`ValueStream`** — streams that always have a current value

```yaml
dependencies:
  rxdart: ^0.28.0
```

---

### 4.2 Subjects

A `Subject` is simultaneously a `StreamController` (you add values) and a `Stream` (you listen to it).

#### `PublishSubject` — no replay

```dart
final subject = PublishSubject<String>();

subject.stream.listen(print); // listener registered

subject.add('hello');  // prints: hello
subject.add('world');  // prints: world

// Late subscriber misses previous values:
subject.stream.listen(print); // nothing until next add()

subject.close(); // always close in dispose()
```

#### `BehaviorSubject` — replays the latest value

```dart
final subject = BehaviorSubject<String>.seeded('initial');

subject.add('updated');

// New subscriber immediately gets 'updated':
subject.stream.listen(print); // prints: updated immediately

print(subject.value); // 'updated' — synchronous access
```

Use `BehaviorSubject` for search queries, form fields, anything where a new subscriber needs the current value.

#### `ReplaySubject` — replays the last N values

```dart
final subject = ReplaySubject<int>(maxSize: 3);
subject.add(1);
subject.add(2);
subject.add(3);
subject.add(4);

// New subscriber gets 2, 3, 4 (last 3):
subject.stream.listen(print);
```

---

### 4.3 Key operators

#### `debounceTime` — wait for input to settle

```dart
subject.stream
    .debounceTime(const Duration(milliseconds: 300))
    .listen(print);

subject.add('h');
subject.add('he');
subject.add('hel');
// 300 ms of silence...
// prints: hel  (only the last value after settling)
```

#### `distinct` — skip duplicate consecutive values

```dart
subject.stream
    .distinct()
    .listen(print);

subject.add('a'); // prints: a
subject.add('a'); // skipped
subject.add('b'); // prints: b
```

Always put `distinct()` **before** `debounceTime` — there is no point debouncing a value that didn't change.

#### `switchMap` — cancel previous, start new

```dart
final results = querySubject.stream
    .distinct()
    .debounceTime(const Duration(milliseconds: 300))
    .switchMap((query) => Stream.fromFuture(search(query)));
```

`switchMap` unsubscribes from the previous inner stream when a new outer value arrives. This is what prevents stale search results from overwriting fresh ones.

**vs `flatMap` (`asyncExpand`):** `flatMap` merges all inner streams — if query A takes 1 s and query B takes 0.1 s, B's results arrive first but A's arrive later and overwrite them. `switchMap` cancels A the moment B is typed.

#### `combineLatest` — merge multiple streams, always emit when any changes

```dart
final combined = Rx.combineLatest2(
  usernameSubject.stream,
  passwordSubject.stream,
  (String username, String password) => username.isNotEmpty && password.length >= 8,
);

// Emits true/false whenever either field changes
combined.listen((isValid) => setState(() => _isValid = isValid));
```

#### `zip` — pair elements one-to-one

```dart
final zipped = Rx.zip2(
  Stream.fromIterable([1, 2, 3]),
  Stream.fromIterable(['a', 'b', 'c']),
  (int n, String s) => '$n$s',
);
// emits: '1a', '2b', '3c'
```

Unlike `combineLatest`, `zip` waits for both streams to emit a matching element before producing a value.

#### `scan` — accumulate over time (like `reduce` but emits intermediates)

```dart
subject.stream
    .scan<int>((acc, val, _) => acc + val, 0)
    .listen(print);

subject.add(1); // prints: 1
subject.add(2); // prints: 3
subject.add(3); // prints: 6
```

Great for running totals, undo history, accumulated state.

---

### 4.4 Full reactive search pattern

This is the canonical RxDart pattern used in production:

```dart
class _SearchScreenState extends State<SearchScreen> {
  // 1. Subject as input sink
  final _query = BehaviorSubject<String>.seeded('');

  // 2. Declarative pipeline — built once, never rebuilt
  late final Stream<List<String>?> _results = _query.stream
      .distinct()
      .debounceTime(const Duration(milliseconds: 300))
      .switchMap((q) => q.isEmpty
          ? Stream.value(null)          // null = idle state
          : Stream.fromFuture(search(q)));

  @override
  void dispose() {
    _query.close(); // must close — leaks a stream if not
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextField(onChanged: _query.add), // push to subject
      Expanded(
        child: StreamBuilder<List<String>?>(
          stream: _results,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text('Start typing...');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            final results = snapshot.data!;
            if (results.isEmpty) return const Text('No results');
            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (_, i) => ListTile(title: Text(results[i])),
            );
          },
        ),
      ),
    ]);
  }
}
```

**Key detail:** `_results` is `late final` — it's built once and reused. If you build it inside `build()` you create a new stream on every frame, breaking debounce and creating multiple subscriptions.

---

### 4.5 Integrating with Riverpod

RxDart and Riverpod compose well. Use `StreamProvider` to consume a `Subject`:

```dart
final _querySubject = BehaviorSubject<String>.seeded('');

final searchResultsProvider = StreamProvider.autoDispose
    .family<List<String>, String>((ref, query) {
  return Stream.fromFuture(search(query));
});

// Or expose the subject's pipeline directly:
final resultsStreamProvider = Provider<Stream<List<String>?>>((ref) {
  return _querySubject.stream
      .distinct()
      .debounceTime(const Duration(milliseconds: 300))
      .switchMap((q) => q.isEmpty
          ? Stream.value(null)
          : Stream.fromFuture(search(q)));
});
```

---

### 4.6 Common mistakes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| Building pipeline in `build()` | New subscription every frame, debounce never fires | `late final` field |
| `flatMap` instead of `switchMap` | Stale results overwrite fresh ones | `switchMap` |
| Not closing subject in `dispose` | Stream leak, `setState after dispose` errors | `_subject.close()` in `dispose` |
| `distinct()` after `debounceTime` | Debounce resets on repeated same value | `distinct()` before `debounceTime` |
| `Stream.value(null)` forgotten for empty query | Idle state shows last results | Emit `null` explicitly for idle |

---

### 4.7 Interview Q&A

**Q: What is the difference between `switchMap` and `flatMap`?**
`flatMap` (also called `asyncExpand`) merges all inner streams concurrently — results from all in-flight operations arrive and are emitted in whatever order they complete. `switchMap` cancels the previous inner stream when a new outer value arrives — only the latest operation's result is emitted. For search, `switchMap` is correct; `flatMap` risks showing stale results.

**Q: When would you use `BehaviorSubject` over `PublishSubject`?**
`BehaviorSubject` when the latest value must be immediately available to new subscribers — form fields, search queries, current user. `PublishSubject` when you only care about future events — button clicks, navigation triggers.

**Q: What happens if you forget to close a `Subject`?**
The underlying `StreamController` is never closed. Any `StreamSubscription` listening to it is never cancelled. If the listening widget is disposed, `setState` is called on a dead `State` — same class of bug as forgetting to cancel a `StreamSubscription`.

**Q: What does `distinct()` do and why does order with `debounceTime` matter?**
`distinct()` filters out consecutive duplicate values. Placed before `debounceTime`, it prevents the debounce timer from restarting when the user types and immediately deletes, returning to the same string — the value hasn't changed, so it's dropped before reaching the timer. Placed after, the timer still fires but the duplicate is dropped silently — which works, but wastes a timer cycle.

---

## 5. Choosing between them

### Decision matrix

| Situation | Recommendation |
|-----------|----------------|
| Simple local state (toggle, counter) | `setState` or `StateProvider` |
| App-wide settings (theme, locale) | `StateProvider` / `NotifierProvider` |
| Async data load (user profile, feed) | `AsyncNotifierProvider` or `FutureProvider` |
| Real-time data (chat, prices) | `StreamProvider` |
| Search / debounce / query cancellation | RxDart (`BehaviorSubject` + `switchMap`) |
| Complex async flows with multiple states | Bloc with sealed classes + `restartable` |
| Large team, strict separation of UI/logic | Bloc |
| Solo / small team, pragmatic | Riverpod |
| Combining multiple async sources | RxDart (`combineLatest`, `zip`) |

### They are not mutually exclusive

In a production app you will often see all three:

```
Riverpod      — global state, dependency injection, most features
Bloc / Cubit  — complex feature state machines (auth, checkout)
RxDart        — reactive pipelines inside a single feature (search, filters)
```

RxDart is not a replacement for Riverpod — it is a toolkit for building reactive pipelines that Riverpod then exposes via `StreamProvider`.

---

## Exercises

All three build exercises in `practice/build/` are intentionally approach-agnostic. Solve each one three times:

| Exercise | First pass | Second pass | Third pass |
|----------|-----------|-------------|------------|
| `todos/` | Riverpod (`AsyncNotifierProvider`) | Cubit | RxDart + StreamBuilder |
| `live_search/` | RxDart (`BehaviorSubject` + `switchMap`) | Riverpod (`StreamProvider.family`) | Bloc + `restartable` |
| `stopwatch/` | Vanilla streams (`Stream.periodic`) | RxDart (`interval` + `scan`) | Riverpod (`StreamProvider`) |

After each pass, read the corresponding `SOLUTIONS.md` and compare your implementation to the rubric.
