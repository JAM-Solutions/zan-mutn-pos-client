// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revenue_source.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RevenueSource _$RevenueSourceFromJson(Map<String, dynamic> json) =>
    RevenueSource(
      json['id'] as int,
      json['uuid'] as String,
      json['name'] as String,
      json['gfsCode'] as String,
      json['isMiscellaneous'] as bool,
      json['isActive'] as bool,
      json['penalty'] as bool?,
      json['penaltyMode'] as String?,
      (json['minimumAmount'] as num?)?.toDouble(),
      (json['maximumAmount'] as num?)?.toDouble(),
      json['unitName'] as String?,
    );

Map<String, dynamic> _$RevenueSourceToJson(RevenueSource instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'name': instance.name,
      'gfsCode': instance.gfsCode,
      'isMiscellaneous': instance.isMiscellaneous,
      'isActive': instance.isActive,
      'penalty': instance.penalty,
      'penaltyMode': instance.penaltyMode,
      'minimumAmount': instance.minimumAmount,
      'maximumAmount': instance.maximumAmount,
      'unitName': instance.unitName,
    };
