# Exercise 15: Int Is Even/Odd

**Time**: 5 min | **Difficulty**: 1 | **Topic**: Extension Methods

---

## Challenge

Create extensions on `int` to check if a number is even or odd.

## Requirements

1. Create an extension on `int`
2. Implement `isEven` getter - returns `true` if divisible by 2
3. Implement `isOdd` getter - returns `true` if not divisible by 2
4. Note: Dart already has these - this is practice for extension syntax

## Examples

```dart
4.isEven    // true
7.isOdd     // true
0.isEven    // true
(-2).isEven // true
(-3).isOdd  // true
```

## Hints

<details>
<summary>Hint 1: Modulo operator</summary>
Use `%` operator to check remainder when divided by 2.
</details>

<details>
<summary>Hint 2: isEven definition</summary>
A number is even if `number % 2 == 0`.
</details>

<details>
<summary>Hint 3: Relationship</summary>
`isOdd` is the opposite of `isEven`.
</details>

## Starter Code

See `main.dart` - implement `isEven` and `isOdd` getters.

## Testing

Run with:
```bash
dart run
```

---

[← Back to Extensions Index](../README.md)
