import 'package:flutter_test/flutter_test.dart';
import 'package:numi/core/debug/debug_request_metrics.dart';

void main() {
  test('accounts for completed and failed requests without payload data', () {
    final logs = <String>[];
    final metrics = DebugRequestMetrics(log: logs.add);

    final first = metrics.recordStarted(method: 'GET', path: '/profiles');
    metrics.recordCompleted(
      requestNumber: first,
      method: 'GET',
      path: '/profiles',
      elapsed: const Duration(milliseconds: 12),
      statusCode: 200,
      failed: false,
    );
    final second = metrics.recordStarted(method: 'POST', path: '/auth/login');
    metrics.recordCompleted(
      requestNumber: second,
      method: 'POST',
      path: '/auth/login',
      elapsed: const Duration(milliseconds: 18),
      statusCode: 401,
      failed: true,
    );

    expect(metrics.snapshot.started, 2);
    expect(metrics.snapshot.succeeded, 1);
    expect(metrics.snapshot.failed, 1);
    expect(logs.join('\n'), isNot(contains('authorization')));
  });
}
