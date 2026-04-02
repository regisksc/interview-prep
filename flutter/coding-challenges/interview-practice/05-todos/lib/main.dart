import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ❌ Everything in one file. No separation.

void main() => runApp(const MaterialApp(home: TodosScreen()));

class Todo {
  final int id;
  final String todo;
  bool completed;
  final int userId;

  Todo({
    required this.id,
    required this.todo,
    required this.completed,
    required this.userId,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      todo: json['todo'],
      completed: json['completed'],
      userId: json['userId'],
    );
  }
}

// ❌ Algorithm stub — implement stable partition
// "do now": completed=false AND userId <= 5
// "do later": everything else
// Preserve original order within each group
List<Todo> stablePartition(List<Todo> todos) {
  return todos;
}

class TodosScreen extends StatefulWidget {
  const TodosScreen({super.key});

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  List<Todo> todos = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  // ❌ Network logic inside the widget
  Future<void> _fetch() async {
    setState(() { isLoading = true; error = null; });
    try {
      final response = await http.get(
        Uri.parse('https://dummyjson.com/todos?limit=30'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = (data['todos'] as List).map((e) => Todo.fromJson(e)).toList();
        setState(() { todos = list; isLoading = false; });
      } else {
        setState(() { error = 'Status ${response.statusCode}'; isLoading = false; });
      }
    } catch (e) {
      setState(() { error = e.toString(); isLoading = false; });
    }
  }

  void _toggle(int index) {
    setState(() {
      todos[index].completed = !todos[index].completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = todos.where((t) => !t.completed).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Todos ($activeCount active)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              setState(() {
                final sorted = stablePartition(todos);
                todos = sorted;
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(error!, style: const TextStyle(color: Colors.red)),
                      ElevatedButton(onPressed: _fetch, child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetch,
                  child: ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final t = todos[index];
                      // ❌ Tile UI inline — should be a separate widget
                      return CheckboxListTile(
                        value: t.completed,
                        onChanged: (_) => _toggle(index),
                        title: Text(
                          t.todo,
                          style: TextStyle(
                            decoration: t.completed ? TextDecoration.lineThrough : null,
                            color: t.completed ? Colors.grey : null,
                          ),
                        ),
                        subtitle: Text('User ${t.userId}'),
                      );
                    },
                  ),
                ),
    );
  }
}
