import 'package:json_annotation/json_annotation.dart';

import '../../models/contact/contact_model.dart';
import '../../models/grades/metadata_model.dart';
import '../base/base_response.dart';

part 'list_contact_response.g.dart';

@JsonSerializable(explicitToJson: true)
class ListContactResponse extends BaseResponse {
  @JsonKey(name: 'result')
  final ContactListResult? result;

  ListContactResponse({this.result});

  factory ListContactResponse.fromJson(Map<String, dynamic> json) =>
      _$ListContactResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ListContactResponseToJson(this);

  List<ContactModel>? get items => result?.items;
  MetadataModel? get metadata => result?.metadata;
}

@JsonSerializable(explicitToJson: true)
class ContactListResult {
  @JsonKey(name: 'items')
  final List<ContactModel>? items;

  @JsonKey(name: 'metadata')
  final MetadataModel? metadata;

  ContactListResult({this.items, this.metadata});

  factory ContactListResult.fromJson(Map<String, dynamic> json) =>
      _$ContactListResultFromJson(json);

  Map<String, dynamic> toJson() => _$ContactListResultToJson(this);
}
