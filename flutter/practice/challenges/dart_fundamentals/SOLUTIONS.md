# Solutions — Dart Fundamentals

## Symptoms
1. You can add the same item multiple times — the duplicate check never fires.
2. Tapping a checkbox does nothing — the item stays unchecked forever.
3. Tapping **Clear bought** crashes the app at runtime.

---

## Bug 1 — Missing `==` / `hashCode` on `ShoppingItem`

**Where:** `ShoppingItem` class.

`_items.contains(newItem)` uses `==` to compare objects. Dart's default `==`
is reference (identity) equality, so two separate `ShoppingItem` instances with
identical names are never considered equal — `contains` always returns `false`
and duplicates accumulate freely.

**Fix:** override `==` and `hashCode`:

```dart
@override
bool operator ==(Object other) =>
    other is ShoppingItem && other.name == name;

@override
int get hashCode => name.hashCode;
```

---

## Bug 2 — `copyWith` result discarded

**Where:** `_toggleBought()`.

```dart
_items[index].copyWith(bought: !_items[index].bought); // result thrown away
```

`copyWith` creates and returns a *new* object — it does not mutate in place.
The returned object is never assigned, so `_items[index]` is unchanged.
`setState` triggers a rebuild that re-renders the exact same data.

**Fix:** assign the result back:

```dart
void _toggleBought(int index) {
  setState(() {
    _items[index] = _items[index].copyWith(bought: !_items[index].bought);
  });
}
```

---

## Bug 3 — Modifying a `List` while iterating over it

**Where:** `_clearBought()`.

```dart
for (final item in _items) {
  if (item.bought) _items.remove(item); // ConcurrentModificationError
}
```

Dart's `List` iterator tracks a modification stamp. Calling `remove()` (or
any mutating operation) while a `for-in` is active invalidates the iterator and
throws `ConcurrentModificationError` at runtime.

**Fix:** use `removeWhere`, which is safe:

```dart
void _clearBought() {
  setState(() => _items.removeWhere((item) => item.bought));
}
```
