# Bloc / Cubit

**Practice:** `practice/build/todos/` · **Interview guide:** `README.md` → Module 3

---

## Start here

If Riverpod feels like "declare a provider and expose logic through it", Bloc feels like "drive the feature through explicit state transitions."

Since you already know Bloc better than Riverpod, use it as the reference point:

- **Cubit**: class with methods that `emit(...)`
- **Bloc**: event-driven version of that same idea
- **BlocProvider**: widget-tree dependency injection
- **BlocBuilder**: rebuild from state
- **BlocListener**: side-effects from state changes

For most app features, start with **Cubit**. Move to full **Bloc** only when you need event transformers, explicit event logs, or more formal workflow modeling.

---

## The normal feature flow

This is the usual way a Bloc feature gets built:

1. Define the feature state.
2. Decide whether Cubit is enough.
3. Create the Cubit/Bloc class.
4. Add feature methods or event handlers.
5. Provide it above the screen.
6. Render state with `BlocBuilder`.
7. Trigger side-effects with `BlocListener`.

For a todo feature with Cubit:

1. State: loading, data, maybe error
2. Cubit: load todos, add, toggle, delete
3. `BlocProvider(create: ...)`
4. `BlocBuilder<TodoCubit, TodoState>`
5. UI buttons call cubit methods

---

## Why Bloc?

Riverpod handles most apps well. Bloc earns its extra complexity when you need:

- **Auditability** — every state transition is an explicit, loggable event
- **Complex async flows** — `EventTransformer` lets you debounce, throttle, or cancel events at the Bloc level, not in the UI
- **Large teams** — the event/state contract enforces a clean boundary between UI and logic

```yaml
dependencies:
  flutter_bloc: ^9.0.0
```

---

## Cubit — Bloc without events

Start here. Cubit replaces events with plain method calls.

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

`emit` is the only way to change state. The new state is broadcast to all `BlocBuilder`s watching this Cubit.

Think of Cubit as the closest Bloc equivalent to a Riverpod notifier:

- Riverpod `state = ...`
- Cubit `emit(...)`

---

## BlocProvider, BlocBuilder, BlocListener

```dart
// Provide the Cubit to the subtree
BlocProvider(
  create: (_) => CounterCubit(),
  child: const CounterScreen(),
)

// Rebuild UI when state changes
BlocBuilder<CounterCubit, CounterState>(
  buildWhen: (previous, current) => previous.count != current.count,
  builder: (context, state) => Text('${state.count}'),
)

// Side-effects only — no rebuild
BlocListener<CounterCubit, CounterState>(
  listenWhen: (previous, current) => current.count == 10,
  listener: (context, state) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Reached 10!')));
  },
  child: const CounterScreen(),
)

// Rebuild + side-effects combined
BlocConsumer<CounterCubit, CounterState>(
  listenWhen: ...,
  listener: ...,
  buildWhen: ...,
  builder: ...,
)
```

`buildWhen` and `listenWhen` are optimisation hooks — return `false` to suppress a rebuild or callback when the relevant part of state hasn't changed.

---

## Full Bloc — events + states

Use full Bloc (not Cubit) when:
- A single user action can produce different state transitions depending on context
- You need event transformers (debounce, cancel, queue)
- You need a full audit log of every action

If your feature mainly responds to direct method calls like `addTodo()` or `toggleTodo()`, Cubit is usually enough.

### Sealed state hierarchy

```dart
sealed class AuthState {}
class AuthInitial    extends AuthState {}
class AuthLoading    extends AuthState {}
class AuthSuccess    extends AuthState { final User user; AuthSuccess(this.user); }
class AuthFailure    extends AuthState { final String message; AuthFailure(this.message); }
```

Sealed classes give you exhaustive `switch` — the compiler errors if you miss a case.

### Events

```dart
sealed class AuthEvent {}
class LoginRequested  extends AuthEvent {
  final String email, password;
  LoginRequested(this.email, this.password);
}
class LogoutRequested extends AuthEvent {}
```

### Bloc

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;

  AuthBloc(this._repo) : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _repo.login(event.email, event.password);
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogout(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repo.logout();
    emit(AuthInitial());
  }
}
```

### Dispatching and consuming

```dart
// Dispatch
context.read<AuthBloc>().add(LoginRequested(email, password));

