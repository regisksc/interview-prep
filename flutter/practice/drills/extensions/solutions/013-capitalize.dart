/// Solution: String Capitalize

extension StringCapitalize on String {
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}

void main() {
  print('hello'.capitalize);    // 'Hello'
  print('HELLO'.capitalize);    // 'Hello'
  print(''.capitalize);         // ''
  print('h'.capitalize);        // 'H'
}
