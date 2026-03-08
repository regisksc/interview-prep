# Solutions — Async & Streams

## Symptoms
1. Navigate to the Feed, press Back. The debug console keeps printing
   `setState() called after dispose()` every second indefinitely.
2. Tapping the archive icon on a "Logout" event shows "All archived"
   instead of the error — the exception is silently swallowed.
3. "Archive all" always archives events one-by-one sequentially even though
   they could all be saved in parallel, making it noticeably slow.

---

## Bug 1 — `StreamSubscription` never cancelled

**Where:** `dispose()` — `_subscription?.cancel()` is missing.

The stream emits an event every second and the subscription calls `setState`
each time. When the user navigates back, the widget is disposed but the
subscription is still active. Every incoming event calls `setState` on the
dead state, causing Flutter to throw `setState() called after dispose()` on
every tick until the app is killed.

**Fix:** cancel the subscription in `dispose`, **before** `super.dispose()`:

```dart
@override
void dispose() {
  _subscription?.cancel();
  super.dispose();
}
```

---

## Bug 2 — Missing `await` causes the exception to be silently swallowed

**Where:** `_archive()`.

```dart
Future<void> _archive(String event) async {
  try {
    _saveEvent(event);          // Future not awaited — returns immediately
    setState(() => _status = '$event archived');
  } catch (e) {
    setState(() => _status = 'Failed: $e');
  }
}
```

Without `await`, `_saveEvent` returns a `Future` that the caller ignores.
The `try/catch` block cannot catch exceptions from unawaited futures — the
`Future` completes with an error later, unhandled, while the code has already
set the status to "archived" unconditionally.

**Fix:** await the call:

```dart
await _saveEvent(event);
```

---

## Bug 3 — `Future.forEach` processes events sequentially

**Where:** `_archiveAll()`.

```dart
await Future.forEach(toArchive, (String e) => _saveEvent(e));
```

`Future.forEach` awaits each future before starting the next one — it is
inherently sequential. If there are 10 events each taking 800 ms, the total
wait is ~8 seconds.

**Fix:** use `Future.wait` to run all saves concurrently:

```dart
Future<void> _archiveAll() async {
  final toArchive = List<String>.from(_events);
  await Future.wait(toArchive.map((e) => _saveEvent(e)));
  setState(() => _status = 'All ${toArchive.length} events archived');
}
```

Total time drops from `n × 800 ms` to `~800 ms` regardless of count.
