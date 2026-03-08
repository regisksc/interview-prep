import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// The ProviderScope is already wired up. Everything below this line is your
// canvas — delete the placeholder and build the Notes app following README.md.

void main() => runApp(const ProviderScope(child: NotesApp()));

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Notes',
        theme: ThemeData(colorSchemeSeed: Colors.amber, useMaterial3: true),
        home: const Scaffold(
          body: Center(child: Text('Start building — see README.md')),
        ),
      );
}
