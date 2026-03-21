// Challenge: Riverpod — Async Todo List
//
// Build a todo list where data loads asynchronously on startup and every
// mutation (add, toggle, delete) updates the UI reactively. A filter bar
// switches between All / Active / Done views via a derived provider.
//
// Concepts in play: AsyncNotifierProvider, StateProvider, derived Provider,
// AsyncValue (loading / error / data), ref.watch, ref.read, ref.invalidate.
//
// What to build:
//   - TodosNotifier extends AsyncNotifier<List<Todo>>
//       · build() simulates a 600 ms load, returns a seed list
//       · add(String title), toggle(String id), delete(String id)
//   - filterProvider  →  StateProvider<Filter>
//   - filteredTodosProvider  →  derived Provider combining todos + filter
//   - UI: filter chips, AsyncValue.when() list, add FAB with a dialog

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() => runApp(const ProviderScope(child: TodoApp()));

// ── Domain ────────────────────────────────────────────────────────────────────

enum Filter { all, active, done }

class Todo {
  final String id;
  final String title;
  final bool done;

  const Todo({required this.id, required this.title, this.done = false});

  Todo copyWith({String? title, bool? done}) =>
      Todo(id: id, title: title ?? this.title, done: done ?? this.done);
}

// ── Providers ─────────────────────────────────────────────────────────────────

// TODO: implement TodosNotifier + todosProvider (AsyncNotifierProvider)
// TODO: implement filterProvider (StateProvider<Filter>)
// TODO: implement filteredTodosProvider (derived Provider<AsyncValue<List<Todo>>>)

// ── App ───────────────────────────────────────────────────────────────────────

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Todos',
        theme: ThemeData(
            colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
        home: const TodoScreen(),
      );
}

class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: watch filteredTodosProvider and filterProvider

    return Scaffold(
      appBar: AppBar(title: const Text('Todos')),
      body: Column(
        children: [
          // TODO: SegmentedButton or FilterChip row for Filter.values
          Expanded(
            // TODO: asyncTodos.when(loading: ..., error: ..., data: ...)
            child: const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: show a dialog, then ref.read(todosProvider.notifier).add(title)
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
