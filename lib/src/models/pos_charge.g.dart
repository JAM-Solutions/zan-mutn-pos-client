// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_charge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PosCharge _$PosChargeFromJson(Map<String, dynamic> json) => PosCharge(
      json['id'] as int,
      json['uuid'] as String,
      json['taxCollectorId'] as int?,
      json['billReferenceNo'] as String?,
      json['financialYearId'] as int?,
      json['isActive'] as bool?,
      json['completeDate'] == null
          ? null
          : DateTime.parse(json['completeDate'] as String),
      (json['amount'] as num).toDouble(),
      (json['transactions'] as List<dynamic>)
          .map((e) => PosTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PosChargeToJson(PosCharge instance) => <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'taxCollectorId': instance.taxCollectorId,
      'billReferenceNo': instance.billReferenceNo,
      'financialYearId': instance.financialYearId,
      'isActive': instance.isActive,
      'completeDate': instance.completeDate?.toIso8601String(),
      'amount': instance.amount,
      'transactions': instance.transactions.map((e) => e.toJson()).toList(),
    };
