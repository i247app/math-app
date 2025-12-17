import 'package:json_annotation/json_annotation.dart';

part 'contact_model.g.dart';

@JsonSerializable()
class ContactModel {
  final String id;
  final String uid;

  @JsonKey(name: 'contact_name')
  final String contactName;

  @JsonKey(name: 'contact_email')
  final String contactEmail;

  @JsonKey(name: 'contact_phone')
  final String contactPhone;

  @JsonKey(name: 'contact_message')
  final String contactMessage;
  @JsonKey(name: 'is_read')
  final bool? isRead;

  ContactModel({
    required this.id,
    required this.uid,
    required this.contactName,
    required this.contactEmail,
    required this.contactPhone,
    required this.contactMessage,
    this.isRead,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) =>
      _$ContactModelFromJson(json);

  Map<String, dynamic> toJson() => _$ContactModelToJson(this);
}
