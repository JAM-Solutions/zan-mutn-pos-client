// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_configuration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PosConfiguration _$PosConfigurationFromJson(Map<String, dynamic> json) =>
    PosConfiguration(
      json['id'] as int,
      json['uuid'] as String,
      (json['offlineLimit'] as num).toDouble(),
      (json['amountLimit'] as num).toDouble(),
      json['posDeviceId'] as int,
      json['posDeviceName'] as String,
      json['posDeviceNumber'] as String,
      json['lastUpdate'] as String,
    );

Map<String, dynamic> _$PosConfigurationToJson(PosConfiguration instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'offlineLimit': instance.offlineLimit,
      'amountLimit': instance.amountLimit,
      'posDeviceId': instance.posDeviceId,
      'posDeviceNumber': instance.posDeviceNumber,
      'posDeviceName': instance.posDeviceName,
      'lastUpdate': instance.lastUpdate,
    };
