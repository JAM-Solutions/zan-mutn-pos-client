import 'package:json_annotation/json_annotation.dart';

part 'household.g.dart';

@JsonSerializable(explicitToJson: true)
class Households {
  final String taxPayerName;
  final String paymentModeName;

  Households(this.taxPayerName, this.paymentModeName);

  factory Households.fromJson(Map<String, dynamic> json) =>
      _$HouseholdsFromJson(json);

  Map<String, dynamic> toJson() => _$HouseholdsToJson(this);
}
