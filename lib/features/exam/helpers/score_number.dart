double scoreNumber(String value) {
  return double.tryParse(value.trim()) ?? 0;
}
