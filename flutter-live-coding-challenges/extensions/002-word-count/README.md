# Exercise 2: String Word Count

**Time**: 5 min | **Difficulty**: 1 | **Topic**: Extension Methods

---

## Challenge

Create an extension on `String` that counts the number of words in the string.

## Requirements

1. Create an extension on the `String` type
2. Implement a getter called `wordCount` that returns an `int`
3. Words are separated by whitespace
4. Multiple spaces between words count as one separator
5. Empty or whitespace-only strings return 0

## Examples

```dart
'Hello world'.wordCount           // 2
'One'.wordCount                   // 1
'  Multiple   spaces  '.wordCount // 2
''.wordCount                      // 0
'   '.wordCount                   // 0
'Three word phrase'.wordCount     // 3
```

## Hints

<details>
<summary>Hint 1: Split</summary>
Consider using `split()` with a pattern for whitespace.
</details>

<details>
<summary>Hint 2: Trim</summary>
Think about handling leading/trailing whitespace efficiently.
</details>

<details>
<summary>Hint 3: RegExp</summary>
A regular expression can split on any whitespace sequence.
</details>

## Starter Code

See `main.dart` - implement the `wordCount` getter.

## Testing

Run with:
```bash
dart run
```

---

[← Back to Extensions Index](../README.md)
