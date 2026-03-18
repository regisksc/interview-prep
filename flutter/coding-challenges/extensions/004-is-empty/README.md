# Exercise 4: String Is Empty or Blank

**Time**: 5 min | **Difficulty**: 1 | **Topic**: Extension Methods, Null Safety

---

## Challenge

Create an extension on `String?` (nullable string) that checks if the string is null, empty, or contains only whitespace.

## Requirements

1. Create an extension on `String?` (nullable)
2. Implement a getter called `isEmptyOrBlank`
3. Return `true` if: string is `null`, empty `""`, or only whitespace `"   "`
4. Return `false` otherwise

## Examples

```dart
null.isEmptyOrBlank          // true
''.isEmptyOrBlank            // true
'   '.isEmptyOrBlank         // true
'hello'.isEmptyOrBlank       // false
'  content  '.isEmptyOrBlank // false
' '.isEmptyOrBlank           // true
```

## Hints

<details>
<summary>Hint 1: Null check</summary>
Use `== null` check first in the condition.
</details>

<details>
<summary>Hint 2: Trim</summary>
Consider using `trim()` to handle whitespace-only strings.
</details>

<details>
<summary>Hint 3: isEmpty</summary>
Dart strings have an `isEmpty` property.
</details>

## Starter Code

See `main.dart` - implement the `isEmptyOrBlank` getter.

## Testing

Run with:
```bash
dart run
```

---

[← Back to Extensions Index](../README.md)
