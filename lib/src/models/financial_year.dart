import 'package:json_annotation/json_annotation.dart';

part 'financial_year.g.dart';

@JsonSerializable(explicitToJson: true)
class FinancialYear {
  final int id;
  final String uuid;
  final String startDate;
  final String endDate;
  final String name;
  final bool isCurrent;
  final String? lastUpdate;

  FinancialYear(this.id, this.uuid, this.startDate, this.endDate, this.name, this.isCurrent, this.lastUpdate);

  factory FinancialYear.fromJson(Map<String, dynamic> json) => _$FinancialYearFromJson(json);
  Map<String, dynamic> toJson() =>_$FinancialYearToJson(this);

}
