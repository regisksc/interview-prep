/// Exercise 9: DateTime Is Today
/// Time: 5 min | Difficulty: 1
///
/// Create an extension on `DateTime` to check if it's today.
/// Compare year, month, and day only (ignore time).
///
/// Examples:
/// ```dart
/// DateTime.now().isToday      // true
/// DateTime(2020, 1, 1).isToday // false
/// ```

extension DateTimeToday on DateTime {
  // TODO: Implement isToday getter
}

void main() {
  // Test cases
  print(DateTime.now().isToday);           // Expected: true
  print(DateTime(2020, 1, 1).isToday);     // Expected: false
  print(DateTime(2000, 1, 1).isToday);     // Expected: false
}
