import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/data/session_scoped_repository_registry.dart';

void main() {
  test(
    'retains resources for a session and disposes them when its epoch changes',
    () {
      final registry = SessionScopedRepositoryRegistry();
      final resource = _FakeResource();

      registry.updateSession(isAuthenticated: true, sessionEpoch: 1);
      expect(registry.getOrCreate('home', () => resource), same(resource));
      registry.updateSession(isAuthenticated: true, sessionEpoch: 1);
      expect(resource.disposeCount, 0);

      registry.updateSession(isAuthenticated: true, sessionEpoch: 2);
      expect(resource.disposeCount, 1);

      final nextResource = _FakeResource();
      registry.getOrCreate('home', () => nextResource);
      registry.updateSession(isAuthenticated: false, sessionEpoch: 3);
      expect(nextResource.disposeCount, 1);
    },
  );
}

class _FakeResource implements SessionScopedResource {
  int disposeCount = 0;

  @override
  void dispose() => disposeCount++;
}
