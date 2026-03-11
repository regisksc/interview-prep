/// Solution: List First and Last (Safe Access)

extension ListSafeAccess<T> on List<T> {
  T? get firstSafe => isEmpty ? null : this[0];
  T? get lastSafe => isEmpty ? null : this[length - 1];
}

void main() {
  print([1, 2, 3].firstSafe);  // 1
  print([].firstSafe);         // null
  print([5].lastSafe);         // 5
  print([].lastSafe);          // null
  print(['a', 'b'].firstSafe); // 'a'
  print(['a', 'b'].lastSafe);  // 'b'
}
