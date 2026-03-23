# RxDart

**Practice:** `practice/build/live_search/`, `practice/build/stopwatch/` · **Interview guide:** `README.md` → Module 5

---

## Start here

If Riverpod answers, "Where does app state live?", RxDart answers, "How do I transform a stream of events over time?"

RxDart is not a replacement for Riverpod or Bloc. It is a **stream toolkit**.

Use it when the hard part of the feature is not storing state, but handling event flow:

- debounce user input
- cancel stale requests
- merge multiple live sources
- accumulate values over time

If Bloc is already familiar to you, the closest bridge is this:

- `restartable()` in Bloc feels like `switchMap`
- `droppable()` feels like "ignore while busy"
- RxDart just gives you those stream ideas directly

```yaml
dependencies:
  rxdart: ^0.28.0
```

---

## The normal feature flow

This is the usual way an RxDart feature gets built:

1. Identify the input stream.
2. Choose the right subject or source.
3. Build one pipeline from that input.
4. Keep the pipeline outside `build()`.
5. Render the output stream with `StreamBuilder`, Riverpod, or Bloc.
6. Close subjects in `dispose()`.

Typical examples:

- live search
- autocomplete
- form validation from multiple fields
- stopwatch/timer pipelines
- live filters from multiple controls

If the feature is simple "load once, render once", RxDart is usually unnecessary.

---

## Mental model

Think in three parts:

- **input**: events going in
- **pipeline**: operators transforming those events
- **output**: the stream the UI or state layer consumes

For search:

- input: text changes
- pipeline: `distinct` -> `debounceTime` -> `switchMap`
- output: latest search results

That is the heart of RxDart.

---

## Subjects

A `Subject` is both:

- a place you can push values into
- a stream you can listen to

### `PublishSubject`

No replay. New listeners only get future events.

```dart
final subject = PublishSubject<String>();
subject.add('hello');
subject.stream.listen(print);
```

Use for:

- button clicks
- one-off events
- navigation triggers

### `BehaviorSubject`

Replays the latest value to new listeners.

```dart
final query = BehaviorSubject<String>.seeded('');
query.add('riverpod');
print(query.value);
```

Use for:

- search query
- current filter
- form field state
- any stream where the latest value matters immediately

This is the subject beginners usually need most.

### `ReplaySubject`

Replays the last `n` values.

```dart
final history = ReplaySubject<int>(maxSize: 3);
```

Use for:

- short history
- undo-like flows
- debugging recent events

| Subject | New subscriber gets | Has current value |
|---------|---------------------|-------------------|
| `PublishSubject` | nothing old | no |
| `BehaviorSubject` | latest value | yes |
| `ReplaySubject` | recent history | no |

---

## The operators you should know first

### `debounceTime`

Wait for input to settle.

```dart
query.stream
    .debounceTime(const Duration(milliseconds: 300))
    .listen(print);
```

Use for:

- typing
- sliders
- noisy repeated input

### `distinct`

Skip consecutive duplicates.

```dart
query.stream
    .distinct()
    .listen(print);
```

Use before `debounceTime` in search-like pipelines.

### `switchMap`

Cancel the previous async work when a new value arrives.

```dart
final results = query.stream
    .distinct()
    .debounceTime(const Duration(milliseconds: 300))
    .switchMap((text) => Stream.fromFuture(search(text)));
```

This is the most important RxDart operator for app work.

If query `abc` starts, then query `abcd` starts, `switchMap` throws away the old one and keeps the latest.

### `combineLatest`

Recompute when any source changes.

```dart
final isValid = Rx.combineLatest2(
  username.stream,
  password.stream,
  (String u, String p) => u.isNotEmpty && p.length >= 8,
);
```

Great for:

- multi-field forms
- filters
- combining user/session/config streams

### `scan`

Accumulate over time while still emitting intermediate values.

```dart
numbers.stream
    .scan<int>((sum, value, _) => sum + value, 0)
    .listen(print);
```

Good for:

- totals
- histories
- state built from event sequences

---

## The most common real-world example: search

```dart
class _SearchScreenState extends State<SearchScreen> {
  final _query = BehaviorSubject<String>.seeded('');

  late final Stream<List<String>?> _results = _query.stream
      .distinct()
      .debounceTime(const Duration(milliseconds: 300))
      .switchMap(
        (text) => text.isEmpty
            ? Stream.value(null)
            : Stream.fromFuture(search(text)),
      );

  @override
  void dispose() {
    _query.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(onChanged: _query.add),
        Expanded(
          child: StreamBuilder<List<String>?>(
            stream: _results,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.data == null) return const Text('Start typing...');
              final items = snapshot.data!;
              if (items.isEmpty) return const Text('No results');
              return ListView(
                children: [
                  for (final item in items) ListTile(title: Text(item)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
```

Why this shape matters:

- `BehaviorSubject` stores the current query
- `distinct` avoids duplicate work
- `debounceTime` waits for typing to pause
- `switchMap` cancels stale searches
- `_results` is built once, not on every widget rebuild
- `null` is used here as an explicit idle state for "no active query"

---

## Riverpod and RxDart together

A good rule:

- Riverpod manages feature state and dependency flow
- RxDart manages event pipelines when streams get tricky

Example:

```dart
final searchQueryProvider = Provider<BehaviorSubject<String>>((ref) {
  final subject = BehaviorSubject<String>.seeded('');
  ref.onDispose(subject.close);
  return subject;
});

final searchResultsProvider = StreamProvider<List<String>?>((ref) {
  final query = ref.watch(searchQueryProvider);

  return query.stream
      .distinct()
      .debounceTime(const Duration(milliseconds: 300))
      .switchMap(
        (text) => text.isEmpty
            ? Stream.value(null)
            : Stream.fromFuture(search(text)),
      );
});
```

This is a clean pairing when:

- the event flow is Rx-heavy
- the app still wants Riverpod for the public state API

---

## Bloc and RxDart together

If you know Bloc already, RxDart often helps you reason about Bloc concurrency:

- latest request wins -> `switchMap` -> `restartable()`
- ignore new events while busy -> droppable behavior
- queue work in order -> sequential behavior

You do not always need RxDart in a Bloc app, but understanding Rx semantics makes async Bloc much easier to reason about.

---

## Common beginner mistakes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| Building the pipeline inside `build()` | duplicate subscriptions, debounce breaks | create it once as a field |
| Forgetting to close a subject | leaks and updates after dispose | close it in `dispose()` |
| Using `flatMap` when latest should win | stale results appear late | use `switchMap` |
| Using RxDart for simple one-shot fetches | unnecessary complexity | use Riverpod/Bloc/Future first |
| Putting `distinct` after `debounceTime` | repeated identical input still resets timer | put `distinct` first |

---

## When to reach for RxDart

Reach for it when the hard part is:

- timing
- cancellation
- combining streams
- shaping event flow

Do not reach for it just because a feature is async.

Use it when you think:

- "only the latest search result should matter"
- "this input should wait until typing stops"
- "this value depends on multiple live sources"

---

## Interview Q&A

**Q: What is the difference between `switchMap` and `flatMap`?**  
`switchMap` keeps only the latest async work. `flatMap` lets multiple inner streams run at once.

**Q: Why is `BehaviorSubject` so common in UI work?**  
Because new listeners often need the latest value immediately.

**Q: What is the easiest way to misuse RxDart in Flutter?**  
Creating pipelines inside widget `build()` and forgetting to close subjects.

**Q: Is RxDart a state management solution by itself?**  
No. It is a stream composition toolkit that usually complements Riverpod or Bloc.
