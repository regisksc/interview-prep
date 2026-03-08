# Solutions — State Management (Riverpod)

## Symptoms
1. The history list never updates — incrementing and decrementing shows
   "No changes yet" forever.
2. Tapping **Decrement** throws:
   `Bad state: Cannot use "ref.watch" inside a non-build lifecycle`.
3. The "Doubled" value is always 0, no matter what the counter is.

---

## Bug 1 — Direct list mutation is invisible to Riverpod

**Where:** `HistoryNotifier.add()`.

```dart
void add(int value) {
  state.add(value); // mutates the existing list
}
```

Riverpod detects state changes by comparing the previous and next `state`
reference with `==`. When you call `.add()` on the existing list, the list
object is the same reference before and after — Riverpod sees `oldState ==
newState` → `true` and skips notifying listeners. The UI never rebuilds.

**Fix:** emit a new list:

```dart
void add(int value) {
  state = [...state, value];
}
```

---

## Bug 2 — `ref.watch` called inside a button callback

**Where:** `onPressed` of the Decrement button.

```dart
onPressed: () {
  final current = ref.watch(counterProvider); // throws
  ...
}
```

`ref.watch` is only valid inside `build()`. It registers a listener so that
when the provider changes the widget can rebuild. Inside a callback there is no
build context to schedule a rebuild, so Riverpod throws immediately.

**Fix:** use `ref.read` inside callbacks — it reads the current value once
without registering a listener:

```dart
onPressed: () {
  final current = ref.read(counterProvider);
  ref.read(counterProvider.notifier).state = current - 1;
  ref.read(historyProvider.notifier).add(current - 1);
}
```

---

## Bug 3 — `ref.read` used inside a derived provider

**Where:** `doubledProvider`.

```dart
final doubledProvider = Provider<int>((ref) {
  final count = ref.read(counterProvider); // reads once, never again
  return count * 2;
});
```

`ref.read` inside a provider body reads the dependency's current value at
creation time and does **not** subscribe to it. When `counterProvider` changes,
`doubledProvider` is never invalidated and always returns its initial value
(`0 * 2 = 0`).

**Fix:** use `ref.watch` so the derived provider rebuilds whenever the source
changes:

```dart
final doubledProvider = Provider<int>((ref) {
  final count = ref.watch(counterProvider);
  return count * 2;
});
```
