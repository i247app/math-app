import 'package:json_annotation/json_annotation.dart';

import '../../../enum/m_status_code.dart';
import '../../../utils/utc_timestamp_converter.dart';

part 'base_response.g.dart';

@JsonSerializable(explicitToJson: true)
class BaseResponse {
  @JsonKey(name: 'block_until_dt')
  @UtcTimestampConverter()
  String? blockUtilDt;
  @JsonKey(name: 'status')
  int? status;

  @JsonKey(name: 'error')
  String? error;

  @JsonKey(name: 'message')
  String? message;

  /// HTTP request data
  @JsonKey(includeFromJson: false, includeToJson: false)
  int httpStatusCode = 0;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String httpReasonPhrase = "";
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<String, String> httpHeaders = {};

  BaseResponse({
    this.status,
    this.error,
    this.message,
    this.blockUtilDt,
  });

  factory BaseResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseResponseFromJson(json);

  factory BaseResponse.fromJsonWithCode(Map<String, dynamic> json, int code) {
    final instance = _$BaseResponseFromJson(json);
    instance.httpStatusCode = code;
    return instance;
  }

  Map<String, dynamic> toJson() => _$BaseResponseToJson(this);

  bool get isSuccess => status == MStatusCode.success.value;

  bool get isDuplicateSuccess => status == MStatusCode.duplicateSuccess.value;

  bool get isHttpSuccess => httpStatusCode == MStatusCode.success.value;
}