// Consume
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) => switch (state) {
    AuthInitial()                        => const LoginForm(),
    AuthLoading()                        => const CircularProgressIndicator(),
    AuthSuccess(user: final u)           => HomeScreen(user: u),
    AuthFailure(message: final m)        => ErrorView(message: m),
  },
)
```

---

## Event transformers

Control how events are processed at the Bloc level — without any logic in the UI.

```yaml
dependencies:
  bloc_concurrency: ^0.3.0
```

```dart
import 'package:bloc_concurrency/bloc_concurrency.dart';

// Drop new events while a handler is already running
on<SearchRequested>(_onSearch, transformer: droppable());

// Cancel the running handler when a new event arrives (like switchMap)
on<SearchRequested>(_onSearch, transformer: restartable());

// Process events one at a time, in order
on<SaveRequested>(_onSave, transformer: sequential());
```

`restartable()` is the Bloc equivalent of RxDart's `switchMap` — the correct choice for search-as-you-type.

---

## Riverpod-to-Bloc translation

If you are learning Riverpod and want a bridge:

| Riverpod | Bloc / Cubit |
|----------|---------------|
| provider | `BlocProvider` |
| notifier/controller | `Cubit` / `Bloc` |
| `state = newValue` | `emit(newValue)` |
| `ref.watch(...)` | `BlocBuilder` |
| `ref.read(...notifier)` | `context.read<MyCubit>()` |
| derived provider | selector / computed state / separate cubit |

Big difference:

- Riverpod declares providers at the top level
- Bloc usually injects state objects through the widget tree

---

## Testing

```dart
import 'package:bloc_test/bloc_test.dart';

blocTest<CounterCubit, CounterState>(
  'increment emits incremented count',
  build: () => CounterCubit(),
  act:   (cubit) => cubit.increment(),
  expect: () => [const CounterState(1)],
);

blocTest<AuthBloc, AuthState>(
  'login success emits loading then authenticated',
  build: () => AuthBloc(FakeAuthRepo()),
  act:   (bloc) => bloc.add(LoginRequested('a@b.com', 'pass')),
  expect: () => [
    AuthLoading(),
    isA<AuthSuccess>(),
  ],
);
```

---

## Common mistakes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| `emit` after `await` when Bloc is closed | `Bad state: emit after close` | Check `!isClosed` or use `Emitter.forEach` |
| Mutating state directly | No rebuild | Create a new state object |
| `context.read` in `initState` | Provider not found | Move `BlocProvider` higher or pass Bloc explicitly |
| One giant state class | All widgets rebuild on any change | Split into multiple Blocs by feature |
| Bloc for a simple boolean toggle | Unnecessary boilerplate | Use Cubit or `StateProvider` |

---

## Interview Q&A

**Q: When would you choose Bloc over Cubit?**
When you need event transformers (`restartable`, `droppable`) or when you need a complete audit trail of every user action. For everything else, Cubit is simpler and preferred.

**Q: What is `Emitter` and why is it passed to handlers instead of using `this.emit`?**
`Emitter` is a scoped emission handle tied to the current handler invocation. When the Bloc is closed or a `restartable` event supersedes the current one, the `Emitter` is cancelled — any subsequent `emit` call is a no-op. If you used `this.emit` directly you could emit stale state after the handler should have been abandoned.

**Q: Why use sealed classes for states?**
Exhaustive `switch` — the compiler forces you to handle every state. When a new state is added, every switch that doesn't handle it becomes a compile error, not a silent runtime bug.

**Q: How does `restartable()` work internally?**
It applies a `switchMap`-like transformation to the event stream — when a new event arrives, it cancels the current handler's `Future` and starts a fresh one. New events are not queued; only the latest is processed.

**Q: What is the difference between `BlocBuilder`, `BlocListener`, and `BlocConsumer`?**
`BlocBuilder` rebuilds the widget tree. `BlocListener` runs side-effects (navigation, snackbars) without rebuilding. `BlocConsumer` does both. The rule: put visual output in `builder`, put imperative side-effects in `listener`.
