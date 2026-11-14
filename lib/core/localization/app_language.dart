import 'dart:ui';

enum AppLanguage {
  vi('vi-VN', 'vi', 'Tiếng Việt'),
  en('en-US', 'en', 'English');

  const AppLanguage(this.apiCode, this.lookupCode, this.displayName);

  final String apiCode;
  final String lookupCode;
  final String displayName;

  AppLanguageCode get localeCode => AppLanguageCode.tryParse(apiCode)!;

  static AppLanguage fromCode(String? code) {
    return AppLanguageCode.tryParse(code)?.language ?? AppLanguage.vi;
  }

  static AppLanguage fromDevice(Locale locale) {
    return switch (locale.languageCode.toLowerCase()) {
      'en' => AppLanguage.en,
      'vi' => AppLanguage.vi,
      _ => AppLanguage.vi,
    };
  }
}

/// A supported language with its region, independent of a service's separator.
class AppLanguageCode {
  const AppLanguageCode._(this.language, this.region);

  final AppLanguage language;
  final String region;

  String get languageCode => language.lookupCode;
  String get languageTag => '$languageCode-$region';
  String get underscoreCode => '${languageCode}_$region';
  String get ttsCode => languageTag;

  static AppLanguageCode? tryParse(String? value) {
    final match = RegExp(
      r'^([a-z]{2})(?:-([a-z]{2}|[0-9]{3}))?$',
      caseSensitive: false,
    ).firstMatch(value?.trim().replaceAll('_', '-') ?? '');
    if (match == null) return null;
    final language = switch (match[1]!.toLowerCase()) {
      'vi' => AppLanguage.vi,
      'en' => AppLanguage.en,
      _ => null,
    };
    if (language == null) return null;
    final region = match[2]?.toUpperCase() ?? language.apiCode.split('-').last;
    return AppLanguageCode._(language, region);
  }
}

class AppLanguageState {
  AppLanguageState._();

  static AppLanguage current = AppLanguage.vi;

  static String get currentApiCode => current.apiCode;
}
