/// Solution: Map Invert

extension MapInvert<K, V> on Map<K, V> {
  Map<V, K> invert() => Map.fromEntries(entries.map((e) => MapEntry(e.value, e.key)));
}

void main() {
  print({'a': 1, 'b': 2}.invert);    // {1: 'a', 2: 'b'}
  print({}.invert);                   // {}
}
