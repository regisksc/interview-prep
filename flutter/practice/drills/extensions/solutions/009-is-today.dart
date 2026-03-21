/// Solution: DateTime Is Today

extension DateTimeToday on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}

void main() {
  print(DateTime.now().isToday);           // true
  print(DateTime(2020, 1, 1).isToday);     // false
  print(DateTime(2000, 1, 1).isToday);     // false
}
