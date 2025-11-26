import 'package:json_annotation/json_annotation.dart';

import '../../models/grades/grade_model.dart';
import '../../models/grades/metadata_model.dart';
import '../base/base_response.dart';

part 'grades_list_response.g.dart';

@JsonSerializable(explicitToJson: true)
class GradesListResponse extends BaseResponse {
  @JsonKey(name: 'metadata')
  final MetadataModel? metadata;

  @JsonKey(name: 'result')
  final List<GradeModel>? result;

  GradesListResponse({this.result, this.metadata});

  factory GradesListResponse.fromJson(Map<String, dynamic> json) =>
      _$GradesListResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GradesListResponseToJson(this);
}
