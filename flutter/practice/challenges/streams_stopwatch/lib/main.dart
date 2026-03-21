// Challenge: Vanilla Streams — Stopwatch
//
// Build a stopwatch using only Dart streams. No packages, no setState,
// no AnimationController — the UI must be driven entirely by a Stream<int>
// that emits elapsed seconds.
//
// Concepts in play: Stream.periodic, StreamController, StreamBuilder,
// stream lifecycle, pause / resume / cancel.
//
// What to build:
//   - A screen showing elapsed time as mm:ss
//   - Start / Pause / Resume / Reset buttons
//   - The display updates once per second driven by a stream
//   - Navigating away and back must not leak the stream

import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const StopwatchApp());

class StopwatchApp extends StatelessWidget {
  const StopwatchApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Stopwatch',
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        home: const StopwatchScreen(),
      );
}

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});
  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  // TODO: declare your stream, subscription, and any elapsed-seconds state

  @override
  void dispose() {
    // TODO: cancel / close any streams or controllers
    super.dispose();
  }

  String _format(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stopwatch')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: replace with a StreamBuilder that reads from your stream
            Text(
              '00:00',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // TODO: wire up Start / Pause / Resume / Reset
                FilledButton(onPressed: null, child: const Text('Start')),
                const SizedBox(width: 12),
                OutlinedButton(onPressed: null, child: const Text('Reset')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
