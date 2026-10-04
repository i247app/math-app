/// Identifies the session that started asynchronous cache updates.
///
/// Capture [current] before awaiting work and check [isCurrent] before writing
/// its result. Ending a session invalidates all previously captured scopes.
class SessionCacheScope {
  SessionCacheScope._();

  static SessionCacheScope _current = SessionCacheScope._();

  static SessionCacheScope get current => _current;

  bool get isCurrent => identical(this, _current);

  static void reset() => _current = SessionCacheScope._();
}
