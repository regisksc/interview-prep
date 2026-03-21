// Build exercise: Todo List
//
// A todo list where data loads asynchronously on startup.
// Every mutation (add, toggle, delete) updates the UI reactively.
// A filter bar switches between All / Active / Done views.
// The filtered list is computed outside of build().
//
// Behaviours to implement:
//   - 600 ms simulated load on startup; show a loading indicator during it
//   - Add a todo via a FAB + dialog
//   - Toggle and delete individual todos
//   - Filter chips / segments: All / Active / Done
//   - Filtered list reacts automatically when todos or filter changes
//
// → See README.md for full requirements and approach notes.
// → See SOLUTIONS.md for a reference implementation and rubric.

import 'package:flutter/material.dart';

void main() => runApp(const TodoApp());

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

// ── State / Providers ─────────────────────────────────────────────────────────
// TODO: implement your state layer here

// ── App ───────────────────────────────────────────────────────────────────────

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Todos',
        theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
        home: const TodoScreen(),
      );
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});
  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  // TODO: wire up state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todos')),
      body: Column(
        children: [
          // TODO: filter chips / segmented button
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: show dialog, add todo
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
