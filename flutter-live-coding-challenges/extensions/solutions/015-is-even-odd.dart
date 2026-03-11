/// Solution: Int Is Even/Odd

extension IntParity on int {
  bool get isEven => this % 2 == 0;
  bool get isOdd => this % 2 != 0;
}

void main() {
  print(4.isEven);    // true
  print(7.isOdd);     // true
  print(0.isEven);    // true
  print(1.isOdd);     // true
  print((-2).isEven); // true
}
