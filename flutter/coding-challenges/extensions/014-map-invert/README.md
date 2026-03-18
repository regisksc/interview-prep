# Exercise 14: Map Invert

**Time**: 10 min | **Difficulty**: 2 | **Topic**: Extension Methods, Generics

---

## Challenge

Create an extension on `Map<K, V>` that inverts the map, swapping keys and values.

## Requirements

1. Create an extension on `Map<K, V>` (generic)
2. Implement a method `invert()` that returns `Map<V, K>`
3. Original values become keys, original keys become values
4. Handle the case of duplicate values (later keys overwrite earlier ones)

## Examples

```dart
{'a': 1, 'b': 2}.invert    // {1: 'a', 2: 'b'}
{}.invert                  // {}
{'x': 1, 'y': 1}.invert    // {1: 'y'} (duplicate value - last wins)
{'name': 'John', 'city': 'NYC'}.invert  // {'John': 'name', 'NYC': 'city'}
```

## Hints

<details>
<summary>Hint 1: Map from iterable</summary>
Use `Map.fromIterable()` or create a new map and populate it.
</details>

<details>
<summary>Hint 2: entries</summary>
Iterate over `entries` and swap key/value pairs.
</details>

<details>
<summary>Hint 3: for loop</summary>
A simple for-each loop over entries works well here.
</details>

## Starter Code

See `main.dart` - implement the `invert()` method.

## Testing

Run with:
```bash
dart run
```

---

[← Back to Extensions Index](../README.md)
