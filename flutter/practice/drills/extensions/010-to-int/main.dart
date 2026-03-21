/// Exercise 10: String To Int (Safe Parse)
/// Time: 5 min | Difficulty: 1
///
/// Create an extension on `String` to safely parse to int.
/// Returns null if parsing fails.
///
/// Examples:
/// ```dart
/// '123'.toIntOrNull()     // 123
/// 'abc'.toIntOrNull()     // null
/// '-45'.toIntOrNull()     // -45
/// '  42  '.toIntOrNull()  // 42
/// ```

extension StringToInt on String {
  // TODO: Implement toIntOrNull() method
}

void main() {
  // Test cases
  print('123'.toIntOrNull());      // Expected: 123
  print('abc'.toIntOrNull());      // Expected: null
  print('-45'.toIntOrNull());      // Expected: -45
  print('  42  '.toIntOrNull());   // Expected: 42
  print(''.toIntOrNull());         // Expected: null
  print('12.34'.toIntOrNull());    // Expected: null
}
