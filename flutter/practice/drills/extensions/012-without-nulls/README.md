# Exercise 12: List Without Nulls

**Time**: 5 min | **Difficulty**: 1 | **Topic**: Extension Methods, Null Safety

---

## Challenge

Create an extension on `List<T?>` that removes all null values from the list.

## Requirements

1. Create an extension on `List<T?>` (list of nullable items)
2. Implement a getter called `withoutNulls` that returns `List<T>`
3. Filter out all null values
4. The result should be a non-nullable list

## Examples

```dart
[1, null, 2, null, 3].withoutNulls  // [1, 2, 3]
[].withoutNulls                      // []
[null, null].withoutNulls            // []
['a', null, 'b'].withoutNulls        // ['a', 'b']
```

## Hints

<details>
<summary>Hint 1: where</summary>
Use `where()` to filter elements.
</details>

<details>
<summary>Hint 2: Type cast</summary>
After filtering, you may need to cast the result type.
</details>

<details>
<summary>Hint 3: whereType</summary>
Dart has `whereType<T>()` which filters by type and removes nulls.
</details>

## Starter Code

See `main.dart` - implement the `withoutNulls` getter.

## Testing

Run with:
```bash
dart run
```

---

[← Back to Extensions Index](../README.md)
