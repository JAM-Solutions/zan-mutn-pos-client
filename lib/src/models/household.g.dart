// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'household.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Households _$HouseholdsFromJson(Map<String, dynamic> json) => Households(
      json['taxPayerName'] as String,
      json['paymentModeName'] as String,
      json['controlNumber'],
    );

Map<String, dynamic> _$HouseholdsToJson(Households instance) =>
    <String, dynamic>{
      'taxPayerName': instance.taxPayerName,
      'paymentModeName': instance.paymentModeName,
    };
