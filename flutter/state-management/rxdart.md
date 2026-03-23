# RxDart

**Practice:** `practice/build/live_search/`, `practice/build/stopwatch/` · **Interview guide:** `README.md` → Module 5

---

## What is ReactiveX?

ReactiveX is a model for composing asynchronous event streams using functional operators. RxDart extends Dart's native `Stream` with:

- **Subjects** — `StreamController`s that cache and replay values
- **Operators** — `debounceTime`, `switchMap`, `combineLatest`, and more
- **`ValueStream`** — streams that always have a synchronously accessible current value

```yaml
dependencies:
  rxdart: ^0.28.0
```

RxDart is not a replacement for Riverpod — it is a toolkit for building reactive pipelines that can feed into Riverpod via `StreamProvider`, or be consumed directly with `StreamBuilder`.

---

## Subjects

A `Subject` is simultaneously a `StreamController` (you push values into it) and a `Stream` (you listen to it).

### `PublishSubject` — no replay

```dart
final subject = PublishSubject<String>();

subject.stream.listen(print);

subject.add('hello'); // prints: hello
subject.add('world'); // prints: world

// Late subscriber misses previous values:
subject.stream.listen(print); // nothing until next add()

subject.close(); // always close in dispose()
```

### `BehaviorSubject` — replays the latest value

```dart
final subject = BehaviorSubject<String>.seeded('initial');

subject.add('updated');

// New subscriber immediately gets 'updated':
subject.stream.listen(print); // prints: updated immediately

print(subject.value); // 'updated' — synchronous access to latest value
```

Use `BehaviorSubject` for search queries, form fields, and anything where a new subscriber needs the current value immediately.

### `ReplaySubject` — replays the last N values

```dart
final subject = ReplaySubject<int>(maxSize: 3);
subject.add(1);
subject.add(2);
subject.add(3);
subject.add(4);

// New subscriber gets 2, 3, 4 (the last 3):
subject.stream.listen(print);
```

| Subject | New subscriber receives | Synchronous `.value` | Use for |
|---------|------------------------|----------------------|---------|
| `PublishSubject` | Nothing | No | Click events, navigation triggers |
| `BehaviorSubject` | Latest value | Yes | Search query, current user, form fields |
| `ReplaySubject(n)` | Last n values | No | Undo history, recent events |

---

## Key operators

### `debounceTime` — wait for input to settle

```dart
subject.stream
    .debounceTime(const Duration(milliseconds: 300))
    .listen(print);

subject.add('h');
subject.add('he');
subject.add('hel');
// 300 ms of silence...
// prints: hel  (only the last value after the gap)
```

### `distinct` — skip consecutive duplicate values

```dart
subject.stream
    .distinct()
    .listen(print);

subject.add('a'); // prints: a
subject.add('a'); // skipped
subject.add('b'); // prints: b
```

Always put `distinct()` **before** `debounceTime`. Placing it after wastes a timer cycle on a value that hasn't changed.

### `switchMap` — cancel previous, start new

```dart
final results = querySubject.stream
    .distinct()
    .debounceTime(const Duration(milliseconds: 300))
    .switchMap((query) => Stream.fromFuture(search(query)));
```

When a new outer value arrives, `switchMap` unsubscribes from the previous inner stream and subscribes to a new one. Only the latest operation's result is emitted.

**vs `flatMap` (`asyncExpand`):** `flatMap` merges all inner streams concurrently. If query A takes 1 s and query B takes 0.1 s, B's results arrive first but A's arrive later and overwrite them. `switchMap` cancels A the moment B starts — stale results are impossible.

### `combineLatest` — emit when any source changes

```dart
final isValid = Rx.combineLatest2(
  usernameSubject.stream,
  passwordSubject.stream,
  (String u, String p) => u.isNotEmpty && p.length >= 8,
);

isValid.listen((valid) => setState(() => _isValid = valid));
```

Emits whenever **any** source emits a new value, using the latest value from all others. Unlike `zip`, it does not wait for all sources to emit a new matching event.

### `zip` — pair elements one-to-one

```dart
final zipped = Rx.zip2(
  Stream.fromIterable([1, 2, 3]),
  Stream.fromIterable(['a', 'b', 'c']),
  (int n, String s) => '$n$s',
);
// emits: '1a', '2b', '3c'
```

