import 'package:json_annotation/json_annotation.dart';

part 'pos_registration.g.dart';

@JsonSerializable(explicitToJson: true)
class PosRegistration {
  final int id;
  final String imei;
  final String serialNumber;

  PosRegistration(this.id, this.imei, this.serialNumber);

  factory PosRegistration.fromJson(Map<String, dynamic> json) =>
      _$PosRegistrationFromJson(json);

  Map<String, dynamic> toJson() => _$PosRegistrationToJson(this);
}
