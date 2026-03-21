/// Solution: DateTime Age

extension DateTimeAge on DateTime {
  int get age {
    final now = DateTime.now();
    var age = now.year - year;

    // Adjust if birthday hasn't occurred this year
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }

    return age;
  }
}

void main() {
  print(DateTime(2000, 1, 1).age);    // 26 (in 2026)
  print(DateTime(2020, 1, 1).age);    // 6
}
