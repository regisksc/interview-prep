/// Exercise 8: List Chunk
/// Time: 10 min | Difficulty: 2
///
/// Create an extension on `List<T>` to split into chunks of given size.
///
/// Examples:
/// ```dart
/// [1, 2, 3, 4, 5].chunk(2)  // [[1, 2], [3, 4], [5]]
/// [1, 2, 3].chunk(3)        // [[1, 2, 3]]
/// [1, 2].chunk(5)           // [[1, 2]]
/// [].chunk(2)               // []
/// ```

extension ListChunk<T> on List<T> {
  // TODO: Implement chunk(int size) method
}

void main() {
  // Test cases
  print([1, 2, 3, 4, 5].chunk(2));  // Expected: [[1, 2], [3, 4], [5]]
  print([1, 2, 3].chunk(3));        // Expected: [[1, 2, 3]]
  print([1, 2].chunk(5));           // Expected: [[1, 2]]
  print([].chunk(2));               // Expected: []
  print([1, 2, 3, 4].chunk(2));     // Expected: [[1, 2], [3, 4]]
}
