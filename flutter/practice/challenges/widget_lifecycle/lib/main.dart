// Challenge: Widget Lifecycle — Live Score
//
// A two-screen app that simulates a live match score updating every 2 seconds,
// with a pulse animation on each increment and an async save action.
//
// Concepts in play: initState / dispose, Timer, AnimationController,
// async operations with BuildContext across await gaps.
//
// Known issues (3 bugs):
//   - After navigating back from the match screen, the console keeps printing errors.
//   - Tapping "Save score" and immediately navigating back causes a crash.
//   - Navigating in and out of the screen repeatedly leaks memory each time.

import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const ScoreApp());

class ScoreApp extends StatelessWidget {
  const ScoreApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Live Score',
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        home: const HomeScreen(),
      );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Live Score')),
        body: Center(
          child: FilledButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScoreDetailScreen()),
            ),
            child: const Text('Watch live match'),
          ),
        ),
      );
}

class ScoreDetailScreen extends StatefulWidget {
  const ScoreDetailScreen({super.key});
  @override
  State<ScoreDetailScreen> createState() => _ScoreDetailScreenState();
}

class _ScoreDetailScreenState extends State<ScoreDetailScreen>
    with SingleTickerProviderStateMixin {
  int _score = 0;
  // ignore: unused_field
  Timer? _timer;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() {
        _score++;
        _pulse.forward(from: 0);
      });
    });
  }

  Future<void> _saveScore() async {
    await Future.delayed(const Duration(seconds: 2));
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Score $_score saved!')),
    );
  }

  @override
  void dispose() {
    // TODO: clean up resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match Score')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: Tween(begin: 1.0, end: 1.3).animate(_pulse),
              child: Text(
                '$_score',
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saveScore,
              child: const Text('Save score'),
            ),
          ],
        ),
      ),
    );
  }
}
