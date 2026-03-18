# Exercise 9: DateTime Is Today

**Time**: 5 min | **Difficulty**: 1 | **Topic**: Extension Methods, DateTime

---

## Challenge

Create an extension on `DateTime` that checks if the date is today.

## Requirements

1. Create an extension on `DateTime`
2. Implement a getter called `isToday` that returns a `bool`
3. Compare year, month, and day with `DateTime.now()`
4. Time components (hour, minute, second) should not matter

## Examples

```dart
DateTime.now().isToday      // true
DateTime(2020, 1, 1).isToday // false
DateTime.now().subtract(Duration(days: 1)).isToday  // false
```

## Hints

<details>
<summary>Hint 1: Compare components</summary>
Compare `year`, `month`, and `day` properties separately.
</details>

<details>
<summary>Hint 2: DateTime.now()</summary>
Use `DateTime.now()` to get the current date for comparison.
</details>

<details>
<summary>Hint 3: isAtSameMoment</summary>
Alternatively, normalize both dates to midnight and compare.
</details>

## Starter Code

See `main.dart` - implement the `isToday` getter.

## Testing

Run with:
```bash
dart run
```

---

[← Back to Extensions Index](../README.md)
