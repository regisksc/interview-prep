# Riverpod

**Practice:** `practice/build/todos/` · **Interview guide:** `README.md` → Module 3

---

## Start here

Riverpod is easiest when you separate three words that people casually blur together:

- **Provider**: the thing your UI reads and watches
- **Notifier**: the class behind the provider that owns state and methods
- **Controller**: just a naming style for the notifier class

If you come from Bloc, think:

- provider = the public handle the UI uses
- notifier/controller = the object with your feature logic
- `state` = the current value exposed by that feature

You usually do **not** instantiate the notifier in the widget. You declare it once, wrap it in a provider, then the widget uses the provider.

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
```

```dart
void main() => runApp(const ProviderScope(child: MyApp()));
```

`ProviderScope` is the Riverpod container for the app. In most apps, there is one at the top.

---

## The normal feature flow

This is the usual way a feature gets built with Riverpod:

1. Define the feature state shape.
2. Pick the provider type.
3. Create the notifier/controller class if the feature has logic.
4. Wrap that class in a top-level provider variable.
5. Watch the provider in the UI.
6. Read `provider.notifier` in callbacks to call methods.
7. Keep derived values in separate providers instead of recomputing them in widgets.

For a todos feature:

1. State shape: `List<Todo>`
2. Needs async load plus mutations: `AsyncNotifier`
3. Controller class: `TodosController`
4. Provider variable: `todosProvider`
5. UI watches `todosProvider`
6. Buttons call `ref.read(todosProvider.notifier).toggle(...)`
7. Filtered list becomes `filteredTodosProvider`

---

## Pick the right type

```
What are you storing?

  Read-only derived value?              → Provider<T>
  Small mutable scalar?                 → StateProvider<T>
  Sync state with methods?              → NotifierProvider<N, T>
  One-shot async load only?             → FutureProvider<T>
  Continuous stream?                    → StreamProvider<T>
  Async state with mutation methods?    → AsyncNotifierProvider<N, T>
```

Beginner shortcut:

- if it only exposes a value, use a provider
- if it needs methods, use a notifier
- if startup is async, use an async notifier

---

## The smallest useful example

```dart
class TodosController extends AsyncNotifier<List<Todo>> {
  @override
  Future<List<Todo>> build() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [const Todo(id: '1', title: 'Buy milk')];
  }

  Future<void> add(String title) async {
    final current = await future;
    state = AsyncData([
      ...current,
      Todo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
      ),
    ]);
  }

  Future<void> toggle(String id) async {
    final current = await future;
    state = AsyncData(
      current
          .map((todo) => todo.id == id
              ? todo.copyWith(done: !todo.done)
              : todo)
          .toList(),
    );
  }
}

final todosProvider =
    AsyncNotifierProvider<TodosController, List<Todo>>(
      TodosController.new,
    );
```

Read that in layers:

- `TodosController` is the logic class
- `build()` creates the initial state
- methods mutate the state
- `todosProvider` is what widgets actually use

---

## How widgets use it

### `ConsumerWidget`

This is the Riverpod version of `StatelessWidget`, but it gives you `ref`.

```dart
class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todosProvider);

    return todos.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
      data: (items) => ListView(
        children: [
          for (final todo in items)
            ListTile(
              title: Text(todo.title),
              onTap: () => ref.read(todosProvider.notifier).toggle(todo.id),
            ),
        ],
      ),
    );
  }
}
```

### `ConsumerStatefulWidget`

Use this only when the **widget** needs lifecycle, such as:

- `TextEditingController`
- `FocusNode`
- `AnimationController`
- one-time imperative widget setup

If the **data** needs loading, that still usually belongs in the provider.

---

## `watch`, `read`, and `listen`

| Method | Typical place | What it means |
|--------|----------------|---------------|
| `ref.watch(p)` | widget `build()` or derived provider | subscribe and rebuild/react when it changes |
| `ref.read(p)` | callback or method | read once, no subscription |
| `ref.listen(p, cb)` | side-effect wiring | run code when a provider changes |

```dart
final todos = ref.watch(todosProvider);
final notifier = ref.read(todosProvider.notifier);
```

- `todos` = current state for rendering
- `notifier` = the object whose methods you call

Common rule:

- render with `watch`
- mutate with `read(...notifier)`

---

## Provider types with practical use

### `Provider<T>`

Read-only and derived.

```dart
final greetingProvider = Provider<String>((ref) => 'Hello');
```

Use for:

- constants
- adapters
- derived values

Never has a notifier.

### `StateProvider<T>`

Simple mutable scalar.

```dart
final filterProvider = StateProvider<Filter>((ref) => Filter.all);
```

Use for:

- toggle
- selected tab
- small enum
- search query string

Avoid it for complex objects with many behaviors.

### `NotifierProvider<N, T>`

Synchronous state plus methods.

```dart
class CartController extends Notifier<List<Item>> {
  @override
  List<Item> build() => [];

