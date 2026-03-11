# Exercise 16: String To Camel Case

**Time**: 10 min | **Difficulty**: 2 | **Topic**: Extension Methods, String Manipulation

---

## Challenge

Create an extension on `String` that converts the string to camelCase format.

## Requirements

1. Create an extension on `String`
2. Implement a method `toCamelCase()` that returns a `String`
3. Split on spaces, hyphens, or underscores
4. First word is lowercase, subsequent words are capitalized
5. Remove all separators

## Examples

```dart
'hello world'.toCamelCase()      // 'helloWorld'
'Hello World'.toCamelCase()      // 'helloWorld'
'hello-world'.toCamelCase()      // 'helloWorld'
'hello_world'.toCamelCase()      // 'helloWorld'
'alreadyCamelCase'.toCamelCase() // 'alreadyCamelCase'
'   spaced  '.toCamelCase()      // 'spaced'
```

## Hints

<details>
<summary>Hint 1: RegExp split</summary>
Use `split()` with a RegExp that matches spaces, hyphens, and underscores.
</details>

<details>
<summary>Hint 2: Process words</summary>
Lowercase the first word, capitalize and join the rest.
</details>

<details>
<summary>Hint 3: Skip empty</summary>
Filter out empty strings from the split result.
</details>

## Starter Code

See `main.dart` - implement the `toCamelCase()` method.

## Testing

Run with:
```bash
dart run
```

---

[← Back to Extensions Index](../README.md)
