// Challenge: Async & Streams — Live Feed
//
// An event feed that subscribes to a continuous stream of random events.
// Each event can be archived individually or all at once via a simulated
// async network call.
//
// Concepts in play: StreamSubscription lifecycle, await in try/catch,
// parallel vs sequential async operations.
//
// Known issues (3 bugs):
//   - Navigating back from the feed leaves errors printing in the console indefinitely.
//   - Archiving a "Logout" event shows a success message instead of an error.
//   - "Archive all" is far slower than it should be given the network latency.

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const FeedApp());

class FeedApp extends StatelessWidget {
  const FeedApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Live Feed',
        theme: ThemeData(colorSchemeSeed: Colors.orange, useMaterial3: true),
        home: const HomeScreen(),
      );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Live Feed')),
        body: Center(
          child: FilledButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FeedScreen()),
            ),
            child: const Text('Open Feed'),
          ),
        ),
      );
}

// Simulates a stream of random events.
Stream<String> _eventStream() async* {
  final rng = Random();
  final events = ['Login', 'Purchase', 'View', 'Click', 'Logout'];
  while (true) {
    await Future.delayed(const Duration(seconds: 1));
    yield events[rng.nextInt(events.length)];
  }
}

// Simulates saving an event to a remote server.
Future<void> _saveEvent(String event) async {
  await Future.delayed(const Duration(milliseconds: 800));
  if (event == 'Logout') throw Exception('Cannot archive logout events');
}

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final List<String> _events = [];
  // ignore: unused_field
  StreamSubscription<String>? _subscription;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _subscription = _eventStream().listen((event) {
      setState(() => _events.insert(0, event));
    });
  }

  Future<void> _archive(String event) async {
    try {
      _saveEvent(event);
      setState(() => _status = '$event archived');
    } catch (e) {
      setState(() => _status = 'Failed: $e');
    }
  }

  Future<void> _archiveAll() async {
    final toArchive = List<String>.from(_events);
    await Future.forEach(toArchive, (String e) => _saveEvent(e));
    setState(() => _status = 'All ${toArchive.length} events archived');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        actions: [
          TextButton(
            onPressed: _archiveAll,
            child: const Text('Archive all'),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_status.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(_status,
                  style: Theme.of(context).textTheme.bodySmall),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _events.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(_events[i]),
                trailing: IconButton(
                  icon: const Icon(Icons.archive_outlined),
                  onPressed: () => _archive(_events[i]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
