/// Solution: Map Safe Get with Default

extension MapSafeGet<K, V> on Map<K, V> {
  V getOr(K key, V defaultValue) {
    return this[key] ?? defaultValue;
  }
}

void main() {
  print({'a': 1}.getOr('a', 0));      // 1
  print({'a': 1}.getOr('b', 0));      // 0
  print({}.getOr('x', 'default'));    // 'default'
  print({'name': 'John'}.getOr('name', 'Unknown'));  // 'John'
}
