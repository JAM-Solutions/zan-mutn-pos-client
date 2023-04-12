// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_registration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PosRegistration _$PosRegistrationFromJson(Map<String, dynamic> json) =>
    PosRegistration(
      json['id'] as int,
      json['imei'] as String,
      json['serialNumber'] as String,
    );

Map<String, dynamic> _$PosRegistrationToJson(PosRegistration instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imei': instance.imei,
      'serialNumber': instance.serialNumber,
    };
