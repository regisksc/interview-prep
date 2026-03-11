# Exercise 11: Bool To Int

**Time**: 5 min | **Difficulty**: 1 | **Topic**: Extension Methods

---

## Challenge

Create an extension on `bool` that converts `true` to `1` and `false` to `0`.

## Requirements

1. Create an extension on `bool`
2. Implement a method `toInt()` that returns an `int`
3. `true` should return `1`
4. `false` should return `0`

## Examples

```dart
true.toInt()    // 1
false.toInt()   // 0
```

## Hints

<details>
<summary>Hint 1: Ternary</summary>
Use a ternary expression: `condition ? 1 : 0`
</details>

<details>
<summary>Hint 2: One-liner</summary>
This can be a single-line implementation.
</details>

## Starter Code

See `main.dart` - implement the `toInt()` method.

## Testing

Run with:
```bash
dart run
```

---

[← Back to Extensions Index](../README.md)
