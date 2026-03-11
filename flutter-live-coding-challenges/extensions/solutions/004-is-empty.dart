/// Solution: String Is Empty or Blank

extension StringNullCheck on String? {
  bool get isEmptyOrBlank => this?.trim().isEmpty ?? true;
}

void main() {
  print((null as String?).isEmptyOrBlank);  // true
  print(''.isEmptyOrBlank);                 // true
  print('   '.isEmptyOrBlank);              // true
  print('hello'.isEmptyOrBlank);            // false
  print(' hi '.isEmptyOrBlank);             // false
  print('\t\n'.isEmptyOrBlank);             // true
}
