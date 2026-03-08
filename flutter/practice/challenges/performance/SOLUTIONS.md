# Solutions — Performance

## Symptoms
1. Typing in the search field feels laggy — every character causes a noticeable
   frame drop even on a modern device.
2. The initial load and every filter change renders all 2 000 items at once,
   even those far off-screen.
3. Scrolling through the list is janky because every frame has to lay out and
   paint all visible and invisible items simultaneously.

---

## Bug 1 — Expensive computation inside `build()`

**Where:** `_CatalogScreenState.build()`.

```dart
final filtered = _allProducts
    .where(...)
    .toList()
  ..sort((a, b) => a.price.compareTo(b.price));
```

This runs on **every** call to `build()`. Flutter can call `build()` many times
per second (every frame during animations, every `setState`, every parent
rebuild). Filtering and sorting 2 000 items synchronously on the UI thread on
every frame causes jank.

**Fix:** compute filtered/sorted results only when the inputs actually change,
not on every render. Move the computation to a helper called from `_onSearch`
and `_onCategory`, and store the result in state:

```dart
late List<Product> _filtered;

@override
void initState() {
  super.initState();
  _recompute();
}

void _recompute() {
  _filtered = _allProducts
      .where((p) =>
          (_selectedCategory == 'All' || p.category == _selectedCategory) &&
          p.name.toLowerCase().contains(_query.toLowerCase()))
      .toList()
    ..sort((a, b) => a.price.compareTo(b.price));
}

void _onSearch(String value) {
  setState(() { _query = value; _recompute(); });
}

void _onCategory(String? value) {
  if (value != null) setState(() { _selectedCategory = value!; _recompute(); });
}
```

Now `build()` just reads `_filtered` — no computation at render time.

---

## Bug 2 — `ListView` materializes all items at once

**Where:** The `ListView` at the bottom of `build()`.

```dart
ListView(
  children: filtered.map((p) => ListTile(...)).toList(),
)
```

`ListView` with a `children` list builds every widget upfront, regardless of
whether it is visible. With 2 000 items that means 2 000 `ListTile` widgets
created, laid out, and painted before the first frame. This is both slow to
load and wasteful of memory.

**Fix:** use `ListView.builder`, which lazily creates only the items currently
visible on screen (typically ~20–30):

```dart
ListView.builder(
  itemCount: filtered.length,
  itemBuilder: (_, i) => ListTile(
    title: Text(filtered[i].name),
    subtitle: Text(filtered[i].category),
    trailing: Text('\$${filtered[i].price.toStringAsFixed(2)}'),
  ),
)
```

---

## Bug 3 — `setState` called even when the value has not changed

**Where:** `_onSearch` (and potentially `_onCategory`).

If the user pastes the same text or presses a modifier key, `onChanged` fires
with the same string. `setState` is called unconditionally, triggering a full
`build()` for no reason. Combined with Bug 1, this amplifies the jank.

**Fix:** guard the state update:

```dart
void _onSearch(String value) {
  if (value == _query) return;
  setState(() { _query = value; _recompute(); });
}
```
