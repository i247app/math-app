import 'dart:ui';

enum AppLanguage {
  vi('vi-VN', 'vi', 'Tiếng Việt'),
  en('en-US', 'en', 'English');

  const AppLanguage(this.apiCode, this.lookupCode, this.displayName);

  final String apiCode;
  final String lookupCode;
  final String displayName;

  static AppLanguage fromCode(String? code) {
    final normalized = code?.trim().toLowerCase();
    return switch (normalized) {
      'en' || 'en-us' || 'en_us' => AppLanguage.en,
      'vi' || 'vi-vn' || 'vi_vn' => AppLanguage.vi,
      _ => AppLanguage.vi,
    };
  }

  static AppLanguage fromDevice(Locale locale) {
    return switch (locale.languageCode.toLowerCase()) {
      'en' => AppLanguage.en,
      'vi' => AppLanguage.vi,
      _ => AppLanguage.vi,
    };
  }
}

class AppLanguageState {
  AppLanguageState._();

  static AppLanguage current = AppLanguage.vi;

  static String get currentApiCode => current.apiCode;
}
