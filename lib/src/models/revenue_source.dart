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

  RevenueSource(this.id, this.uuid, this.name, this.gfsCode,
      this.isMiscellaneous, this.isActive);

  factory RevenueSource.fromJson(Map<String, dynamic> json) =>
      _$RevenueSourceFromJson({
        ...json,
        'isMiscellaneous': int.tryParse(json['isMiscellaneous'].toString()) != null
            ? (json['isMiscellaneous'] == 1)
            : json['isMiscellaneous'],
        'isActive': int.tryParse(json['isActive'].toString()) != null
            ? (json['isActive'] == 1)
            : json['isActive']
      });

  Map<String, dynamic> toJson() => _$RevenueSourceToJson(this);
}
