/// Strips all non-digit characters from [value].
///
/// Single source of truth for phone normalization across the app.
/// Use this everywhere instead of inline replaceAll calls.
String normalizePhone(String value) =>
    value.replaceAll(RegExp(r'[^0-9]'), '');
