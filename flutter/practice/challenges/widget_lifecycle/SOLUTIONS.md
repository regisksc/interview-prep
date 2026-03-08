# Solutions — Widget Lifecycle

## Symptoms
1. Navigate to the match screen, press Back quickly. The debug console prints
   `setState() called after dispose()` a few seconds later.
2. Tapping **Save score** then immediately pressing Back causes
   `"Looking up a deactivated widget's ancestor"` or a null-context crash.
3. Memory usage grows slightly every time you navigate in and out of the
   match screen (AnimationController never released).

---

## Bug 1 — Timer not cancelled in `dispose`

**Where:** `initState` starts `Timer.periodic`; `dispose` does not cancel it.

The timer fires every 2 seconds regardless of whether the widget is still in the
tree. After the user presses Back, the widget is disposed, but the timer keeps
calling `setState` on the dead `State` object → Flutter throws
`setState() called after dispose()`.

**Fix:** cancel the timer in `dispose`:

```dart
@override
void dispose() {
  _timer?.cancel();
  _pulse.dispose();
  super.dispose();
}
```

---

## Bug 2 — `context` used across an async gap without a `mounted` check

**Where:** `_saveScore()`, after the `await`.

If the user presses Back during the 2-second delay, the widget is disposed
before the `await` resumes. At that point `context` is stale and
`ScaffoldMessenger.of(context)` throws because there is no longer a valid
`Scaffold` ancestor.

**Fix:** check `mounted` after every `await` before touching `context`:

```dart
Future<void> _saveScore() async {
  await Future.delayed(const Duration(seconds: 2));
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Score $_score saved!')),
  );
}
```

---

## Bug 3 — `AnimationController` never disposed

**Where:** `dispose()` — `_pulse.dispose()` is missing.

`AnimationController` registers a `Ticker` with the engine's scheduler binding.
Without calling `dispose()`, that ticker keeps running and the controller holds
a reference to the `TickerProvider` (this widget's `State`), preventing garbage
collection. Every navigation to the screen leaks one controller.

**Fix:** dispose the controller before calling `super.dispose()`:

```dart
@override
void dispose() {
  _timer?.cancel();
  _pulse.dispose();
  super.dispose();
}
```

> Note: `super.dispose()` must always be the **last** call in `dispose`.
> Calling it first deactivates the `TickerProvider` mixin, making any
> subsequent `_pulse.dispose()` call operate on an already-torn-down vsync.
