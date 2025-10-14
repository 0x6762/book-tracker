String cleanIsbn(String input) {
  return input.replaceAll(RegExp(r'[^0-9Xx]'), '').toUpperCase();
}

bool isIsbn13(String code) {
  final c = cleanIsbn(code);
  return c.length == 13 && (c.startsWith('978') || c.startsWith('979'));
}

bool isIsbn10(String code) {
  final c = cleanIsbn(code);
  return c.length == 10 && RegExp(r'^[0-9]{9}[0-9X]$').hasMatch(c);
}

String? toIsbn10(String isbn13) {
  final c = cleanIsbn(isbn13);
  if (c.length != 13 || !(c.startsWith('978') || c.startsWith('979')))
    return null;
  final core = c.substring(3, 12);
  int sum = 0;
  for (int i = 0; i < 9; i++) {
    sum += (int.parse(core[i]) * (10 - i));
  }
  int check = 11 - (sum % 11);
  String checkChar;
  if (check == 10) {
    checkChar = 'X';
  } else if (check == 11) {
    checkChar = '0';
  } else {
    checkChar = check.toString();
  }
  return core + checkChar;
}

String? toIsbn13(String isbn10) {
  final c = cleanIsbn(isbn10);
  if (c.length != 10 || !RegExp(r'^[0-9]{9}[0-9X]$').hasMatch(c)) return null;
  final core = '978' + c.substring(0, 9);
  int sum = 0;
  for (int i = 0; i < core.length; i++) {
    final digit = int.parse(core[i]);
    sum += (i % 2 == 0) ? digit : digit * 3;
  }
  final check = (10 - (sum % 10)) % 10;
  return core + check.toString();
}
