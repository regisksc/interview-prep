# Exercise 8: List Chunk

**Time**: 10 min | **Difficulty**: 2 | **Topic**: Extension Methods, List Operations

---

## Challenge

Create an extension on `List<T>` that splits the list into chunks of a given size.

## Requirements

1. Create an extension on `List<T>` (generic)
2. Implement a method `chunk(int size)` that returns `List<List<T>>`
3. Split the list into sublists of the specified size
4. The last chunk may be smaller if the list doesn't divide evenly
5. Return empty list if input is empty

## Examples

```dart
[1, 2, 3, 4, 5].chunk(2)  // [[1, 2], [3, 4], [5]]
[1, 2, 3].chunk(3)        // [[1, 2, 3]]
[1, 2].chunk(5)           // [[1, 2]]
[].chunk(2)               // []
['a', 'b', 'c', 'd'].chunk(2)  // [['a', 'b'], ['c', 'd']]
```

## Hints

<details>
<summary>Hint 1: Loop with step</summary>
Use a for loop with `i += size` to iterate through the list.
</details>

<details>
<summary>Hint 2: Sublist</summary>
Use `sublist(start, end)` to extract each chunk.
</details>

<details>
<summary>Hint 3: List.generate</summary>
Consider using `List.generate()` for a functional approach.
</details>

## Starter Code

See `main.dart` - implement the `chunk(int size)` method.

## Testing

Run with:
```bash
dart run
```

---

[← Back to Extensions Index](../README.md)
