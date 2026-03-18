/// Exercise 6: Map Safe Get with Default
/// Time: 5 min | Difficulty: 1
///
/// Create an extension on `Map<K, V>` to safely get values with a default fallback.
///
/// Examples:
/// ```dart
/// {'a': 1}.getOr('a', 0)     // 1
/// {'a': 1}.getOr('b', 0)     // 0
/// {}.getOr('x', 'def')       // 'def'
/// ```

extension MapSafeGet<K, V> on Map<K, V> {
  // TODO: Implement getOr(K key, V defaultValue) method
}

void main() {
  // Test cases
  print({'a': 1}.getOr('a', 0));      // Expected: 1
  print({'a': 1}.getOr('b', 0));      // Expected: 0
  print({}.getOr('x', 'default'));    // Expected: 'default'
  print({'name': 'John'}.getOr('name', 'Unknown'));  // Expected: 'John'
}
