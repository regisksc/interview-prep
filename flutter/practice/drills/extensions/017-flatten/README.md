# Exercise 17: List Flatten

**Time**: 10 min | **Difficulty**: 2 | **Topic**: Extension Methods, List Operations

---

## Challenge

Create an extension on `List<List<T>>` that flattens a nested list one level deep.

## Requirements

1. Create an extension on `List<List<T>>` (list of lists)
2. Implement a method `flatten()` that returns `List<T>`
3. Combine all inner lists into a single list
4. Preserve order of elements

## Examples

```dart
[[1, 2], [3, 4], [5]].flatten()    // [1, 2, 3, 4, 5]
[[1], [], [2, 3]].flatten()        // [1, 2, 3]
[[1, 2, 3]].flatten()              // [1, 2, 3]
[].flatten()                        // []
[['a', 'b'], ['c']].flatten()      // ['a', 'b', 'c']
```

## Hints

<details>
<summary>Hint 1: expand</summary>
Use `expand()` which flattens collections.
</details>

<details>
<summary>Hint 2: for loop</summary>
Alternatively, use nested loops to add elements to a result list.
</details>

<details>
<summary>Hint 3: fold</summary>
Consider using `fold()` to accumulate results.
</details>

## Starter Code

See `main.dart` - implement the `flatten()` method.

## Testing

Run with:
```bash
dart run
```

---

[← Back to Extensions Index](../README.md)
