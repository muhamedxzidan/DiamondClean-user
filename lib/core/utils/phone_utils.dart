final _nonDigits = RegExp(r'[^0-9]');

/// Strips all non-digit characters from [value].
String normalizePhone(String value) => value.replaceAll(_nonDigits, '');
