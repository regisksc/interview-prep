# Solution — RxDart: Live Search

## Reference Implementation

```dart
import 'package:rxdart/rxdart.dart';

class _SearchScreenState extends State<SearchScreen> {
  final _query = BehaviorSubject<String>.seeded('');

  late final Stream<List<String>?> _results = _query.stream
      .distinct()
      .debounceTime(const Duration(milliseconds: 300))
      .switchMap((q) => q.isEmpty
          ? Stream.value(null)          // emit null → idle state
          : Stream.fromFuture(_search(q)));

  @override
  void dispose() {
    _query.close();
    super.dispose();
  }
}
```

**TextField wiring:**
```dart
onChanged: (v) => _query.add(v),
```

**StreamBuilder with three states:**
```dart
StreamBuilder<List<String>?>(
  stream: _results,
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const Center(child: Text('Start typing to search'));
    }
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    final results = snapshot.data!;
    if (results.isEmpty) return const Center(child: Text('No results'));
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) => ListTile(title: Text(results[i])),
    );
  },
)
```

**Key decisions:**
- `BehaviorSubject.seeded('')` replays the last value to new listeners — important if the widget rebuilds mid-typing.
- `distinct()` before `debounceTime` avoids re-running a search when the user types and immediately deletes, returning to a prior value.
- `switchMap` automatically cancels the in-flight `_search` future when a new query arrives — this is the core correctness property.
- Emitting `null` for empty query cleanly separates the idle state from an empty-results state.

---

## Rubric

### Hard Approved
- Builds the pipeline declaratively as a single `late final Stream` field — not rebuilt on every `build()` call.
- Uses `switchMap` (not `flatMap`/`asyncExpand`) and can explain why: `flatMap` would merge all in-flight results, causing stale results from slow queries to overwrite fast ones.
- Uses `distinct()` before `debounceTime` and can explain the ordering: deduplication before debounce means a repeated value never even resets the debounce timer.
- Closes the `BehaviorSubject` in `dispose`.
- Can explain what `BehaviorSubject` adds over a plain `StreamController`: it caches the latest value and replays it to new subscribers, making it safe to rebuild the widget.
- Bonus: knows `PublishSubject` (no replay) and `ReplaySubject` (full history) and when each is appropriate.
- Bonus: mentions that `switchMap` over a `Future` requires wrapping it in `Stream.fromFuture` and understands why.

### Soft Approved
- Pipeline works but built partially in `initState` with manual subscription instead of a declarative stream.
- Uses `debounceTime` but omits `distinct` — understands debounce but not deduplication.
- Uses `flatMap` instead of `switchMap` — results work most of the time but race condition exists for slow queries.
- Closes the subject in `dispose` but can't fully explain `BehaviorSubject` vs `StreamController`.

### Rejected
- Re-creates the pipeline inside `build()` — a new stream on every rebuild, losing debounce state and subscribing multiple times.
- Uses a `Timer` for debounce instead of `debounceTime` — reinvents the wheel and usually gets edge cases wrong (cancelling on new input).
- Does not close the subject in `dispose`.
- Cannot explain `switchMap` or why stale results are a problem.
- Uses `asyncExpand` and cannot articulate the difference from `switchMap`.
