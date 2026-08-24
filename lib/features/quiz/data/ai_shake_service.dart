import 'package:numi/core/network/network_client.dart';

class AIShakeService {
  AIShakeService({
    NetworkClient? networkClient,
    this.cooldown = const Duration(minutes: 15),
  }) : _networkClient = networkClient ?? NetworkClient.shared;

  static final shared = AIShakeService();

  final NetworkClient _networkClient;
  final Duration cooldown;

  DateTime? _lastAttemptAt;
  Future<void>? _inFlight;

  Future<void> aiShake() {
    final inFlight = _inFlight;
    if (inFlight != null) {
      return inFlight;
    }

    final now = DateTime.now();
    final lastAttemptAt = _lastAttemptAt;
    if (lastAttemptAt != null && now.difference(lastAttemptAt) < cooldown) {
      return Future<void>.value();
    }

    _lastAttemptAt = now;
    final request = _pingAi()
        .catchError((Object _) {})
        .whenComplete(() => _inFlight = null);
    _inFlight = request;
    return request;
  }

  Future<void> _pingAi() async {
    final json = await _networkClient.postJson(
      '/ai/shake',
      const <String, dynamic>{},
    );
    NetworkClient.throwForApiStatus(json);
  }
}
