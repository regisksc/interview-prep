# Riverpod

**Practice:** `practice/build/todos/` · **Interview guide:** `README.md` → Module 3

---

## Why Riverpod?

Provider (the old package) had three hard problems:

1. `ProviderNotFoundException` at runtime — no compile-time safety
2. Needed `BuildContext` to read a provider from anywhere
3. Combining providers was awkward

Riverpod solves all three. It is the de-facto standard for new Flutter apps.

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
```

```dart
void main() => runApp(const ProviderScope(child: MyApp()));
```

`ProviderScope` is the single container for all providers. There is exactly one per app.

---

## Provider types

```
What are you storing?

  Read-only derived value?              → Provider<T>
  Simple mutable scalar?                → StateProvider<T>
  Complex object with methods?          → NotifierProvider<N, T>
  One-shot async load?                  → FutureProvider<T>
  Continuous stream?                    → StreamProvider<T>
  Async object with mutation methods?   → AsyncNotifierProvider<N, T>
```

---

### `Provider<T>` — read-only, derived

```dart
final greetingProvider = Provider<String>((ref) => 'Hello, world');

final greeting = ref.watch(greetingProvider);
```

Never has a notifier. Use for constants and computed values.

---

### `StateProvider<T>` — simple mutable scalar

```dart
final counterProvider = StateProvider<int>((ref) => 0);

// Read:
final count = ref.watch(counterProvider);

// Write (inside a callback):
ref.read(counterProvider.notifier).state++;
```

Good for: selected tab, search query string, toggle. Avoid for objects with multiple fields — use `NotifierProvider` instead.

---

### `NotifierProvider<N, T>` — complex synchronous state

```dart
class CartNotifier extends Notifier<List<Item>> {
  @override
  List<Item> build() => [];

  void add(Item item) {
    state = [...state, item]; // new reference — triggers rebuild
  }

  void remove(String id) {
    state = state.where((i) => i.id != id).toList();
  }
}

final cartProvider =
    NotifierProvider<CartNotifier, List<Item>>(CartNotifier.new);

// Widget:
final items = ref.watch(cartProvider);
ref.read(cartProvider.notifier).add(item);
```

**Critical rule:** `state = newValue` triggers a rebuild. `state.add(x)` (mutating in place) does **not** — Riverpod uses reference equality.

---

### `FutureProvider<T>` — one-shot async load

```dart
final userProvider = FutureProvider<User>((ref) async {
  return await api.fetchUser();
});

// Widget:
final asyncUser = ref.watch(userProvider);
return asyncUser.when(
  loading: () => const CircularProgressIndicator(),
  error:   (e, _) => Text('Error: $e'),
  data:    (user) => Text(user.name),
);
```

The result is automatically wrapped in `AsyncValue<T>` with three states: loading, error, data.

---

### `StreamProvider<T>` — continuous data

```dart
final messagesProvider = StreamProvider<List<Message>>((ref) {
  return firestore.collection('messages').snapshots().map(fromSnapshot);
});
```

Behaves like `FutureProvider` but rebuilds on every new stream event.

---

### `AsyncNotifierProvider<N, T>` — async state with mutations

The most powerful type. Combines async init (`FutureProvider`) with mutation methods (`NotifierProvider`).

```dart
class TodosNotifier extends AsyncNotifier<List<Todo>> {
  @override
  Future<List<Todo>> build() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [const Todo(id: '1', title: 'Buy milk')];
  }

  Future<void> add(String title) async {
    final current = await future; // safe — waits if build() is still running
    state = AsyncData([
      ...current,
      Todo(id: DateTime.now().millisecondsSinceEpoch.toString(), title: title),
    ]);
    // State stays AsyncData during mutation — no loading flash
  }

  Future<void> toggle(String id) async {
    final current = await future;
    state = AsyncData(
      current.map((t) => t.id == id ? t.copyWith(done: !t.done) : t).toList(),
    );
  }
}

final todosProvider =
    AsyncNotifierProvider<TodosNotifier, List<Todo>>(TodosNotifier.new);
