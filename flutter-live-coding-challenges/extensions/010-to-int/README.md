# Exercise 10: String To Int (Safe Parse)

**Time**: 5 min | **Difficulty**: 1 | **Topic**: Extension Methods, Error Handling

---

## Challenge

Create an extension on `String` that safely parses to an integer, returning `null` on failure.

## Requirements

1. Create an extension on `String`
2. Implement a method `toIntOrNull()` that returns `int?`
3. Return the parsed integer if successful
4. Return `null` if the string is not a valid integer
5. Handle whitespace by trimming before parsing

## Examples

```dart
'123'.toIntOrNull()     // 123
'abc'.toIntOrNull()     // null
'-45'.toIntOrNull()     // -45
'  42  '.toIntOrNull()  // 42
''.toIntOrNull()        // null
'12.34'.toIntOrNull()   // null (not a valid int format)
```

## Hints

<details>
<summary>Hint 1: Try-catch</summary>
Use try-catch to handle `FormatException` from `int.parse()`.
</details>

<details>
<summary>Hint 2: int.tryParse</summary>
Dart has `int.tryParse()` which returns null on failure.
</details>

<details>
<summary>Hint 3: Trim</summary>
Call `trim()` before parsing to handle whitespace.
</details>

## Starter Code

See `main.dart` - implement the `toIntOrNull()` method.

## Testing

Run with:
```bash
dart run
```

---

[← Back to Extensions Index](../README.md)
