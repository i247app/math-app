// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_up_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignUpResponse _$SignUpResponseFromJson(Map<String, dynamic> json) =>
    SignUpResponse(
      status: (json['status'] as num?)?.toInt(),
      error: json['error'] as String?,
      message: json['message'] as String?,
      blockUtilDt: json['block_until_dt'] as String?,
      result: json['result'] == null
          ? null
          : User.fromJson(json['result'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SignUpResponseToJson(SignUpResponse instance) =>
    <String, dynamic>{
      'block_until_dt': instance.blockUtilDt,
      'status': instance.status,
      'error': instance.error,
      'message': instance.message,
      'result': instance.result?.toJson(),
    };
