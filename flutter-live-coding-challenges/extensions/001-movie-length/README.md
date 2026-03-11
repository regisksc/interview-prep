# Exercise 1: Minutes to Movie Length

**Time**: 5 min | **Difficulty**: 1 | **Topic**: Extension Methods

---

## Challenge

Create an extension method on `int` that converts a number of minutes into a human-readable movie length format.

## Requirements

1. Create an extension on the `int` type
2. Implement a method called `toMovieLength()` that returns a `String`
3. Format rules:
   - If hours > 0, include hours as `Xh`
   - If minutes > 0 (remainder), include as `Ymin`
   - Combine both when applicable
   - Return empty string for 0 minutes

## Examples

```dart
60.toMovieLength()     // '1h'
80.toMovieLength()     // '1h 20min'
120.toMovieLength()    // '2h'
145.toMovieLength()    // '2h 25min'
5.toMovieLength()      // '5min'
0.toMovieLength()      // ''
200.toMovieLength()    // '3h 20min'
```

## Hints

<details>
<summary>Hint 1: Division</summary>
Use integer division (`~/`) to get hours and modulo (`%`) to get remaining minutes.
</details>

<details>
<summary>Hint 2: String Building</summary>
Consider building the string conditionally based on whether hours/minutes are non-zero.
</details>

<details>
<summary>Hint 3: Extension Syntax</summary>
Extension syntax: `extension Name on Type { returnType methodName() { ... } }`
</details>

## Starter Code

See `main.dart` - implement the `toMovieLength()` method.

## Testing

Run with:
```bash
dart run
```

Expected output should match the examples above.

## Solution

See `../solutions/001-movie-length.dart` after completing the exercise.

---

[← Back to Extensions Index](../README.md)
