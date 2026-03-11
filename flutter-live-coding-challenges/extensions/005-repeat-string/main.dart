/// Exercise 5: Int Repeat String
/// Time: 5 min | Difficulty: 1
///
/// Create an extension on `int` to repeat a string N times.
///
/// Examples:
/// ```dart
/// 3.times('ab')      // 'ababab'
/// 0.times('x')       // ''
/// 1.times('hello')   // 'hello'
/// ```

extension IntRepeat on int {
  // TODO: Implement times(String) method
}

void main() {
  // Test cases
  print(3.times('ab'));     // Expected: 'ababab'
  print(0.times('x'));      // Expected: ''
  print(1.times('hello'));  // Expected: 'hello'
  print(5.times('x'));      // Expected: 'xxxxx'
  print((-1).times('a'));   // Expected: ''
}
