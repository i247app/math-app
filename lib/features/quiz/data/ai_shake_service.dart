import 'package:numi/core/network/network_client.dart';

class AIShakeService {
  AIShakeService({
    NetworkApi? networkApi,
    this.cooldown = const Duration(minutes: 15),
  }) : _networkApi = networkApi ?? NetworkApi.shared;

  static final shared = AIShakeService();

  final NetworkApi _networkApi;
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
    final request = _networkApi
        .aiShake()
        .catchError((Object _) {})
        .whenComplete(() => _inFlight = null);
    _inFlight = request;
    return request;
  }
}
