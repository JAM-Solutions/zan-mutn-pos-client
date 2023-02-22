// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'council.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Council _$CouncilFromJson(Map<String, dynamic> json) => Council(
      json['postalAddress'] as String,
      json['mobileNumber'] as String,
      json['email'] as String,
    );

Map<String, dynamic> _$CouncilToJson(Council instance) => <String, dynamic>{
      'postalAddress': instance.postalAddress,
      'mobileNumber': instance.mobileNumber,
      'email': instance.email,
    };
