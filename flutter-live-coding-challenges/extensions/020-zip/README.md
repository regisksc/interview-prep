# Exercise 20: List Zip

**Time**: 10 min | **Difficulty**: 2 | **Topic**: Extension Methods, Generics, Tuples

---

## Challenge

Create an extension on `List<T>` that zips two lists together into pairs.

## Requirements

1. Create an extension on `List<T>` (generic)
2. Implement a method `zip<U>(List<U> other)` that returns `List<(T, U)>`
3. Pair elements at corresponding indices from both lists
4. Result length equals the shorter of the two input lists

## Examples

```dart
[1, 2, 3].zip([4, 5, 6])        // [(1, 4), (2, 5), (3, 6)]
[1, 2].zip([3, 4, 5, 6])        // [(1, 3), (2, 4)] (shortest wins)
[].zip([1, 2])                  // []
['a', 'b'].zip([1, 2])          // [('a', 1), ('b', 2)]
[true, false].zip(['yes', 'no']) // [(true, 'yes'), (false, 'no')]
```

## Hints

<details>
<summary>Hint 1: List.generate</summary>
Use `List.generate()` with the minimum length of both lists.
</details>

<details>
<summary>Hint 2: Records</summary>
Dart 3 records use `(a, b)` syntax for pairs.
</details>

<details>
<summary>Hint 3: Length</summary>
Use `min(this.length, other.length)` for the result size.
</details>

## Starter Code

See `main.dart` - implement the `zip<U>(List<U> other)` method.

## Testing

Run with:
```bash
dart run
```

---

[← Back to Extensions Index](../README.md)
