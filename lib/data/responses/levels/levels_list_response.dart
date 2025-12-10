import 'package:json_annotation/json_annotation.dart';

import '../../models/levels/level_model.dart';
import '../../models/grades/metadata_model.dart';
import '../base/base_response.dart';

part 'levels_list_response.g.dart';

@JsonSerializable(explicitToJson: true)
class LevelsListResponse extends BaseResponse {
  @JsonKey(name: 'result')
  final LevelsResult? result;

  LevelsListResponse({String? blockUtilDt, this.result});

  factory LevelsListResponse.fromJson(Map<String, dynamic> json) =>
      _$LevelsListResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LevelsListResponseToJson(this);

  
  List<LevelModel>? get levels => result?.items;
  MetadataModel? get metadata => result?.metadata;
}

@JsonSerializable(explicitToJson: true)
class LevelsResult {
  @JsonKey(name: 'items')
  final List<LevelModel>? items;

  @JsonKey(name: 'metadata')
  final MetadataModel? metadata;

  LevelsResult({this.items, this.metadata});

  factory LevelsResult.fromJson(Map<String, dynamic> json) =>
      _$LevelsResultFromJson(json);

  Map<String, dynamic> toJson() => _$LevelsResultToJson(this);
}
