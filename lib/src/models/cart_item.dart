import 'package:json_annotation/json_annotation.dart';
import 'package:zanmutm_pos_client/src/models/revenue_source.dart';

part 'cart_item.g.dart';

@JsonSerializable(explicitToJson: true)
class RevenueItem {
  final RevenueSource revenueSource;
  final double amount;
  final int quantity;
  final String? description;

  RevenueItem(this.revenueSource, this.amount, this.quantity, this.description);

  factory RevenueItem.fromJson(Map<String, dynamic> json) =>
      _$RevenueItemFromJson(json);

  Map<String, dynamic> toJson() => _$RevenueItemToJson(this);
}
