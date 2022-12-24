// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItem _$CartItemFromJson(Map<String, dynamic> json) => CartItem(
      RevenueSource.fromJson(json['revenueSource'] as Map<String, dynamic>),
      (json['amount'] as num).toDouble(),
      json['quantity'] as int,
      json['description'] as String?,
    );

Map<String, dynamic> _$CartItemToJson(CartItem instance) => <String, dynamic>{
      'revenueSource': instance.revenueSource.toJson(),
      'amount': instance.amount,
      'quantity': instance.quantity,
      'description': instance.description,
    };
