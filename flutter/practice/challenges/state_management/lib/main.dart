import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() => runApp(const ProviderScope(child: CounterApp()));

final counterProvider = StateProvider<int>((ref) => 0);

final doubledProvider = Provider<int>((ref) {
  final count = ref.read(counterProvider);
  return count * 2;
});

class HistoryNotifier extends Notifier<List<int>> {
  @override
  List<int> build() => [];

  void add(int value) {
    state.add(value);
  }
}

final historyProvider =
    NotifierProvider<HistoryNotifier, List<int>>(HistoryNotifier.new);

class CounterApp extends StatelessWidget {
  const CounterApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Counter + History',
        theme:
            ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
        home: const CounterScreen(),
      );
}

class CounterScreen extends ConsumerWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    final doubled = ref.watch(doubledProvider);
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Count: $count',
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            Text(
              'Doubled: $doubled',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final current = ref.watch(counterProvider);
                ref.read(counterProvider.notifier).state = current - 1;
                ref.read(historyProvider.notifier).add(current - 1);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
              child: const Text('Decrement'),
            ),
            const SizedBox(height: 32),
            const Divider(),
            Text('History', style: Theme.of(context).textTheme.titleMedium),
            Expanded(
              child: history.isEmpty
                  ? const Center(child: Text('No changes yet'))
                  : ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (_, i) => ListTile(
                        leading: const Icon(Icons.history),
                        title: Text('Value: ${history[i]}'),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final next = ref.read(counterProvider) + 1;
          ref.read(counterProvider.notifier).state = next;
          ref.read(historyProvider.notifier).add(next);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
