/// Exercise 17: List Flatten
/// Time: 10 min | Difficulty: 2
///
/// Flatten a nested list one level deep.
///
/// Examples:
/// ```dart
/// [[1, 2], [3, 4], [5]].flatten()    // [1, 2, 3, 4, 5]
/// [[1], [], [2, 3]].flatten()        // [1, 2, 3]
/// ```

extension ListFlatten<T> on List<List<T>> {
  // TODO: Implement flatten() method
}

void main() {
  print([[1, 2], [3, 4], [5]].flatten());    // Expected: [1, 2, 3, 4, 5]
  print([[1], [], [2, 3]].flatten());        // Expected: [1, 2, 3]
  print(<List<int>>[].flatten());            // Expected: []
}
