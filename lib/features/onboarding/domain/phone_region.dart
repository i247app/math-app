enum PhoneRegion {
  vn(
    code: '+84',
    flag: '🇻🇳',
    label: 'VN',
    minDigits: 9,
    maxDigits: 10,
    hint: '090 123 4567',
  ),
  us(
    code: '+1',
    flag: '🇺🇸',
    label: 'US',
    minDigits: 10,
    maxDigits: 10,
    hint: '202 555 0101',
  );

  const PhoneRegion({
    required this.code,
    required this.flag,
    required this.label,
    required this.minDigits,
    required this.maxDigits,
    required this.hint,
  });

  final String code;
  final String flag;
  final String label;
  final int minDigits;
  final int maxDigits;
  final String hint;
}
