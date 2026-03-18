/// Exercise 2: String Word Count
/// Time: 5 min | Difficulty: 1
///
/// Create an extension on `String` that counts the number of words.
/// Words are separated by whitespace. Multiple spaces count as one separator.
///
/// Examples:
/// ```dart
/// 'Hello world'.wordCount           // 2
/// 'One'.wordCount                   // 1
/// '  Multiple   spaces  '.wordCount // 2
/// ''.wordCount                      // 0
/// ```

extension WordCountExtension on String {
  // TODO: Implement wordCount getter
}

void main() {
  // Test cases
  print('Hello world'.wordCount);           // Expected: 2
  print('One'.wordCount);                   // Expected: 1
  print('  Multiple   spaces  '.wordCount); // Expected: 2
  print(''.wordCount);                      // Expected: 0
  print('   '.wordCount);                   // Expected: 0
  print('single'.wordCount);                // Expected: 1
}
