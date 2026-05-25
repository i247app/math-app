class SemesterListRequest {
  const SemesterListRequest({required this.userId});

  final String userId;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'user_id': userId};
  }
}

class SemesterListResponse {
  const SemesterListResponse({
    required this.mstatus,
    this.semesters = const <SemesterModel>[],
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final List<SemesterModel> semesters;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory SemesterListResponse.fromJson(Map<String, dynamic> json) {
    return SemesterListResponse(
      mstatus: _intFromJson(json['mstatus']) ?? 0,
      semesters: _listFromJson(json['semesters'], SemesterModel.fromJson),
      status: json['status'] as String?,
      mmessage: json['mmessage'] as String?,
      debug: json['debug'] as String?,
    );
  }
}

class SemesterModel {
  const SemesterModel({
    this.id,
    this.semesterId,
    this.name,
    this.description,
    this.displayOrder,
    this.imageUrl,
    this.createDt,
    this.modifyDt,
  });

  final String? id;
  final String? semesterId;
  final String? name;
  final String? description;
  final int? displayOrder;
  final String? imageUrl;
  final String? createDt;
  final String? modifyDt;

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
      id: json['id']?.toString(),
      semesterId: json['semester_id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      displayOrder: _intFromJson(json['display_order']),
      imageUrl: json['image_url'] as String?,
      createDt: json['create_dt'] as String?,
      modifyDt: json['modify_dt'] as String?,
    );
  }
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

int? _intFromJson(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}
