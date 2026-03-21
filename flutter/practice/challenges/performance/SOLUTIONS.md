# Solutions & Rubric — Performance

---

## Bug 1 — Expensive computation inside `build()`

**Root cause:** Filtering and sorting 2 000 items runs on every `build()` call. Flutter can call `build()` many times per second — every `setState`, parent rebuild, or animation frame re-runs the full filter+sort on the UI thread, causing jank.

**Fix:** compute only when inputs change; store the result in state.
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
  if (value != null) setState(() { _selectedCategory = value; _recompute(); });
}
```
`build()` now just reads `_filtered` — no computation at render time.

---

## Bug 2 — `ListView` materializes all items at once

**Root cause:** `ListView(children: [...])` builds every widget upfront regardless of visibility. With 2 000 items, 2 000 `ListTile` widgets are created, laid out, and painted before the first frame — slow initial render and wasteful memory.

**Fix:**
```dart
ListView.builder(
  itemCount: _filtered.length,
  itemBuilder: (_, i) => ListTile(
    title: Text(_filtered[i].name),
    subtitle: Text(_filtered[i].category),
    trailing: Text('\$${_filtered[i].price.toStringAsFixed(2)}'),
  ),
)
```
`ListView.builder` lazily creates only the items currently in the viewport (~20–30 at a time).

---

## Bug 3 — `setState` called unconditionally

**Root cause:** `onChanged` fires whenever the field emits a value, including when the user pastes the same text or presses a modifier key. `setState` is called even when `_query` hasn't changed, scheduling an unnecessary rebuild. Combined with Bug 1 this multiplies the jank.

**Fix:**
```dart
void _onSearch(String value) {
  if (value == _query) return;
  setState(() { _query = value; _recompute(); });
}
```

---

## Interview Rubric

### Hard Approved
- Finds all 3 bugs, explains their compounding relationship, and prioritises them correctly (Bug 1 + Bug 2 have the most impact; Bug 3 is secondary).
- Bug 1: knows that `build()` can be called far more often than state changes, and that it is the wrong place for non-trivial computation. Can name alternatives: caching in state, `didUpdateWidget`, derived state via Riverpod/`select`.
- Bug 2: knows the difference between `ListView`, `ListView.builder`, and `ListView.separated` — and when `SliverList` / `SliverPrototypeExtentList` would be preferred over all of them.
- Bug 3: understands that `setState` triggers a synchronous call to `build()` and should be guarded.
- Bonus: mentions `itemExtent` on `ListView.builder` as a further optimization — skips the layout measurement step when all items are the same height.
- Bonus: knows how to use DevTools (Performance overlay, Widget Rebuild tracker, CPU profiler) to locate these issues empirically rather than by reading code.
- Bonus: proposes moving the filter/sort to an `Isolate` or using `compute()` for very large datasets.

### Soft Approved
- Finds and fixes at least 2 of the 3 bugs.
- Fixes Bug 2 immediately (`ListView.builder`) but needs a moment to connect Bug 1 to the build cycle.
- Knows `ListView.builder` is lazy but cannot precisely explain when each item widget is created and destroyed.
- Finds Bug 3 only after Bugs 1 and 2 are resolved, or only when pointed to `_onSearch`.
- Cannot articulate when to prefer `Isolate`/`compute` vs caching in state.

### Rejected
- Finds 1 or fewer bugs, or finds them only after being shown the symptoms in DevTools.
- Wraps the filter+sort in a `FutureBuilder` to move it off the main thread — shows initiative but misunderstands that `FutureBuilder` still runs in the UI isolate; `compute()` is needed for true parallelism.
- Replaces `ListView` with `ListView.builder` but keeps the filter+sort in `build()` — fixes Bug 2 while missing the more impactful Bug 1.
- Cannot explain why calling `setState` with the same value causes a rebuild, or does not know that `setState` is synchronous with respect to `build()`.
- Has not used Flutter DevTools and cannot describe how they would diagnose a performance issue without reading the code.