```

**`await future` vs `state.value!`:**
- `state.value!` throws if `build()` hasn't completed yet
- `await future` waits safely — always prefer this in mutations

---

## ref.watch vs ref.read vs ref.listen

| Method | Where | What it does |
|--------|-------|--------------|
| `ref.watch(p)` | inside `build()` | Subscribes — widget rebuilds when `p` changes |
| `ref.read(p)` | inside callbacks / methods | Reads once — no subscription |
| `ref.listen(p, cb)` | inside `build()` | Runs `cb` on change — no rebuild |

```dart
// ✅ correct
Widget build(BuildContext context, WidgetRef ref) {
  final count = ref.watch(counterProvider);
  return FilledButton(
    onPressed: () => ref.read(counterProvider.notifier).state++,
    child: Text('$count'),
  );
}

// ❌ wrong — throws Bad state exception
onPressed: () {
  final count = ref.watch(counterProvider);
}
```

---

## Derived providers

```dart
final filterProvider = StateProvider<Filter>((ref) => Filter.all);

final filteredTodosProvider = Provider<AsyncValue<List<Todo>>>((ref) {
  final todos  = ref.watch(todosProvider);
  final filter = ref.watch(filterProvider);
  return todos.whenData((list) => switch (filter) {
    Filter.all    => list,
    Filter.active => list.where((t) => !t.done).toList(),
    Filter.done   => list.where((t) => t.done).toList(),
  });
});
```

`whenData` runs the transform only when data is available — loading/error pass through unchanged.

---

## Modifiers

### `autoDispose`

Provider is destroyed when no widget watches it anymore.

```dart
final searchProvider = FutureProvider.autoDispose.family<List<User>, String>(
  (ref, query) => api.search(query),
);
```

Prevent auto-dispose when needed (e.g. navigation):

```dart
final expensiveProvider = FutureProvider.autoDispose<Data>((ref) async {
  final link = ref.keepAlive();
  ref.onDispose(link.close);
  return await heavyComputation();
});
```

### `family`

Parameterises a provider — like passing an argument.

```dart
final userProvider = FutureProvider.family<User, String>(
  (ref, userId) => api.fetchUser(userId),
);

final user = ref.watch(userProvider('abc-123'));
```

---

## Testing

```dart
test('add todo increments list', () async {
  final container = ProviderContainer(overrides: [
    apiProvider.overrideWithValue(FakeApi()),
  ]);
  addTearDown(container.dispose);

  await container.read(todosProvider.future);
  await container.read(todosProvider.notifier).add('Test');

  final todos = container.read(todosProvider).value!;
  expect(todos.length, 2);
});
```

No `pumpWidget`, no `BuildContext` — pure Dart tests.

---

## Common mistakes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| `state.add(x)` in Notifier | UI never updates | `state = [...state, x]` |
| `ref.watch` in a callback | `Bad state` exception | Use `ref.read` |
| `ref.read` in a derived provider | Value stuck at initial | Use `ref.watch` |
| `state.value!` in mutation | Throws during loading | `await future` |
| `AsyncLoading()` before every mutation | Loading spinner flash | Assign `AsyncData` directly |

---

## Interview Q&A

**Q: Why can't you use `ref.watch` outside `build`?**
`ref.watch` registers a listener that schedules a widget rebuild. Outside `build`, there is no rebuild context — Riverpod throws immediately.

**Q: Why does mutating a `List` in place not update the UI?**
Riverpod compares old and new `state` with `==`. A mutated list is the same object, so `oldState == newState` is true — no notification fires.

**Q: What is `whenData` and why use it in a derived provider?**
`whenData` applies a transform only when the `AsyncValue` is `data`, passing `loading` and `error` through unchanged. Without it you'd have to pattern-match loading/error in every derived provider — duplication.

**Q: When would you use `autoDispose`?**
Whenever the provider's data is scoped to a screen or user session — search results, paginated feeds, per-route data. Without it, providers live in the container forever even after the screen is gone.

**Q: What is the difference between `NotifierProvider` and `AsyncNotifierProvider`?**
`NotifierProvider` is for synchronous state — `build()` returns `T` directly. `AsyncNotifierProvider` is for state that must be loaded asynchronously — `build()` returns `Future<T>` and Riverpod wraps it in `AsyncValue<T>` automatically.
