/// Exercise 7: String Truncate
/// Time: 5 min | Difficulty: 1
///
/// Create an extension on `String` to truncate to max length with optional suffix.
///
/// Examples:
/// ```dart
/// 'Hello World'.truncate(5)           // 'Hello...'
/// 'Hi'.truncate(10)                   // 'Hi'
/// 'Hello World'.truncate(5, '')       // 'Hello'
/// 'Hello World'.truncate(5, ' [more]')// 'Hello [more]'
/// ```

extension StringTruncate on String {
  // TODO: Implement truncate(int maxLength, {String suffix}) method
}

void main() {
  // Test cases
  print('Hello World'.truncate(5));            // Expected: 'Hello...'
  print('Hi'.truncate(10));                    // Expected: 'Hi'
  print('Hello World'.truncate(5, ''));        // Expected: 'Hello'
  print('Hello World'.truncate(5, ' [more]')); // Expected: 'Hello [more]'
  print(''.truncate(5));                       // Expected: ''
}
