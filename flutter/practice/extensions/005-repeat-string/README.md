# Exercise 5: Int Repeat String

**Time**: 5 min | **Difficulty**: 1 | **Topic**: Extension Methods

---

## Challenge

Create an extension on `int` that repeats a given string N times.

## Requirements

1. Create an extension on `int`
2. Implement a method `times(String)` that returns a `String`
3. The integer value determines how many times to repeat the string
4. Return empty string if count is 0 or negative

## Examples

```dart
3.times('ab')      // 'ababab'
0.times('x')       // ''
1.times('hello')   // 'hello'
(-1).times('y')    // ''
2.times('123')     // '123123'
```

## Hints

<details>
<summary>Hint 1: String concatenation</summary>
Use a loop or built-in method to build the repeated string.
</details>

<details>
<summary>Hint 2: Edge case</summary>
Handle zero and negative values by returning empty string.
</details>

<details>
<summary>Hint 3: List join</summary>
Consider using `List.filled().join()` for a concise solution.
</details>

## Starter Code

See `main.dart` - implement the `times(String)` method.

## Testing

Run with:
```bash
dart run
```

---

[← Back to Extensions Index](../README.md)
