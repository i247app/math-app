import 'package:json_annotation/json_annotation.dart';

part 'device_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class DeviceListRequest {
  const DeviceListRequest({required this.userId, required this.isVerified});

  final int userId;
  final bool isVerified;

  factory DeviceListRequest.fromJson(Map<String, dynamic> json) =>
      _$DeviceListRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceListRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class DeviceListResponse {
  const DeviceListResponse({
    required this.mstatus,
    this.devices = const <DeviceModel>[],
    this.status,
    this.mmessage,
    this.debug,
  });

  @JsonKey(fromJson: _requiredIntFromJson)
  final int mstatus;
  @JsonKey(fromJson: _deviceListFromJson)
  final List<DeviceModel> devices;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory DeviceListResponse.fromJson(Map<String, dynamic> json) =>
      _$DeviceListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceListResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class DeviceModel {
  const DeviceModel({
    this.deviceId,
    this.deviceName,
    this.deviceUuid,
    this.isVerified,
    this.platform,
    this.status,
    this.userId,
    this.createDt,
    this.modifyDt,
  });

  @JsonKey(fromJson: _intFromJson)
  final int? deviceId;
  final String? deviceName;
  final String? deviceUuid;
  final bool? isVerified;
  final String? platform;
  final String? status;
  @JsonKey(fromJson: _intFromJson)
  final int? userId;
  final String? createDt;
  final String? modifyDt;

  factory DeviceModel.fromJson(Map<String, dynamic> json) =>
      _$DeviceModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceModelToJson(this);
}

List<DeviceModel> _deviceListFromJson(Object? value) {
  return _listFromJson(value, DeviceModel.fromJson);
}

List<T> _listFromJson<T>(
  Object? value,
  T Function(Map<String, dynamic> json) fromJson,
) {
  if (value is! List) {
    return <T>[];
  }

  return value
      .map((item) => _objectFromJson(item, fromJson))
      .whereType<T>()
      .toList();
}

T? _objectFromJson<T>(
  Object? value,
  T Function(Map<String, dynamic> json) fromJson,
) {
  if (value case final Map<String, dynamic> json) {
    return fromJson(json);
  }
  if (value case final Map<Object?, Object?> json) {
    return fromJson(Map<String, dynamic>.from(json));
  }
  return null;
}

int _requiredIntFromJson(Object? value) => _intFromJson(value) ?? 0;

int? _intFromJson(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}
