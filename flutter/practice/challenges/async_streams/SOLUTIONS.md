# Solutions & Rubric — Async & Streams

---

## Bug 1 — `StreamSubscription` never cancelled

**Root cause:** The subscription calls `setState` on every event. When the user navigates back, the widget is disposed but the subscription is still active. Every incoming event calls `setState` on the dead state → `setState() called after dispose()` on every tick until the app is killed.

**Fix:**
```dart
@override
void dispose() {
  _subscription?.cancel();
  super.dispose();
}
```

---

## Bug 2 — Missing `await` causes exception to be silently swallowed

**Root cause:** Without `await`, `_saveEvent(event)` returns a `Future` that the function ignores. The `try/catch` only wraps synchronous code — it cannot catch exceptions from unawaited futures. The status is set to "archived" unconditionally, and the error surfaces later as an unhandled exception.

**Fix:**
```dart
Future<void> _archive(String event) async {
  try {
    await _saveEvent(event);
    setState(() => _status = '$event archived');
  } catch (e) {
    setState(() => _status = 'Failed: $e');
  }
}
```

---

## Bug 3 — `Future.forEach` is sequential

**Root cause:** `Future.forEach` awaits each future before starting the next. With N events each taking ~800 ms, total time is `N × 800 ms`. The events are independent — there is no reason to serialize them.

**Fix:**
```dart
Future<void> _archiveAll() async {
  final toArchive = List<String>.from(_events);
  await Future.wait(toArchive.map((e) => _saveEvent(e)));
  setState(() => _status = 'All ${toArchive.length} events archived');
}
```
Total time drops from `N × 800 ms` to `~800 ms` regardless of count.

---

## Interview Rubric

### Hard Approved
- Finds all 3 bugs and explains the underlying async model:
  - Knows that a `StreamSubscription` is not tied to the widget tree and must be cancelled manually, analogous to cancelling a `Timer`.
  - Can explain precisely why an unawaited `Future` escapes a `try/catch` — the exception is delivered to the `Future`'s error handler, not the surrounding call stack.
  - Knows the semantic difference between `Future.forEach` (sequential, each item waits for the previous) and `Future.wait` (concurrent, all started immediately).
- Bonus: mentions that `Future.wait` can be given `eagerError: false` to collect all results even if some fail, instead of aborting on the first error.
- Bonus: mentions that an unawaited future should be marked with `unawaited()` from `package:meta` if intentional, to signal to the reader (and linter) that the omission is deliberate.
- Bonus: notes that `Future.wait` with `_saveEvent` will surface the first exception and silently discard results from futures that completed after the failure — and knows how to handle that.

### Soft Approved
- Finds and fixes at least 2 of the 3 bugs.
- Fixes Bug 1 and Bug 3 but misses Bug 2 (the missing `await` is easy to overlook — the app doesn't crash, it just silently shows the wrong status).
- Knows `Future.wait` but cannot explain *why* `Future.forEach` is sequential.
- Fixes Bug 2 by wrapping the entire `_archive` body in a top-level try/catch and re-calling it with `await` — correct outcome, shows partial understanding.

### Rejected
- Finds 1 or fewer bugs.
- Does not know that streams must be cancelled — thinks navigating away automatically cleans up all subscriptions.
- Cannot explain why the try/catch in Bug 2 fails to catch the exception.
- Replaces `Future.forEach` with a plain `for` loop with `await` — this is still sequential (worse: it's more verbose).
- Confuses `StreamController.close()` with `StreamSubscription.cancel()`.
