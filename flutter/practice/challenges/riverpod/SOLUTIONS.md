# Solutions & Rubric — State Management (Riverpod)

---

## Bug 1 — Direct list mutation invisible to Riverpod

**Root cause:** Riverpod detects state changes by comparing the old and new `state` reference with `==`. `state.add(value)` mutates the existing list in place — the reference does not change, so Riverpod sees `oldState == newState` and skips notifying listeners. The UI never rebuilds.

**Fix:**
```dart
void add(int value) {
  state = [...state, value];
}
```

---

## Bug 2 — `ref.watch` called inside a button callback

**Root cause:** `ref.watch` is only valid inside `build()`. It registers a reactive listener so the widget can rebuild when the provider changes. Inside a callback there is no build context to schedule a rebuild against — Riverpod throws `Bad state: Cannot use "ref.watch" inside a non-build lifecycle`.

**Fix:**
```dart
onPressed: () {
  final current = ref.read(counterProvider);
  ref.read(counterProvider.notifier).state = current - 1;
  ref.read(historyProvider.notifier).add(current - 1);
},
```

---

## Bug 3 — `ref.read` used inside a derived provider body

**Root cause:** `ref.read` inside a provider body reads the dependency once at creation time and does **not** subscribe to it. When `counterProvider` changes, `doubledProvider` is never invalidated and always returns its initial computed value (`0 * 2 = 0`).

**Fix:**
```dart
final doubledProvider = Provider<int>((ref) {
  final count = ref.watch(counterProvider);
  return count * 2;
});
```

---

## Interview Rubric

### Hard Approved
- Finds all 3 bugs and explains the underlying Riverpod contract behind each:
  - Knows that Riverpod uses reference equality to detect state changes — mutating a collection in place is invisible.
  - Can articulate the rule: `ref.watch` inside `build`, `ref.read` inside callbacks/event handlers.
  - Understands the difference between `ref.read` and `ref.watch` inside a *provider body* specifically — not just in widgets.
- Bonus: mentions `ref.listen` as a third option for side-effects triggered by provider changes.
- Bonus: can explain why spreading into a new list (`[...state, value]`) satisfies the equality check when the list is not `const`.
- Bonus: knows that `NotifierProvider` is preferred over `StateNotifierProvider` in modern Riverpod and can explain the difference.

### Soft Approved
- Finds and fixes at least 2 of the 3 bugs.
- Fixes Bug 1 and Bug 2 but misses Bug 3 (the derived provider bug is subtle — `ref.read` vs `ref.watch` looks identical unless you know the provider-body contract).
- Knows the `ref.watch`/`ref.read` rule for widgets but did not apply it to the provider body context without prompting.
- Fixes Bug 1 by calling `state = List.from(state)..add(value)` — correct semantics, slightly less idiomatic than spread.

### Rejected
- Finds 1 or fewer bugs.
- Attempts to fix Bug 1 by adding `notifyListeners()` — confuses Riverpod with `ChangeNotifier`/Provider.
- Cannot explain why `ref.watch` in a callback throws — thinks it is a timing/async issue.
- Does not know the distinction between `ref.read` and `ref.watch` in provider bodies vs widget `build`.
- Fixes Bug 3 by converting `doubledProvider` to a `StateProvider` and manually updating it on every counter change — misunderstands derived state.
