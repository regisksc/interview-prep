/// Solution: List Zip

extension ListZip<T> on List<T> {
  List<(T, U)> zip<U>(List<U> other) {
    final length = this.length < other.length ? this.length : other.length;
    return List.generate(length, (i) => (this[i], other[i]));
  }
}

void main() {
  print([1, 2, 3].zip([4, 5, 6]));     // [(1, 4), (2, 5), (3, 6)]
  print([1, 2].zip([3, 4, 5, 6]));     // [(1, 3), (2, 4)]
  print([].zip([1, 2]));               // []
  print(['a', 'b'].zip([1, 2]));       // [(a, 1), (b, 2)]
}
