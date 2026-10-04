/// Synchronously clears in-memory account data and invalidates pending writes.
/// Called by the session owner before exposing a new account or ending one.
abstract interface class SessionDataCleaner {
  void clear();
}
