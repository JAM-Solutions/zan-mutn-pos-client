// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      json['id'] as int,
      json['firstName'] as String?,
      json['lastName'] as String?,
      json['email'] as String,
      json['adminHierarchyId'] as int?,
      json['taxPayerId'] as int?,
      json['adminHierarchyName'] as String?,
      json['taxPayerUuid'] as String?,
      json['taxCollectorId'] as int?,
      json['taxCollectorUuid'] as String?,
      json['collectionPointName'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'adminHierarchyId': instance.adminHierarchyId,
      'taxPayerId': instance.taxPayerId,
      'taxCollectorId': instance.taxCollectorId,
      'taxPayerUuid': instance.taxPayerUuid,
      'taxCollectorUuid': instance.taxCollectorUuid,
      'adminHierarchyName': instance.adminHierarchyName,
      'collectionPointName': instance.collectionPointName,
    };
