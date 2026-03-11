# Exercise 13: String Capitalize

**Time**: 5 min | **Difficulty**: 1 | **Topic**: Extension Methods

---

## Challenge

Create an extension on `String` that capitalizes the first letter of the string.

## Requirements

1. Create an extension on `String`
2. Implement a method `capitalize()` that returns a `String`
3. First character should be uppercase
4. Remaining characters should be lowercase
5. Handle empty strings gracefully

## Examples

```dart
'hello'.capitalize    // 'Hello'
'HELLO'.capitalize    // 'Hello'
''.capitalize         // ''
'h'.capitalize        // 'H'
'hELLO wORLD'.capitalize  // 'Hello world'
```

## Hints

<details>
<summary>Hint 1: substring</summary>
Use `substring()` to separate first character from the rest.
</details>

<details>
<summary>Hint 2: toUpperCase/toLowerCase</summary>
Use these methods on the appropriate parts.
</details>

<details>
<summary>Hint 3: Edge case</summary>
Handle empty strings to avoid index errors.
</details>

## Starter Code

See `main.dart` - implement the `capitalize()` method.

## Testing

Run with:
```bash
dart run
```

---

[← Back to Extensions Index](../README.md)
