/// Solution: Bool To Int

extension BoolToInt on bool {
  int toInt() => this ? 1 : 0;
}

void main() {
  print(true.toInt());    // 1
  print(false.toInt());   // 0
}
