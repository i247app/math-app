import 'package:json_annotation/json_annotation.dart';
part 'user.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: 'id')
  String? id;

  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'email')
  String? email;

  @JsonKey(name: 'phone')
  String? phone;

  @JsonKey(name: 'password')
  String? password;

  @JsonKey(name: 'avatar_url')
  String? avatarUrl;

  @JsonKey(name: 'role')
  String? role;

  @JsonKey(name: 'created_at')
  String? createdAt;

  @JsonKey(name: 'modified_at')
  String? modifiedAt;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.password,
    this.avatarUrl,
    this.role,
    this.createdAt,
    this.modifiedAt,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? password,
    String? avatarUrl,
    String? role,
    String? createdAt,
    String? modifiedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
