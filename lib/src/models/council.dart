import 'package:json_annotation/json_annotation.dart';

part 'council.g.dart';

@JsonSerializable(explicitToJson: true)
class Council {
  final String postalAddress;
  final String mobileNumber;
  final String email;

  Council(this.postalAddress, this.mobileNumber, this.email,);

  factory Council.fromJson(Map<String, dynamic> json) =>
      _$CouncilFromJson(json);

  Map<String, dynamic> toJson() => _$CouncilToJson(this);
}
