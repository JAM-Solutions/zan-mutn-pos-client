import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class User {
  final int id;
  final String? firstName;
  final String? lastName;
  final String email;
  final int? adminHierarchyId;
  final int? taxPayerId;
  final int? taxCollectorId;
  final String? taxPayerUuid;
  final String? taxCollectorUuid;
  final String? adminHierarchyName;
  final String? collectionPointName;

  User(
      this.id,
      this.firstName,
      this.lastName,
      this.email,
      this.adminHierarchyId,
      this.taxPayerId,
      this.adminHierarchyName,
      this.taxPayerUuid,
      this.taxCollectorId,
      this.taxCollectorUuid, this.collectionPointName);

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
