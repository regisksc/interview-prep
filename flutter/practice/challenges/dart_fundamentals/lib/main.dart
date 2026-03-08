import 'package:flutter/material.dart';

void main() => runApp(const ShoppingApp());

class ShoppingApp extends StatelessWidget {
  const ShoppingApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Shopping List',
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        home: const ShoppingScreen(),
      );
}

class ShoppingItem {
  final String name;
  final bool bought;

  const ShoppingItem({required this.name, this.bought = false});

  ShoppingItem copyWith({String? name, bool? bought}) => ShoppingItem(
        name: name ?? this.name,
        bought: bought ?? this.bought,
      );
}

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});
  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final List<ShoppingItem> _items = [];
  final TextEditingController _controller = TextEditingController();

  void _addItem(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final newItem = ShoppingItem(name: trimmed);
    if (_items.contains(newItem)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item already in list')),
      );
      return;
    }
    setState(() => _items.add(newItem));
    _controller.clear();
  }

  void _toggleBought(int index) {
    _items[index].copyWith(bought: !_items[index].bought);
    setState(() {});
  }

  void _clearBought() {
    for (final item in _items) {
      if (item.bought) _items.remove(item);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boughtCount = _items.where((i) => i.bought).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          TextButton(
            onPressed: _clearBought,
            child: const Text('Clear bought'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Add item',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _addItem,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => _addItem(_controller.text),
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$boughtCount / ${_items.length} bought',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return CheckboxListTile(
                  title: Text(
                    item.name,
                    style: item.bought
                        ? const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                  value: item.bought,
                  onChanged: (_) => _toggleBought(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
