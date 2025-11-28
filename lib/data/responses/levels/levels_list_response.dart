import 'package:json_annotation/json_annotation.dart';

import '../../models/levels/level_model.dart';
import '../../models/grades/metadata_model.dart';
import '../base/base_response.dart';

part 'levels_list_response.g.dart';

@JsonSerializable(explicitToJson: true)
class LevelsListResponse extends BaseResponse {
  @JsonKey(name: 'metadata')
  final MetadataModel? metadata;

  @JsonKey(name: 'result')
  final List<LevelModel>? result;

  LevelsListResponse({String? blockUtilDt, this.metadata, this.result});

  factory LevelsListResponse.fromJson(Map<String, dynamic> json) =>
      _$LevelsListResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LevelsListResponseToJson(this);
}
