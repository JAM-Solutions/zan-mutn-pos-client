// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RevenueItem _$RevenueItemFromJson(Map<String, dynamic> json) => RevenueItem(
      RevenueSource.fromJson(json['revenueSource'] as Map<String, dynamic>),
      (json['amount'] as num).toDouble(),
      json['quantity'] as int,
      json['description'] as String?,
    );

Map<String, dynamic> _$RevenueItemToJson(RevenueItem instance) =>
    <String, dynamic>{
      'revenueSource': instance.revenueSource.toJson(),
      'amount': instance.amount,
      'quantity': instance.quantity,
      'description': instance.description,
    };
