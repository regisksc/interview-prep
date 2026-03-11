/// Solution: List Chunk

extension ListChunk<T> on List<T> {
  List<List<T>> chunk(int size) {
    if (size <= 0 || isEmpty) return [];

    final result = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      final end = (i + size < length) ? i + size : length;
      result.add(sublist(i, end));
    }
    return result;
  }
}

void main() {
  print([1, 2, 3, 4, 5].chunk(2));  // [[1, 2], [3, 4], [5]]
  print([1, 2, 3].chunk(3));        // [[1, 2, 3]]
  print([1, 2].chunk(5));           // [[1, 2]]
  print([].chunk(2));               // []
  print([1, 2, 3, 4].chunk(2));     // [[1, 2], [3, 4]]
}
