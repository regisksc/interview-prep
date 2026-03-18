/// Solution: String Is Palindrome

extension StringPalindrome on String {
  bool get isPalindrome {
    final cleaned = lowercase.replaceAll(RegExp(r'\s'), '');
    return cleaned == cleaned.split('').reversed.join();
  }
}

void main() {
  print('radar'.isPalindrome);                      // true
  print('A man a plan a canal Panama'.isPalindrome); // true
  print('hello'.isPalindrome);                      // false
  print(''.isPalindrome);                           // true
  print('a'.isPalindrome);                          // true
}
