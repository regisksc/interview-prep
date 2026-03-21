// Challenge: RxDart — Live Search
//
// Build a search screen that queries a local dataset reactively.
// Keystrokes are debounced so the search only runs 300 ms after the user
// stops typing. Switching queries mid-flight cancels the previous search.
// A loading indicator appears between the debounce and the result.
//
// Concepts in play: BehaviorSubject, debounceTime, switchMap, distinct,
// StreamBuilder, Subject lifecycle.
//
// What to build:
//   - A text field whose value is pushed into a BehaviorSubject<String>
//   - A stream pipeline: distinct → debounceTime(300ms) → switchMap(_search)
//   - Three UI states driven by the stream: idle, loading, results

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

void main() => runApp(const SearchApp());

class SearchApp extends StatelessWidget {
  const SearchApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Live Search',
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        home: const SearchScreen(),
      );
}

// Simulates a remote search with artificial latency.
Future<List<String>> _search(String query) async {
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

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // TODO: declare a BehaviorSubject<String> for the query
  // TODO: build the results stream pipeline from the subject

  @override
  void dispose() {
    // TODO: close the subject
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
                // TODO: push v into the subject
              },
            ),
          ),
          Expanded(
            // TODO: StreamBuilder on your results stream
            // null snapshot  → idle ("Start typing...")
            // waiting        → CircularProgressIndicator
            // data           → ListView or "No results"
            child: const Center(child: Text('Start typing to search')),
          ),
        ],
      ),
    );
  }
}
