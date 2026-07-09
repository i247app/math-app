/// Application configuration loaded at compile-time via `--dart-define` or
/// `--dart-define-from-file`. Values are injected by the build system and
/// **never** bundled as plain-text assets, making them harder to extract from
/// a release binary.
///
/// Usage:
///   flutter run --dart-define-from-file=config/env.dev.json
///   flutter build apk --dart-define-from-file=config/env.prod.json
abstract final class ApiConfig {
  /// The base URL for all API requests.
  ///
  /// Set via: `--dart-define=API_BASE_URL=https://api.example.com`
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://x21.i247.com/go',
  );
}
