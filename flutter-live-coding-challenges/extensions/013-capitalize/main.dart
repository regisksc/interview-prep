/// Exercise 13: String Capitalize
/// Time: 5 min | Difficulty: 1
///
/// Create an extension on `String` to capitalize first letter.
///
/// Examples:
/// ```dart
/// 'hello'.capitalize    // 'Hello'
/// 'HELLO'.capitalize    // 'Hello'
/// ''.capitalize         // ''
/// ```

extension StringCapitalize on String {
  // TODO: Implement capitalize() method
}

void main() {
  print('hello'.capitalize);    // Expected: 'Hello'
  print('HELLO'.capitalize);    // Expected: 'Hello'
  print(''.capitalize);         // Expected: ''
  print('h'.capitalize);        // Expected: 'H'
}