Waits for both streams to produce a matching element before emitting. Slower stream controls the pace.

### `scan` — accumulate over time

```dart
subject.stream
    .scan<int>((acc, val, _) => acc + val, 0)
    .listen(print);

subject.add(1); // prints: 1
subject.add(2); // prints: 3
subject.add(3); // prints: 6
```

Like `reduce` but emits each intermediate result. Useful for running totals, undo history, and accumulated state.

---

## The canonical reactive search pattern

```dart
class _SearchScreenState extends State<SearchScreen> {
  // Input sink
  final _query = BehaviorSubject<String>.seeded('');

  // Pipeline — built once as a field, never inside build()
  late final Stream<List<String>?> _results = _query.stream
      .distinct()
      .debounceTime(const Duration(milliseconds: 300))
      .switchMap((q) => q.isEmpty
          ? Stream.value(null)          // null → idle state
          : Stream.fromFuture(search(q)));

  @override
  void dispose() {
    _query.close(); // leaks a stream if omitted
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextField(onChanged: _query.add),
      Expanded(
        child: StreamBuilder<List<String>?>(
          stream: _results,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text('Start typing...');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            final items = snapshot.data!;
            if (items.isEmpty) return const Text('No results');
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) => ListTile(title: Text(items[i])),
            );
          },
        ),
      ),
    ]);
  }
}
```

`_results` is `late final` — built once and reused across rebuilds. If you build the pipeline inside `build()`, a new stream is created on every frame, breaking debounce and creating multiple subscriptions.

---

## Integrating with Riverpod

RxDart pipelines compose cleanly with Riverpod's `StreamProvider`:

```dart
// Expose a Subject's pipeline as a Riverpod provider
final _querySubject = BehaviorSubject<String>.seeded('');

final searchResultsProvider = Provider<Stream<List<String>?>>((ref) {
  return _querySubject.stream
      .distinct()
      .debounceTime(const Duration(milliseconds: 300))
      .switchMap((q) => q.isEmpty
          ? Stream.value(null)
          : Stream.fromFuture(search(q)));
});

// In a widget:
final resultsStream = ref.watch(searchResultsProvider);
return StreamBuilder<List<String>?>(stream: resultsStream, builder: ...);
```

---

## Common mistakes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| Building pipeline inside `build()` | New subscription every frame, debounce never fires | `late final` field |
| `flatMap` instead of `switchMap` | Stale results overwrite fresh ones | Use `switchMap` |
| Not closing subject in `dispose` | Stream leak, `setState after dispose` errors | `_subject.close()` in `dispose` |
| `distinct()` after `debounceTime` | Debounce resets on repeated same value | `distinct()` before `debounceTime` |
| Forgetting `Stream.value(null)` for empty query | Idle state shows last results | Emit `null` explicitly for idle |

---

## Interview Q&A

**Q: What is the difference between `switchMap` and `flatMap`?**
`flatMap` (`asyncExpand`) merges all inner streams concurrently — results arrive in completion order, so a slow earlier query can overwrite a fast recent one. `switchMap` cancels the previous inner stream when a new outer value arrives — only the latest result is ever emitted. For search, `switchMap` is always correct.

**Q: When would you use `BehaviorSubject` over `PublishSubject`?**
`BehaviorSubject` when the latest value must be immediately available to new subscribers — form fields, search queries, current user state. `PublishSubject` when you only care about future events and history is irrelevant — button clicks, navigation events.

**Q: What happens if you forget to close a `Subject`?**
The underlying `StreamController` is never closed. Any subscription listening to it is never cancelled. If the listening widget is disposed, `setState` is called on a dead `State` — the same class of bug as forgetting `StreamSubscription.cancel()`.

**Q: Why does operator order matter for `distinct()` and `debounceTime`?**
`distinct()` before `debounceTime` means a repeated value is dropped before it ever reaches the timer — the debounce clock is not reset. After `debounceTime`, the timer fires for the repeated value and then `distinct` drops the result silently. The first ordering is more correct and slightly more efficient.

**Q: How does `scan` differ from `reduce`?**
`reduce` accumulates and emits only a single final value when the stream closes. `scan` emits each intermediate accumulated value as events arrive — the stream never needs to close to be useful. `scan` is the right tool for live totals, running histories, and any state that evolves continuously.
