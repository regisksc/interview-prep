/// Solution: String Camel Case

extension StringCamelCase on String {
  String toCamelCase() {
    if (isEmpty) return this;

    final words = split(RegExp(r'[\s\-_]+')).where((w) => w.isNotEmpty);
    final wordList = words.toList();

    if (wordList.isEmpty) return '';

    final first = wordList.first.toLowerCase();
    final rest = wordList.skip(1).map((w) =>
      w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1).toLowerCase()
    );

    return [first, ...rest].join();
  }
}

void main() {
  print('hello world'.toCamelCase());    // 'helloWorld'
  print('Hello World'.toCamelCase());    // 'helloWorld'
  print('hello-world'.toCamelCase());    // 'helloWorld'
  print('hello_world'.toCamelCase());    // 'helloWorld'
  print(''.toCamelCase());               // ''
}
