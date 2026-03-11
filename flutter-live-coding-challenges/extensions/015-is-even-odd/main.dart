/// Exercise 15: Int Is Even/Odd
/// Time: 5 min | Difficulty: 1
///
/// Create extensions on `int` to check if even or odd.
///
/// Examples:
/// ```dart
/// 4.isEven    // true
/// 7.isOdd     // true
/// 0.isEven    // true
/// ```

extension IntParity on int {
  // TODO: Implement isEven getter
  // TODO: Implement isOdd getter
}

void main() {
  print(4.isEven);    // Expected: true
  print(7.isOdd);     // Expected: true
  print(0.isEven);    // Expected: true
  print(1.isOdd);     // Expected: true
  print((-2).isEven); // Expected: true
}
