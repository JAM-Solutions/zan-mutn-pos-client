// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revenue_source_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RevenueSourceConfig _$RevenueSourceConfigFromJson(Map<String, dynamic> json) =>
    RevenueSourceConfig(
      json['id'] as int,
      json['uuid'] as String,
      (json['unitCost'] as num).toDouble(),
      json['unitName'] as String,
      (json['minimumAmount'] as num?)?.toDouble(),
      (json['maximumAmount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$RevenueSourceConfigToJson(
        RevenueSourceConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'unitCost': instance.unitCost,
      'unitName': instance.unitName,
      'minimumAmount': instance.minimumAmount,
      'maximumAmount': instance.maximumAmount,
    };
