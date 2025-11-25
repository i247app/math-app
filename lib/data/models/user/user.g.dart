part of 'user_model.dart';

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String?,
  name: json['name'] as String?,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  password: json['password'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  role: json['role'] as String?,
  createdAt: json['created_at'] as String?,
  modifiedAt: json['modified_at'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'password': instance.password,
  'avatar_url': instance.avatarUrl,
  'role': instance.role,
  'created_at': instance.createdAt,
  'modified_at': instance.modifiedAt,
};
