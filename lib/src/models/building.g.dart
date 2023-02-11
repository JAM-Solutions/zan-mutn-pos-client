// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'building.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Building _$BuildingFromJson(Map<String, dynamic> json) => Building(
      json['houseNumber'] as String,
      json['buildingCategoryId'] as int,
      json['location'] as String,
      json['status'] as String,
      json['id'] as int
    );

Map<String, dynamic> _$BuildingToJson(Building instance) => <String, dynamic>{
      'houseNumber': instance.houseNumber,
      'buildingCategoryId': instance.buildingCategoryId,
      'location': instance.location,
      'status': instance.status,
      'id': instance.id
    };
