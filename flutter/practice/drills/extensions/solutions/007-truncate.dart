/// Solution: String Truncate

extension StringTruncate on String {
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return substring(0, maxLength) + suffix;
  }
}

void main() {
  print('Hello World'.truncate(5));            // 'Hello...'
  print('Hi'.truncate(10));                    // 'Hi'
  print('Hello World'.truncate(5, ''));        // 'Hello'
  print('Hello World'.truncate(5, ' [more]')); // 'Hello [more]'
  print(''.truncate(5));                       // ''
}
