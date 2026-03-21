/// Exercise 3: List First and Last (Safe Access)
/// Time: 5 min | Difficulty: 1
///
/// Create extensions on `List<T>` to get first and last elements safely.
/// Returns null if the list is empty.
///
/// Examples:
/// ```dart
/// [1, 2, 3].firstSafe    // 1
/// [].firstSafe           // null
/// [5].lastSafe           // 5
/// [].lastSafe            // null
/// ```

extension ListSafeAccess<T> on List<T> {
  // TODO: Implement firstSafe getter
  // TODO: Implement lastSafe getter
}

void main() {
  // Test cases
  print([1, 2, 3].firstSafe);  // Expected: 1
  print([].firstSafe);         // Expected: null
  print([5].lastSafe);         // Expected: 5
  print([].lastSafe);          // Expected: null
  print(['a', 'b'].firstSafe); // Expected: 'a'
  print(['a', 'b'].lastSafe);  // Expected: 'b'
}
