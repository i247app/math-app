DateTime historyDateValue(String? value) {
  return DateTime.tryParse(value?.trim() ?? '')?.toLocal() ??
      DateTime.fromMillisecondsSinceEpoch(0);
}
