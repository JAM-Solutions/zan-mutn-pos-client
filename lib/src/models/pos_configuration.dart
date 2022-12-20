import 'package:json_annotation/json_annotation.dart';

part 'pos_configuration.g.dart';

@JsonSerializable(explicitToJson: true)
class PosConfiguration {
  final int id;
  final String uuid;
  final double offlineLimit;
  final double amountLimit;
  final int posDeviceId;
  final String posDeviceNumber;
  final String posDeviceName;
  final String lastUpdate;

  PosConfiguration(this.id, this.uuid, this.offlineLimit, this.amountLimit,
      this.posDeviceId, this.posDeviceName, this.posDeviceNumber, this.lastUpdate);

  factory PosConfiguration.fromJson(Map<String, dynamic> json) =>
      _$PosConfigurationFromJson(json);

  Map<String, dynamic> toJson() => _$PosConfigurationToJson(this);
}
