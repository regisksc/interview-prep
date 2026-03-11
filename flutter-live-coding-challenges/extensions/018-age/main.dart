/// Exercise 18: DateTime Age
/// Time: 10 min | Difficulty: 2
///
/// Calculate age from birth date.
///
/// Examples:
/// ```dart
/// DateTime(2000, 1, 1).age    // 26 (in 2026)
/// ```

extension DateTimeAge on DateTime {
  // TODO: Implement age getter
}

void main() {
  print(DateTime(2000, 1, 1).age);    // Expected: 26 (in 2026)
  print(DateTime(2020, 1, 1).age);    // Expected: 6
}
