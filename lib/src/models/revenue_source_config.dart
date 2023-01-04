import 'package:json_annotation/json_annotation.dart';

part 'revenue_source_config.g.dart';

@JsonSerializable(explicitToJson: true)
class RevenueSourceConfig {
  final int id;
  final String uuid;
  final double unitCost;
  final String unitName;
  final double? minimumAmount;
  final double? maximumAmount;

  RevenueSourceConfig(this.id, this.uuid, this.unitCost, this.unitName,
      this.minimumAmount, this.maximumAmount);

  factory RevenueSourceConfig.formJson(Map<String, dynamic> json) =>
      _$RevenueSourceConfigFromJson(json);

  Map<String, dynamic> toJson() => _$RevenueSourceConfigToJson(this);
}
