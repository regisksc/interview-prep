/// Solution: String Word Count

extension WordCountExtension on String {
  int get wordCount {
    if (trim().isEmpty) return 0;
    return split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }
}

void main() {
  print('Hello world'.wordCount);           // 2
  print('One'.wordCount);                   // 1
  print('  Multiple   spaces  '.wordCount); // 2
  print(''.wordCount);                      // 0
  print('   '.wordCount);                   // 0
  print('single'.wordCount);                // 1
}
