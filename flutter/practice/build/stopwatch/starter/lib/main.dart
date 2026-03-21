// Build exercise: Stopwatch
//
// A stopwatch whose display is driven by a reactive data source —
// not a setState loop or an AnimationController. The UI rebuilds
// only when the stream emits, and all resources are released when
// the widget leaves the tree.
//
// Behaviours to implement:
//   - Display elapsed time as mm:ss, updating every second
//   - Start, Pause / Resume, Reset buttons
//   - Pausing freezes the count; resuming continues from where it left off
//   - No errors in the console after navigating away
//
// → See README.md for full requirements and approach notes.
// → See SOLUTIONS.md for a reference implementation and rubric.

import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const StopwatchApp());

// ── State ─────────────────────────────────────────────────────────────────────
// TODO: implement your stream-based timing logic here

// ── App ───────────────────────────────────────────────────────────────────────

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
            // TODO: replace with a reactive display
            Text('00:00', style: Theme.of(context).textTheme.displayLarge),
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
