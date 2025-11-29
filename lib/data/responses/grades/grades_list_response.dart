import 'package:json_annotation/json_annotation.dart';

import '../../models/grades/grade_model.dart';
import '../../models/grades/metadata_model.dart';
import '../base/base_response.dart';

part 'grades_list_response.g.dart';

@JsonSerializable(explicitToJson: true)
class GradesListResponse extends BaseResponse {
  @JsonKey(name: 'result')
  final GradesResult? result;

  GradesListResponse({this.result});

  factory GradesListResponse.fromJson(Map<String, dynamic> json) =>
      _$GradesListResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GradesListResponseToJson(this);

  // Helper getters for easier access
  List<GradeModel>? get grades => result?.items;
  MetadataModel? get metadata => result?.metadata;
}

@JsonSerializable(explicitToJson: true)
class GradesResult {
  @JsonKey(name: 'items')
  final List<GradeModel>? items;

  @JsonKey(name: 'metadata')
  final MetadataModel? metadata;

  GradesResult({this.items, this.metadata});

  factory GradesResult.fromJson(Map<String, dynamic> json) =>
      _$GradesResultFromJson(json);

  Map<String, dynamic> toJson() => _$GradesResultToJson(this);
}
