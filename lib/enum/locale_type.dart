enum LocaleType { vn, us }

extension LocaleTypeExtension on LocaleType {
  String get localeCode {
    switch (this) {
      case LocaleType.vn:
        return 'vi_VN';
      case LocaleType.us:
        return 'en_US';
    }
  }
}
