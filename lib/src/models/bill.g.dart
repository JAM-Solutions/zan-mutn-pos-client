// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bill _$BillFromJson(Map<String, dynamic> json) => Bill(
      json['id'] as int,
      json['uuid'] as String,
      json['dueTime'] == null
          ? null
          : DateTime.parse(json['dueTime'] as String),
      json['expireDate'] == null
          ? null
          : DateTime.parse(json['expireDate'] as String),
      (json['amount'] as num).toDouble(),
      json['controlNumber'] as String?,
      json['statusName'] as String?,
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$BillToJson(Bill instance) => <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'dueTime': instance.dueTime?.toIso8601String(),
      'expireDate': instance.expireDate?.toIso8601String(),
      'amount': instance.amount,
      'controlNumber': instance.controlNumber,
      'statusName': instance.statusName,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
