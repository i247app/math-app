class ProgramListRequest {
  const ProgramListRequest({required this.userId});

  final String userId;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'user_id': userId};
  }
}

class ProgramListResponse {
  const ProgramListResponse({
    required this.mstatus,
    this.programs = const <ProgramModel>[],
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final List<ProgramModel> programs;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory ProgramListResponse.fromJson(Map<String, dynamic> json) {
    return ProgramListResponse(
      mstatus: _intFromJson(json['mstatus']) ?? 0,
      programs: _listFromJson(json['programs'], ProgramModel.fromJson),
      status: json['status'] as String?,
      mmessage: json['mmessage'] as String?,
      debug: json['debug'] as String?,
    );
  }
}

class ProgramModel {
  const ProgramModel({
    this.id,
    this.programId,
    this.label,
    this.description,
    this.displayOrder,
    this.imageUrl,
    this.createDt,
    this.modifyDt,
  });

  final String? id;
  final String? programId;
  final String? label;
  final String? description;
  final int? displayOrder;
  final String? imageUrl;
  final String? createDt;
  final String? modifyDt;

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      id: json['id']?.toString(),
      programId: json['program_id'] as String?,
      label: json['label'] as String?,
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
