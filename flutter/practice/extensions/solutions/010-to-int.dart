/// Solution: String To Int (Safe Parse)

extension StringToInt on String {
  int? toIntOrNull() {
    try {
      return int.parse(trim());
    } catch (_) {
      return null;
    }
  }
}

void main() {
  print('123'.toIntOrNull());      // 123
  print('abc'.toIntOrNull());      // null
  print('-45'.toIntOrNull());      // -45
  print('  42  '.toIntOrNull());   // 42
  print(''.toIntOrNull());         // null
  print('12.34'.toIntOrNull());    // null
}
