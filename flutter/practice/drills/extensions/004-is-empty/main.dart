/// Exercise 4: String Is Empty or Blank
/// Time: 5 min | Difficulty: 1
///
/// Create an extension on `String?` to check if string is null, empty, or only whitespace.
///
/// Examples:
/// ```dart
/// null.isEmptyOrBlank        // true
/// ''.isEmptyOrBlank          // true
/// '   '.isEmptyOrBlank       // true
/// 'hello'.isEmptyOrBlank     // false
/// ' hi '.isEmptyOrBlank      // false
/// ```

extension StringNullCheck on String? {
  // TODO: Implement isEmptyOrBlank getter
}

void main() {
  // Test cases
  print((null as String?).isEmptyOrBlank);  // Expected: true
  print(''.isEmptyOrBlank);                 // Expected: true
  print('   '.isEmptyOrBlank);              // Expected: true
  print('hello'.isEmptyOrBlank);            // Expected: false
  print(' hi '.isEmptyOrBlank);             // Expected: false
  print('\t\n'.isEmptyOrBlank);             // Expected: true
}
