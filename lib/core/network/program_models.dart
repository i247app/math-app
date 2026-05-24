class ProgramListRequest {
  const ProgramListRequest({
    required this.userId,
  });

  final String userId;

  factory ProgramListRequest.fromJson(Map<String, dynamic> json) {
    return ProgramListRequest(userId: json['user_id'] as String);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'user_id': userId};
  }
}

class ProgramListResponse {
  const ProgramListResponse({
    required this.mstatus,
    this.grades = const <ProgramGrade>[],
    this.pagination,
    this.status,
    this.mmessage,
    this.debug,
  });

  final int mstatus;
  final List<ProgramGrade> grades;
  final ProgramPagination? pagination;
  final String? status;
  final String? mmessage;
  final String? debug;

  factory ProgramListResponse.fromJson(Map<String, dynamic> json) {
    return ProgramListResponse(
      mstatus: _intFromJson(json['mstatus']) ?? 0,
      grades: _listFromJson(json['grades'], ProgramGrade.fromJson),
      pagination: _objectFromJson(
        json['pagination'],
        ProgramPagination.fromJson,
      ),
      status: json['status'] as String?,
      mmessage: json['mmessage'] as String?,
      debug: json['debug'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'mstatus': mstatus,
      'grades': grades.map((grade) => grade.toJson()).toList(),
      'pagination': pagination?.toJson(),
      'status': status,
      'mmessage': mmessage,
      'debug': debug,
    };
  }
}

class ProgramPagination {
  const ProgramPagination({
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
  final int? page;
  final int? size;
  final int? skip;
  final bool? takeAll;
  final int? totalCount;
  final int? totalPages;

  factory ProgramPagination.fromJson(Map<String, dynamic> json) {
    return ProgramPagination(
      hasNext: json['has_next'] as bool?,
      hasPrevious: json['has_previous'] as bool?,
      page: _intFromJson(json['page']),
      size: _intFromJson(json['size']),
      skip: _intFromJson(json['skip']),
      takeAll: json['take_all'] as bool?,
      totalCount: _intFromJson(json['total_count']),
      totalPages: _intFromJson(json['total_pages']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'has_next': hasNext,
      'has_previous': hasPrevious,
      'page': page,
      'size': size,
      'skip': skip,
      'take_all': takeAll,
      'total_count': totalCount,
      'total_pages': totalPages,
    };
  }
}

class ProgramGrade {
  const ProgramGrade({
    this.id,
    this.gradeId,
    this.label,
    this.description,
    this.displayOrder,
    this.imageUrl,
    this.createDt,
    this.modifyDt,
  });

  final String? id;
  final String? gradeId;
  final String? label;
  final String? description;
  final int? displayOrder;
  final String? imageUrl;
  final String? createDt;
  final String? modifyDt;

  factory ProgramGrade.fromJson(Map<String, dynamic> json) {
    return ProgramGrade(
      id: json['id']?.toString(),
      gradeId: json['grade_id'] as String?,
      label: json['label'] as String?,
      description: json['description'] as String?,
      displayOrder: _intFromJson(json['display_order']),
      imageUrl: json['image_url'] as String?,
      createDt: json['create_dt'] as String?,
      modifyDt: json['modify_dt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'grade_id': gradeId,
      'label': label,
      'description': description,
      'display_order': displayOrder,
      'image_url': imageUrl,
      'create_dt': createDt,
      'modify_dt': modifyDt,
    };
  }
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

int? _intFromJson(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}
