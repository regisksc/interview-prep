# Solution — Riverpod: Async Todo List

## Reference Implementation

```dart
// ── Notifier ──────────────────────────────────────────────────────────────────

class TodosNotifier extends AsyncNotifier<List<Todo>> {
  @override
  Future<List<Todo>> build() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      const Todo(id: '1', title: 'Buy milk'),
      const Todo(id: '2', title: 'Read a book'),
      const Todo(id: '3', title: 'Go for a run', done: true),
    ];
  }

  Future<void> add(String title) async {
    final current = await future;
    state = AsyncData([
      ...current,
      Todo(id: DateTime.now().millisecondsSinceEpoch.toString(), title: title),
    ]);
  }

  Future<void> toggle(String id) async {
    final current = await future;
    state = AsyncData(
      current.map((t) => t.id == id ? t.copyWith(done: !t.done) : t).toList(),
    );
  }

  Future<void> delete(String id) async {
    final current = await future;
    state = AsyncData(current.where((t) => t.id != id).toList());
  }
}

final todosProvider =
    AsyncNotifierProvider<TodosNotifier, List<Todo>>(TodosNotifier.new);

// ── Filter ────────────────────────────────────────────────────────────────────

final filterProvider = StateProvider<Filter>((ref) => Filter.all);

final filteredTodosProvider = Provider<AsyncValue<List<Todo>>>((ref) {
  final todos = ref.watch(todosProvider);
  final filter = ref.watch(filterProvider);
  return todos.whenData((list) => switch (filter) {
        Filter.all    => list,
        Filter.active => list.where((t) => !t.done).toList(),
        Filter.done   => list.where((t) => t.done).toList(),
      });
});
```

**UI — filter chips + async list:**
```dart
Widget build(BuildContext context, WidgetRef ref) {
  final asyncTodos = ref.watch(filteredTodosProvider);
  final filter = ref.watch(filterProvider);

  return Scaffold(
    appBar: AppBar(title: const Text('Todos')),
    body: Column(
      children: [
        SegmentedButton<Filter>(
          segments: const [
            ButtonSegment(value: Filter.all,    label: Text('All')),
            ButtonSegment(value: Filter.active, label: Text('Active')),
            ButtonSegment(value: Filter.done,   label: Text('Done')),
          ],
          selected: {filter},
          onSelectionChanged: (s) =>
              ref.read(filterProvider.notifier).state = s.first,
        ),
        Expanded(
          child: asyncTodos.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (todos) => ListView.builder(
              itemCount: todos.length,
              itemBuilder: (_, i) {
                final todo = todos[i];
                return ListTile(
                  title: Text(todo.title),
                  leading: Checkbox(
                    value: todo.done,
                    onChanged: (_) =>
                        ref.read(todosProvider.notifier).toggle(todo.id),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () =>
                        ref.read(todosProvider.notifier).delete(todo.id),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () async {
        final title = await showDialog<String>(
          context: context,
          builder: (_) => const _AddTodoDialog(),
        );
        if (title != null && title.isNotEmpty) {
          ref.read(todosProvider.notifier).add(title);
        }
      },
      child: const Icon(Icons.add),
    ),
  );
}
```

**Key decisions:**
- `AsyncNotifier.build()` returns a `Future` — Riverpod wraps it in `AsyncValue.loading` automatically during the delay.
- Mutations call `await future` to get the current list safely, then assign a new `AsyncData` — the UI stays in `data` state during mutations (no loading flash).
- `filteredTodosProvider` is a derived `Provider<AsyncValue<...>>` — it wraps the async state with `whenData` so filtering logic never has to deal with loading/error cases.
- Filter state lives in `StateProvider` — simple scalar, no notifier needed.
- `ref.watch` in the derived provider ensures it re-evaluates whenever either `todosProvider` or `filterProvider` changes.

---

## Rubric

### Hard Approved
- Uses `AsyncNotifier` (not `Notifier<List<Todo>>` + manual `Future`) — understands the purpose of `AsyncNotifier.build()` as the async initialiser.
- Mutations use `await future` (not `state.value!`) — knows `state.value` throws if still loading, while `await future` waits safely.
- Derived provider uses `whenData` so the filtering logic is pure (only runs when data is available) and the `AsyncValue` type is preserved for the UI.
- `ref.watch` used correctly in the derived provider (not `ref.read`).
- Bonus: knows `ref.invalidate(todosProvider)` as a way to force a reload and when to prefer it over direct state mutation.
- Bonus: can discuss `autoDispose` — when to use it on `todosProvider` and what `keepAlive()` is for.
- Bonus: can explain why `filteredTodosProvider` returns `AsyncValue<List<Todo>>` instead of just `List<Todo>`.

### Soft Approved
- Completes the feature but mutations call `state = AsyncLoading()` before updating — works, but causes a loading spinner flash on every add/toggle/delete.
- Uses `state.value ?? []` in mutations instead of `await future` — fragile during initial load but passes in practice.
- Derived provider correctly uses `ref.watch` but computed inline in `build()` with `ref.watch(todosProvider).whenData(...)` — correct but misses the point of derived providers.
- Filter works but uses `StateNotifier<Filter>` where `StateProvider<Filter>` is the simpler and idiomatic choice.

### Rejected
- Does not use `AsyncNotifier` — implements as `Notifier<List<Todo>>` with a `Future` field managed manually.
- Cannot explain `AsyncValue` or its three states (loading / error / data).
- Computes filtering inside `build()` — same anti-pattern as the performance challenge.
- Uses `ref.read(todosProvider)` in the derived provider — the derived provider never updates when todos change.
- Does not know what `whenData` is or tries to pattern-match with an `if` on `AsyncValue` subclasses.
