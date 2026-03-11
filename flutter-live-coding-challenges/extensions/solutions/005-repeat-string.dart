/// Solution: Int Repeat String

extension IntRepeat on int {
  String times(String str) {
    if (this <= 0 || str.isEmpty) return '';
    return List.filled(this, str).join();
  }
}

void main() {
  print(3.times('ab'));     // 'ababab'
  print(0.times('x'));      // ''
  print(1.times('hello'));  // 'hello'
  print(5.times('x'));      // 'xxxxx'
  print((-1).times('a'));   // ''
}
