/// Exercise 20: List Zip
/// Time: 10 min | Difficulty: 2
///
/// Zip two lists together into pairs.
/// Stops at the shorter list length.
///
/// Examples:
/// ```dart
/// [1, 2, 3].zip([4, 5, 6])    // [(1,4), (2,5), (3,6)]
/// [1, 2].zip([3, 4, 5, 6])    // [(1,3), (2,4)]
/// [].zip([1, 2])              // []
/// ```

extension ListZip<T> on List<T> {
  // TODO: Implement zip<U>(List<U> other) method
}

void main() {
  print([1, 2, 3].zip([4, 5, 6]));     // Expected: [(1,4), (2,5), (3,6)]
  print([1, 2].zip([3, 4, 5, 6]));     // Expected: [(1,3), (2,4)]
  print([].zip([1, 2]));               // Expected: []
  print(['a', 'b'].zip([1, 2]));       // Expected: [(a,1), (b,2)]
}
