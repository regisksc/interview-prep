/// Solution: Minutes to Movie Length

extension MovieLengthExtension on int {
  String toMovieLength() {
    if (this <= 0) return '';

    final hours = this ~/ 60;
    final minutes = this % 60;

    if (hours == 0) return '${minutes}min';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}min';
  }
}

void main() {
  // Test cases
  print(60.toMovieLength());   // '1h'
  print(80.toMovieLength());   // '1h 20min'
  print(120.toMovieLength());  // '2h'
  print(145.toMovieLength());  // '2h 25min'
  print(5.toMovieLength());    // '5min'
  print(0.toMovieLength());    // ''
  print(200.toMovieLength());  // '3h 20min'
}
