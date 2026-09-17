import 'package:flutter_test/flutter_test.dart';
import 'package:numi/features/auth/data/device_api_models.dart';

void main() {
  test('serializes a device list request', () {
    const request = DeviceListRequest(userId: 21, isVerified: true);

    expect(request.toJson(), <String, dynamic>{
      'user_id': 21,
      'is_verified': true,
    });
  });

  test('parses a device list response', () {
    final response = DeviceListResponse.fromJson(<String, dynamic>{
      'devices': <Map<String, dynamic>>[
        <String, dynamic>{
          'create_dt': '2026-07-01T11:43:56.552244Z',
          'device_id': 4,
          'device_name': 'TECNO SPARK Go 1',
          'device_uuid': 'UP1A.231005.007',
          'is_verified': true,
          'modify_dt': '2026-07-08T16:37:18.116911Z',
          'platform': 'UNKNOWN',
          'status': 'ACTIVE',
          'user_id': 21,
        },
      ],
      'mstatus': 200,
      'status': 'Success',
    });

    expect(response.mstatus, 200);
    expect(response.status, 'Success');
    expect(response.devices, hasLength(1));

    final device = response.devices.single;
    expect(device.deviceId, 4);
    expect(device.deviceName, 'TECNO SPARK Go 1');
    expect(device.deviceUuid, 'UP1A.231005.007');
    expect(device.isVerified, isTrue);
    expect(device.platform, 'UNKNOWN');
    expect(device.status, 'ACTIVE');
    expect(device.userId, 21);
    expect(device.createDt, '2026-07-01T11:43:56.552244Z');
    expect(device.modifyDt, '2026-07-08T16:37:18.116911Z');
  });
}
