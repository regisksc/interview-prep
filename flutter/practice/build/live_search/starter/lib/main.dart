// Build exercise: Live Search
//
// A search screen that queries a dataset reactively as the user types.
// The search should not fire on every keystroke — it waits until input
// settles. If a new query arrives while a search is in flight, the
// previous one is cancelled. A loading indicator appears between
// the input settling and the results arriving.
//
// Behaviours to implement:
//   - Debounce: search fires ~300 ms after the user stops typing
//   - Cancellation: a new query cancels any in-flight search
//   - Three UI states: idle (empty query), loading, results / empty
//
// → See README.md for full requirements and approach notes.
// → See SOLUTIONS.md for a reference implementation and rubric.

import 'package:flutter/material.dart';

void main() => runApp(const SearchApp());

// ── Data ──────────────────────────────────────────────────────────────────────

// Simulates a remote search with artificial latency.
Future<List<String>> search(String query) async {
  await Future.delayed(const Duration(milliseconds: 400));
  if (query.isEmpty) return [];
  const data = [
    'Apple', 'Apricot', 'Avocado', 'Banana', 'Blueberry',
    'Cherry', 'Coconut', 'Date', 'Elderberry', 'Fig',
    'Grape', 'Guava', 'Kiwi', 'Lemon', 'Lime',
    'Mango', 'Melon', 'Orange', 'Papaya', 'Peach',
    'Pear', 'Pineapple', 'Plum', 'Pomegranate', 'Raspberry',
    'Strawberry', 'Watermelon',
  ];
  return data
      .where((s) => s.toLowerCase().contains(query.toLowerCase()))
      .toList();
}

// ── State ─────────────────────────────────────────────────────────────────────
// TODO: implement your reactive query pipeline here

// ── App ───────────────────────────────────────────────────────────────────────

class SearchApp extends StatelessWidget {
  const SearchApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Live Search',
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        home: const SearchScreen(),
      );
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void dispose() {
    // TODO: clean up any stream subscriptions or subjects
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Fruits')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {
                // TODO: push value into your reactive pipeline
              },
            ),
          ),
          const Expanded(
            // TODO: render idle / loading / results states
            child: Center(child: Text('Start typing to search')),
          ),
        ],
      ),
    );
  }
}
