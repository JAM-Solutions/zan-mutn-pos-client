// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppDeviceInfo _$AppDeviceInfoFromJson(Map<String, dynamic> json) =>
    AppDeviceInfo(
      json['id'] as String,
      json['brand'] as String,
      json['manufacturer'] as String,
      json['model'] as String,
    );

Map<String, dynamic> _$AppDeviceInfoToJson(AppDeviceInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'brand': instance.brand,
      'manufacturer': instance.manufacturer,
      'model': instance.model,
    };
