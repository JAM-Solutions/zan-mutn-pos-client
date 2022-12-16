// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_year.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FinancialYear _$FinancialYearFromJson(Map<String, dynamic> json) =>
    FinancialYear(
      json['id'] as int,
      json['uuid'] as String,
      json['startDate'] as String,
      json['endDate'] as String,
      json['name'] as String,
      json['isCurrent'] as bool,
    );

Map<String, dynamic> _$FinancialYearToJson(FinancialYear instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'name': instance.name,
      'isCurrent': instance.isCurrent,
    };
