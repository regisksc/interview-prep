/// Exercise 1: Minutes to Movie Length
/// Time: 5 min | Difficulty: 1
///
/// Create an extension on `int` that converts minutes to a movie length format.
///
/// Examples:
/// ```dart
/// 60.toMovieLength()     // '1h'
/// 80.toMovieLength()     // '1h 20min'
/// 120.toMovieLength()    // '2h'
/// 145.toMovieLength()    // '2h 25min'
/// 5.toMovieLength()      // '5min'
/// ```

extension MovieLengthExtension on int {
  // TODO: Implement toMovieLength() method
}

void main() {
  // Test cases
  print(60.toMovieLength());   // Expected: '1h'
  print(80.toMovieLength());   // Expected: '1h 20min'
  print(120.toMovieLength());  // Expected: '2h'
  print(145.toMovieLength());  // Expected: '2h 25min'
  print(5.toMovieLength());    // Expected: '5min'
  print(0.toMovieLength());    // Expected: ''
  print(200.toMovieLength());  // Expected: '3h 20min'
}
