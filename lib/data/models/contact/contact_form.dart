/*
{
                "id": "0e8248d7-a605-493e-a53e-779a37e3b92b",
                "uid": "",
                "contact_name": "duy",
                "contact_email": "duyntt2002@gmail.com",
                "contact_phone": "091823901283",
                "contact_message": "I have a question about..."
            }

*/

import 'package:json_annotation/json_annotation.dart';
part 'contact_form.g.dart';

@JsonSerializable()
class ContactForm {
  @JsonKey(name: 'contact_name')
  final String contactName;
  @JsonKey(name: 'contact_email')
  final String contactEmail;
  @JsonKey(name: 'contact_phone')
  final String contactPhone;
  @JsonKey(name: 'contact_message')
  final String contactMessage;

  const ContactForm({
    required this.contactName,
    required this.contactEmail,
    required this.contactPhone,
    required this.contactMessage,
  });

  factory ContactForm.fromJson(Map<String, dynamic> json) =>
      _$ContactFormFromJson(json);

  Map<String, dynamic> toJson() => _$ContactFormToJson(this);
}
