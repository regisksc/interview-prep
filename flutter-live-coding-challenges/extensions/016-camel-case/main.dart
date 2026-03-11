/// Exercise 16: String Camel Case
/// Time: 10 min | Difficulty: 2
///
/// Convert string to camelCase.
/// Handles spaces, dashes, underscores as separators.
///
/// Examples:
/// ```dart
/// 'hello world'.toCamelCase()      // 'helloWorld'
/// 'Hello World'.toCamelCase()      // 'helloWorld'
/// 'hello-world'.toCamelCase()      // 'helloWorld'
/// 'hello_world'.toCamelCase()      // 'helloWorld'
/// ```

extension StringCamelCase on String {
  // TODO: Implement toCamelCase() method
}

void main() {
  print('hello world'.toCamelCase());    // Expected: 'helloWorld'
  print('Hello World'.toCamelCase());    // Expected: 'helloWorld'
  print('hello-world'.toCamelCase());    // Expected: 'helloWorld'
  print('hello_world'.toCamelCase());    // Expected: 'helloWorld'
  print(''.toCamelCase());               // Expected: ''
}
