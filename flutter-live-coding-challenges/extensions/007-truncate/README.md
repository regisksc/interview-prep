# Exercise 7: String Truncate

**Time**: 5 min | **Difficulty**: 1 | **Topic**: Extension Methods

---

## Challenge

Create an extension on `String` that truncates the string to a maximum length with an optional suffix.

## Requirements

1. Create an extension on `String`
2. Implement a method `truncate(int maxLength, {String suffix = '...'})`
3. If string length <= maxLength, return original string
4. If string length > maxLength, truncate and add suffix
5. Suffix should be customizable via named parameter

## Examples

```dart
'Hello World'.truncate(5)           // 'Hello...'
'Hi'.truncate(10)                   // 'Hi'
'Hello World'.truncate(5, '')       // 'Hello'
'Hello World'.truncate(5, '!')      // 'Hello!'
'Hello World'.truncate(100)         // 'Hello World'
```

## Hints

<details>
<summary>Hint 1: Substring</summary>
Use `substring(0, maxLength)` to get the truncated portion.
</details>

<details>
<summary>Hint 2: Named parameter</summary>
Use `{String suffix = '...'}` for optional parameter with default.
</details>

<details>
<summary>Hint 3: Length check</summary>
Check `length > maxLength` before truncating.
</details>

## Starter Code

See `main.dart` - implement the `truncate(int maxLength, {String suffix})` method.

## Testing

Run with:
```bash
dart run
```

---

[← Back to Extensions Index](../README.md)
