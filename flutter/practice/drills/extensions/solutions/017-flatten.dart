/// Solution: List Flatten

extension ListFlatten<T> on List<List<T>> {
  List<T> flatten() => expand((e) => e).toList();
}

void main() {
  print([[1, 2], [3, 4], [5]].flatten());    // [1, 2, 3, 4, 5]
  print([[1], [], [2, 3]].flatten());        // [1, 2, 3]
  print(<List<int>>[].flatten());            // []
}
