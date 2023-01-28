// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buildings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Buildings _$BuildingsFromJson(Map<String, dynamic> json) => Buildings(
      json['houseNumber'] as String,
      json['building_category_id'] as int,
      json['location'] as String,
      json['status'] as String
    );

Map<String, dynamic> _$BuildingsToJson(Buildings instance) => <String, dynamic>{
      'houseNumber': instance.houseNumber,
      'building_category_id': instance.buildingCategoryid,
      'location': instance.location,
      'status': instance.status
    };
