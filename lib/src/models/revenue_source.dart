import 'package:json_annotation/json_annotation.dart';

part 'revenue_source.g.dart';

@JsonSerializable(explicitToJson: true)
class RevenueSource {
  final int id;
  final String uuid;
  final String name;
  final String gfsCode;
  final bool isMiscellaneous;
  final bool isActive;
  final bool? penalty;
  final String? penaltyMode;
  final double? minimumAmount;
  final double? unitCost;
  final double? maximumAmount;
  final String? unitName;

  RevenueSource(
      this.id,
      this.uuid,
      this.name,
      this.gfsCode,
      this.isMiscellaneous,
      this.isActive,
      this.penalty,
      this.penaltyMode,
      this.minimumAmount,
      this.maximumAmount,
      this.unitName,
      this.unitCost);

  factory RevenueSource.fromJson(Map<String, dynamic> json) =>
      _$RevenueSourceFromJson({
        ...json,
        'isMiscellaneous':
            int.tryParse(json['isMiscellaneous'].toString()) != null
                ? (json['isMiscellaneous'] == 1)
                : json['isMiscellaneous'],
        'isActive': int.tryParse(json['isActive'].toString()) != null
            ? (json['isActive'] == 1)
            : json['isActive'],
        'penalty': int.tryParse(json['penalty'].toString()) != null
            ? (json['penalty'] == 1)
            : json['penalty']
      });

  Map<String, dynamic> toJson() => _$RevenueSourceToJson(this);
}
