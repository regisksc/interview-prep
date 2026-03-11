/// Solution: List Without Nulls

extension ListWithoutNulls<T> on List<T?> {
  List<T> get withoutNulls => whereType<T>().toList();
}

void main() {
  print([1, null, 2, null, 3].withoutNulls);  // [1, 2, 3]
  print([].withoutNulls);                      // []
  print([null, null].withoutNulls);            // []
}
