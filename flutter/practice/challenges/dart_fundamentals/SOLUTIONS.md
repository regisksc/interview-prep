# Solutions & Rubric — Dart Fundamentals

---

## Bug 1 — Missing `==` / `hashCode` on `ShoppingItem`

**Root cause:** `_items.contains(newItem)` uses Dart's default `==`, which is reference equality. Two `ShoppingItem` instances with the same `name` are different objects, so `contains` always returns `false` and duplicates accumulate.

**Fix:**
```dart
@override
bool operator ==(Object other) =>
    other is ShoppingItem && other.name == name;

@override
int get hashCode => name.hashCode;
```

---

## Bug 2 — `copyWith` result discarded

**Root cause:** `copyWith` returns a *new* object — it does not mutate in place. The result is never assigned back to `_items[index]`, so the list holds the original unchanged object and `setState` redraws the same data.

**Fix:**
```dart
void _toggleBought(int index) {
  setState(() {
    _items[index] = _items[index].copyWith(bought: !_items[index].bought);
  });
}
```

---

## Bug 3 — Mutating a `List` while iterating over it

**Root cause:** Dart's `List` iterator tracks a modification stamp. Calling `remove()` during a `for-in` loop invalidates the iterator and throws `ConcurrentModificationError` at runtime.

**Fix:**
```dart
void _clearBought() {
  setState(() => _items.removeWhere((item) => item.bought));
}
```

---

## Interview Rubric

### Hard Approved
- Identifies all 3 bugs and explains the *why* behind each, not just the fix:
  - Knows that Dart's default `==` is reference equality and that value types need an explicit override.
  - Understands that `copyWith` is a pure function and the result must be captured.
  - Knows why concurrent modification throws and can name a safe alternative (`removeWhere`, iterating a copy, building a new list).
- Bonus: mentions that `hashCode` must be consistent with `==` (same fields), and that violating this contract breaks `Set`, `Map`, and any hash-based collection.
- Bonus: offers `Equatable` or `freezed` as alternatives to manual `==`/`hashCode`.

### Soft Approved
- Finds and fixes at least 2 of the 3 bugs with correct reasoning.
- May fix Bug 3 by iterating over a copy (`List.from`) rather than `removeWhere` — valid but less idiomatic; can be discussed.
- Misses Bug 1 or conflates it with a logic error rather than an equality contract issue.
- Understands immutability conceptually but needed a moment to spot the discarded return value.

### Rejected
- Finds 1 or fewer bugs.
- Attempts to fix Bug 2 by removing `copyWith` and mutating `bought` directly on the object — misunderstands why the class is `final`.
- Cannot explain why `contains` fails — blames the list logic rather than the equality contract.
- Fixes Bug 3 with a `try/catch` around the crash rather than understanding the root cause.
- Does not know what `hashCode` is for or why it must match `==`.
