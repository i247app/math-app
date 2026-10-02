final _compactUtcPattern = RegExp(
  r'^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})(\.\d{1,6})?$',
);

/// Compact API timestamps have no timezone suffix but always represent UTC.
DateTime? tryParseApiDateTime(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return null;
  final match = _compactUtcPattern.firstMatch(text);
  if (match == null) return DateTime.tryParse(text);
  final datePart =
      '${match[1]}-${match[2]}-${match[3]}'
      'T${match[4]}:${match[5]}:${match[6]}';
  final date = DateTime.tryParse('$datePart${match[7] ?? ''}Z');
  // DateTime accepts overflowing dates; reject them for the API format.
  if (date == null || !date.toIso8601String().startsWith(datePart)) return null;
  return date;
}

DateTime parseApiDateTime(String value) =>
    tryParseApiDateTime(value) ??
    (throw FormatException('Invalid API timestamp', value));
