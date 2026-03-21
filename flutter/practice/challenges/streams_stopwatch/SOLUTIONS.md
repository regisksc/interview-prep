# Solution — Vanilla Streams: Stopwatch

## Reference Implementation

```dart
import 'dart:async';
import 'package:flutter/material.dart';

class _StopwatchScreenState extends State<StopwatchScreen> {
  StreamController<int>? _controller;
  StreamSubscription<int>? _subscription;
  int _elapsed = 0;
  bool _running = false;

  void _start() {
    _controller = StreamController<int>();
    _subscription = Stream.periodic(const Duration(seconds: 1), (i) => i + 1)
        .listen((tick) {
      _controller!.add(_elapsed + tick);
    });
    setState(() => _running = true);
  }

  void _pause() {
    _subscription?.pause();
    setState(() => _running = false);
  }

  void _resume() {
    _subscription?.resume();
    setState(() => _running = true);
  }

  void _reset() {
    _subscription?.cancel();
    _controller?.close();
    _controller = StreamController<int>()..add(0);
    setState(() { _elapsed = 0; _running = false; });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller?.close();
    super.dispose();
  }
}
```

**StreamBuilder usage:**
```dart
StreamBuilder<int>(
  stream: _controller?.stream,
  initialData: 0,
  builder: (context, snapshot) {
    return Text(_format(snapshot.data ?? 0), ...);
  },
)
```

**Key decisions:**
- `Stream.periodic` emits relative ticks (0, 1, 2…) — offset by `_elapsed` to support resume after pause.
- `StreamController` is recreated on reset so the `StreamBuilder` gets a fresh stream without stale events.
- `subscription.pause()` / `resume()` suspends the periodic tick without destroying it.
- Both the subscription and controller must be cancelled/closed in `dispose`.

---

## Rubric

### Hard Approved
- Drives the display entirely via `StreamBuilder` — no `setState` for the counter value itself.
- Handles start / pause / resume correctly: `pause()` and `resume()` on the subscription, not cancel + recreate.
- Tracks `_elapsed` so that resuming picks up from where it paused (not from 0).
- Closes the `StreamController` and cancels the subscription in `dispose`.
- Knows the difference between `StreamController` (the sink + stream wrapper) and `StreamSubscription` (the listener handle).

### Soft Approved
- `StreamBuilder` used for display but pause/resume implemented by cancelling and recreating the stream, losing the elapsed offset correctly by storing it.
- Disposes resources but forgets to close the controller (only cancels the subscription).
- Can't explain the difference between `Stream.periodic` and a `Timer` in terms of backpressure and stream semantics.

### Rejected
- Uses `setState` for the timer tick and wraps it in a stream unnecessarily (misses the point of the exercise).
- Does not cancel the subscription in `dispose` — same leak as the widget_lifecycle challenge.
- Does not know what `StreamController` is for or why a plain `Stream` can't be paused.
- Confuses `StreamSubscription.pause()` (buffering) with `StreamSubscription.cancel()` (terminate).
