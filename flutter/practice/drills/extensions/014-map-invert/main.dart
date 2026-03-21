/// Exercise 14: Map Invert
/// Time: 10 min | Difficulty: 2
///
/// Create an extension on `Map<K, V>` to invert keys and values.
///
/// Examples:
/// ```dart
/// {'a': 1, 'b': 2}.invert    // {1: 'a', 2: 'b'}
/// {}.invert                   // {}
/// ```

extension MapInvert<K, V> on Map<K, V> {
  // TODO: Implement invert() method
}

void main() {
  print({'a': 1, 'b': 2}.invert);    // Expected: {1: 'a', 2: 'b'}
  print({}.invert);                   // Expected: {}
}