  void add(Item item) {
    state = [...state, item];
  }
}

final cartProvider =
    NotifierProvider<CartController, List<Item>>(CartController.new);
```

Use when:

- no async initial fetch
- feature has real business logic
- state changes through methods

### `FutureProvider<T>`

One async load, no mutations.

```dart
final userProvider = FutureProvider<User>((ref) async {
  return api.fetchUser();
});
```

Use when the provider only needs to fetch and expose a result.

### `StreamProvider<T>`

For continuous stream data.

```dart
final messagesProvider = StreamProvider<List<Message>>((ref) {
  return firestore.collection('messages').snapshots().map(fromSnapshot);
});
```

### `AsyncNotifierProvider<N, T>`

Async load plus methods.

This is the Riverpod type most likely to feel natural for app features like:

- todos
- cart with server sync
- profile settings
- remote list with add/edit/delete

---

## Derived state belongs in providers

One of the biggest Riverpod wins is moving computed values out of widgets.

```dart
final filterProvider = StateProvider<Filter>((ref) => Filter.all);

final filteredTodosProvider = Provider<AsyncValue<List<Todo>>>((ref) {
  final todos = ref.watch(todosProvider);
  final filter = ref.watch(filterProvider);

  return todos.whenData((list) => switch (filter) {
        Filter.all => list,
        Filter.active => list.where((todo) => !todo.done).toList(),
        Filter.done => list.where((todo) => todo.done).toList(),
      });
});
```

That keeps widgets focused on presentation instead of transformation logic.

---

## `build()` in notifier classes

For `Notifier<T>`:

- `build()` returns the initial `T`

For `AsyncNotifier<T>`:

- `build()` returns `Future<T>`
- Riverpod exposes the result as `AsyncValue<T>`

So `build()` is not a widget build. It is the method Riverpod calls to create the notifier's initial state.

---

## Mutating state correctly

Riverpod works best with immutable updates.

Good:

```dart
state = [...state, newTodo];
```

Bad:

```dart
state.add(newTodo);
```

For async notifiers, prefer:

```dart
final current = await future;
```

over:

```dart
state.value!
```

because `await future` is safe while the initial load is still in progress.

---

## Modifiers

### `family`

Use when the provider needs an argument.

```dart
final userProvider = FutureProvider.family<User, String>(
  (ref, userId) => api.fetchUser(userId),
);

final user = ref.watch(userProvider('abc-123'));
```

### `autoDispose`

Use when the provider should die when the screen goes away.

```dart
final searchProvider =
    FutureProvider.autoDispose.family<List<User>, String>(
      (ref, query) => api.search(query),
    );
```

---

## Testing

```dart
test('add todo increments list', () async {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  await container.read(todosProvider.future);
  await container.read(todosProvider.notifier).add('Test');

  final todos = container.read(todosProvider).value!;
  expect(todos.length, 2);
});
```

This is one of Riverpod's biggest strengths:

- no widget tree
- no `BuildContext`
- pure Dart tests for feature logic

---

## Common beginner mistakes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| Instantiating the notifier in the widget | `ref.watch(...)` does not accept it | Declare a top-level provider variable |
| Putting package dependencies under `environment` | imports do not resolve | put packages under `dependencies` |
| Using `ref.watch` in a callback | `Bad state` exception | use `ref.read` |
| Mutating a list in place | UI does not update | assign a new list |
| Using `state.value!` during loading | throws | use `await future` |
| Doing derived filtering in the widget | cluttered UI code | move it to a provider |

---

## Bloc-to-Riverpod translation

If Bloc is the system you know best, use this mapping:

| Bloc / Cubit | Riverpod |
|-------------|----------|
| `Cubit`/`Bloc` class | `Notifier` / `AsyncNotifier` |
| `state` | `state` |
| `emit(newState)` | `state = newState` |
| `BlocProvider` | top-level provider + `ProviderScope` |
| `context.watch` / `BlocBuilder` | `ref.watch` |
| `context.read` | `ref.read` |

The biggest difference is ergonomic:

- Bloc exposes state machines through widget-tree providers
- Riverpod exposes state through top-level provider declarations

---

## Interview Q&A

**Q: Why can't you use `ref.watch` in a callback?**  
Because `watch` subscribes for rebuilds. Callbacks are not a rebuild context.

**Q: Why does mutating a `List` in place not update the UI?**  
Because Riverpod needs a new assigned state value to notify listeners.

**Q: When should I choose `AsyncNotifierProvider` over `FutureProvider`?**  
When the feature both loads asynchronously and exposes mutation methods.

**Q: When should I use `ConsumerStatefulWidget`?**  
When the widget itself owns lifecycle objects like controllers or focus nodes, not just because data is async.
