enum AppLanguage { US, VN }

extension AppLanguageExtension on AppLanguage {
  String get displayName {
    switch (this) {
      case AppLanguage.US:
        return 'English';
      case AppLanguage.VN:
        return 'Tiếng Việt';
    }
  }
}
