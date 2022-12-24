import 'package:json_annotation/json_annotation.dart';
import 'package:zanmutm_pos_client/src/models/revenue_source.dart';

part 'cart_item.g.dart';

@JsonSerializable(explicitToJson: true)
class CartItem {
  final RevenueSource revenueSource;
  final double amount;
  final int quantity;
  final String? description;

  CartItem(this.revenueSource, this.amount, this.quantity, this.description);

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemToJson(this);
}
