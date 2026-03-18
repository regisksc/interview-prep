/// Exercise 12: List Without Nulls
/// Time: 5 min | Difficulty: 1
///
/// Create an extension on `List<T?>` to remove null values.
///
/// Examples:
/// ```dart
/// [1, null, 2, null, 3].withoutNulls  // [1, 2, 3]
/// [].withoutNulls                      // []
/// [null, null].withoutNulls            // []
/// ```

extension ListWithoutNulls<T> on List<T?> {
  // TODO: Implement withoutNulls getter
}

void main() {
  print([1, null, 2, null, 3].withoutNulls);  // Expected: [1, 2, 3]
  print([].withoutNulls);                      // Expected: []
  print([null, null].withoutNulls);            // Expected: []
}
