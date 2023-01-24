import 'package:json_annotation/json_annotation.dart';

part 'currency.g.dart';

@JsonSerializable(explicitToJson: true)
class Currency {
  final int id;
  final String uuid;
  final String name;
  final String? code;
  bool? isDefault;

  Currency(this.id, this.uuid, this.name, this.isDefault, this.code);

  factory Currency.fromJson(Map<String, dynamic> json) => _$CurrencyFromJson(json);

  Map<String, dynamic> toJson() => _$CurrencyToJson(this);

}
