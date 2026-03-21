# Exercise 19: String Is Palindrome

**Time**: 10 min | **Difficulty**: 2 | **Topic**: Extension Methods, String Manipulation

---

## Challenge

Create an extension on `String` that checks if the string is a palindrome.

## Requirements

1. Create an extension on `String`
2. Implement a getter called `isPalindrome` that returns a `bool`
3. Ignore case (case-insensitive comparison)
4. Ignore spaces and non-alphanumeric characters
5. A palindrome reads the same forwards and backwards

## Examples

```dart
'radar'.isPalindrome           // true
'A man a plan a canal Panama'.isPalindrome  // true
'hello'.isPalindrome           // false
'Was it a car or a cat I saw'.isPalindrome  // true
''.isPalindrome                // true (empty string is palindrome)
'a'.isPalindrome               // true
```

## Hints

<details>
<summary>Hint 1: Clean the string</summary>
Remove non-alphanumeric characters and convert to lowercase first.
</details>

<details>
<summary>Hint 2: Reverse comparison</summary>
Compare the cleaned string with its reverse.
</details>

<details>
<summary>Hint 3: RegExp</summary>
Use `replaceAll(RegExp(r'[^a-z0-9]'), '')` to clean.
</details>

## Starter Code

See `main.dart` - implement the `isPalindrome` getter.

## Testing

Run with:
```bash
dart run
```

---

[← Back to Extensions Index](../README.md)
