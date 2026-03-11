# Exercise 18: DateTime Age Calculator

**Time**: 10 min | **Difficulty**: 2 | **Topic**: Extension Methods, DateTime

---

## Challenge

Create an extension on `DateTime` that calculates a person's age from their birth date.

## Requirements

1. Create an extension on `DateTime` (representing birth date)
2. Implement a getter called `age` that returns an `int`
3. Calculate full years elapsed since the birth date
4. Account for whether birthday has occurred this year

## Examples

```dart
// Assuming current year is 2026
DateTime(2000, 1, 1).age       // 26 (if today is after Jan 1)
DateTime(2000, 12, 31).age     // 25 or 26 depending on current date
DateTime(1990, 5, 15).age      // Depends on current date
```

## Hints

<details>
<summary>Hint 1: DateTime.now()</summary>
Get current date with `DateTime.now()` for comparison.
</details>

<details>
<summary>Hint 2: Year difference</summary>
Start with `now.year - birth.year`.
</details>

<details>
<summary>Hint 3: Adjust for birthday</summary>
Subtract 1 if the birthday hasn't occurred yet this year (compare month/day).
</details>

## Starter Code

See `main.dart` - implement the `age` getter.

## Testing

Run with:
```bash
dart run
```

---

[← Back to Extensions Index](../README.md)
