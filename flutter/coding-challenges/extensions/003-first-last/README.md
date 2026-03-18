# Exercise 3: List First and Last (Safe Access)

**Time**: 5 min | **Difficulty**: 1 | **Topic**: Extension Methods, Null Safety

---

## Challenge

Create extensions on `List<T>` to safely get the first and last elements, returning `null` for empty lists instead of throwing an exception.

## Requirements

1. Create an extension on `List<T>` (generic)
2. Implement `firstSafe` getter - returns first element or `null`
3. Implement `lastSafe` getter - returns last element or `null`
4. Handle empty lists gracefully

## Examples

```dart
[1, 2, 3].firstSafe    // 1
[].firstSafe           // null
[5].lastSafe           // 5
[].lastSafe            // null
['a', 'b'].firstSafe   // 'a'
['x'].lastSafe         // 'x'
```

## Hints

<details>
<summary>Hint 1: Check if empty</summary>
Use `isEmpty` or check `length` before accessing elements.
</details>

<details>
<summary>Hint 2: Return type</summary>
The return type should be `T?` (nullable generic) since it can return null.
</details>

<details>
<summary>Hint 3: Built-in properties</summary>
Lists have `first` and `last` but they throw on empty - you need safe versions.
</details>

## Starter Code

See `main.dart` - implement `firstSafe` and `lastSafe` getters.

## Testing

Run with:
```bash
dart run
```

---

[← Back to Extensions Index](../README.md)
