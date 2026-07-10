/// A resource created for one authenticated session. Implementations should
/// release cache and subscriptions in [dispose].
abstract interface class SessionScopedResource {
  void dispose();
}

/// Keeps repositories alive across profile switches, but disposes every
/// resource when the user/session epoch changes or when the user logs out.
class SessionScopedRepositoryRegistry {
  int? _activeSessionEpoch;
  final Map<String, SessionScopedResource> _resources =
      <String, SessionScopedResource>{};

  int get activeSessionEpoch => _activeSessionEpoch ?? 0;

  void updateSession({
    required bool isAuthenticated,
    required int sessionEpoch,
  }) {
    if (!isAuthenticated) {
      _activeSessionEpoch = null;
      _disposeAll();
      return;
    }
    if (_activeSessionEpoch == sessionEpoch) {
      return;
    }
    _activeSessionEpoch = sessionEpoch;
    _disposeAll();
  }

  T getOrCreate<T extends SessionScopedResource>(
    String feature,
    T Function() create,
  ) {
    final existing = _resources[feature];
    if (existing != null) {
      if (existing is T) {
        return existing;
      }
      throw StateError('Resource "$feature" was registered with another type.');
    }

    final resource = create();
    _resources[feature] = resource;
    return resource;
  }

  void dispose() {
    _activeSessionEpoch = null;
    _disposeAll();
  }

  void _disposeAll() {
    final resources = _resources.values.toList(growable: false);
    _resources.clear();
    for (final resource in resources) {
      resource.dispose();
    }
  }
}
