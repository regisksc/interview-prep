/// Exercise 19: String Is Palindrome
/// Time: 10 min | Difficulty: 2
///
/// Check if string is palindrome (case insensitive, ignoring spaces).
///
/// Examples:
/// ```dart
/// 'radar'.isPalindrome           // true
/// 'A man a plan a canal Panama'.isPalindrome  // true
/// 'hello'.isPalindrome           // false
/// ```

extension StringPalindrome on String {
  // TODO: Implement isPalindrome getter
}

void main() {
  print('radar'.isPalindrome);                      // Expected: true
  print('A man a plan a canal Panama'.isPalindrome); // Expected: true
  print('hello'.isPalindrome);                      // Expected: false
  print(''.isPalindrome);                           // Expected: true
  print('a'.isPalindrome);                          // Expected: true
}
