// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseResponse _$BaseResponseFromJson(Map<String, dynamic> json) => BaseResponse(
  status: (json['status'] as num?)?.toInt(),
  error: json['error'] as String?,
  message: json['message'] as String?,
  blockUtilDt: json['block_until_dt'] as String?,
);

Map<String, dynamic> _$BaseResponseToJson(BaseResponse instance) =>
    <String, dynamic>{
      'block_until_dt': instance.blockUtilDt,
      'status': instance.status,
      'error': instance.error,
      'message': instance.message,
    };
