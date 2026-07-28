import 'package:json_annotation/json_annotation.dart';

part 'notification_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class NotificationListRequest {
  const NotificationListRequest({this.page, this.size, this.takeAll});

  final int? page;
  final int? size;
  final bool? takeAll;

  factory NotificationListRequest.fromJson(Map<String, dynamic> json) =>
      _$NotificationListRequestFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationListRequestToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class NotificationListResponse {
  const NotificationListResponse({
    required this.mstatus,
    this.notifications = const <NotificationModel>[],
    this.pagination,
    this.status,
    this.mmessage,
    this.debug,
  });

  @JsonKey(fromJson: _requiredIntFromJson)
  final int mstatus;
  @JsonKey(fromJson: _notificationListFromJson)
  final List<NotificationModel> notifications;
  @JsonKey(fromJson: _notificationPaginationFromJson)
  final NotificationPagination? pagination;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationListResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class NotificationPagination {
  const NotificationPagination({
    this.hasNext,
    this.hasPrevious,
    this.page,
    this.size,
    this.skip,
    this.takeAll,
    this.totalCount,
    this.totalPages,
  });

  final bool? hasNext;
  final bool? hasPrevious;
  @JsonKey(fromJson: _intFromJson)
  final int? page;
  @JsonKey(fromJson: _intFromJson)
  final int? size;
  @JsonKey(fromJson: _intFromJson)
  final int? skip;
  final bool? takeAll;
  @JsonKey(fromJson: _intFromJson)
  final int? totalCount;
  @JsonKey(fromJson: _intFromJson)
  final int? totalPages;

  factory NotificationPagination.fromJson(Map<String, dynamic> json) =>
      _$NotificationPaginationFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationPaginationToJson(this);
}

/// A notification item returned by the backend.
///
/// The list response provided by the API currently contains no sample item.
/// Common fields are exposed as typed values while [rawJson] preserves every
/// backend field so callers do not lose data when the item schema is extended.
class NotificationModel {
  NotificationModel({
    required Map<String, dynamic> rawJson,
    this.id,
    this.notificationId,
    this.title,
    this.message,
    this.body,
    this.type,
    this.status,
    this.isRead,
    this.readAt,
    this.createDt,
    this.modifyDt,
  }) : rawJson = Map<String, dynamic>.unmodifiable(rawJson);

  final Map<String, dynamic> rawJson;
  final int? id;
  final int? notificationId;
  final String? title;
  final String? message;
  final String? body;
  final String? type;
  final String? status;
  final bool? isRead;
  final String? readAt;
  final String? createDt;
  final String? modifyDt;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      rawJson: json,
      id: _intFromJson(json['id']),
      notificationId: _intFromJson(json['notification_id']),
      title: _stringFromJson(json['title']),
      message: _stringFromJson(json['message']),
      body: _stringFromJson(json['body']),
      type: _stringFromJson(json['type']),
      status: _stringFromJson(json['status']),
      isRead: _boolFromJson(json['is_read']),
      readAt: _stringFromJson(json['read_at']),
      createDt: _stringFromJson(json['create_dt'] ?? json['created_at']),
      modifyDt: _stringFromJson(json['modify_dt'] ?? json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(rawJson);

  int? get stableId => notificationId ?? id;
}

NotificationPagination? _notificationPaginationFromJson(Object? value) {
  return _objectFromJson(value, NotificationPagination.fromJson);
}

List<NotificationModel> _notificationListFromJson(Object? value) {
  return _listFromJson(value, NotificationModel.fromJson);
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

bool? _boolFromJson(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }

  return switch (value?.toString().trim().toLowerCase()) {
    'true' || '1' => true,
    'false' || '0' => false,
    _ => null,
  };
}

String? _stringFromJson(Object? value) => value?.toString();
