# Solutions & Rubric — Widget Lifecycle

---

## Bug 1 — Timer not cancelled in `dispose`

**Root cause:** `Timer.periodic` fires indefinitely. After the user navigates back, the widget is disposed but the timer keeps calling `setState` on the dead `State` object → `setState() called after dispose()`.

**Fix:**
```dart
@override
void dispose() {
  _timer?.cancel();
  _pulse.dispose();
  super.dispose();
}
```

---

## Bug 2 — `context` used across an `async` gap without a `mounted` check

**Root cause:** If the user navigates back during the 2-second `await`, the widget is disposed before `_saveScore` resumes. `context` is now stale — `ScaffoldMessenger.of(context)` throws because there is no longer a valid ancestor.

**Fix:**
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

**Root cause:** `AnimationController` registers a `Ticker` with the engine's scheduler. Without `dispose()`, the ticker keeps running and the controller holds a reference to the `State` (via `TickerProvider`), preventing garbage collection. Each navigation to the screen leaks one controller.

**Fix:** included in Bug 1's fix above — `_pulse.dispose()` must be called before `super.dispose()`.

> `super.dispose()` must always be **last** in `dispose()`. Calling it first tears down the `TickerProvider` mixin, making any subsequent `_pulse.dispose()` operate on an already-invalidated vsync source.

---

## Interview Rubric

### Hard Approved
- Finds all 3 bugs and explains the *why* behind each:
  - Knows that `Timer.periodic` is not tied to the widget tree and must be cancelled explicitly.
  - Understands that `await` is a suspension point — the widget can be disposed between the `await` and the next line, making `context` stale.
  - Knows that `AnimationController` owns a `Ticker` and leaks if not disposed.
- Knows the correct ordering: cancel/dispose resources first, call `super.dispose()` last.
- Bonus: mentions `mounted` is only reliable in `State` and not in non-widget async callbacks.
- Bonus: can explain the difference between `_timer?.cancel()` (stops future callbacks) and `_pulse.dispose()` (releases engine resources) — they are different cleanup mechanisms.

### Soft Approved
- Finds and fixes at least 2 of the 3 bugs.
- Fixes Bug 1 and Bug 2 but misses Bug 3 (the leak is silent — no visible symptom without DevTools).
- Adds `mounted` check but places it incorrectly (e.g., before the `await` — which is vacuously true) or uses a `try/catch` around the `ScaffoldMessenger` call instead.
- Understands lifecycle conceptually but had to be prompted about `AnimationController` disposal.

### Rejected
- Finds 1 or fewer bugs.
- Fixes Bug 1 by removing the timer entirely rather than cancelling it.
- Does not know what `mounted` is or why `context` can become invalid after an `await`.
- Calls `super.dispose()` first and then disposes resources — does not know the ordering rule.
- Identifies the memory leak only after being told to look for one; cannot explain what a `Ticker` is or why it prevents GC.
