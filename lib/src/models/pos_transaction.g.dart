// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PosTransaction _$PosTransactionFromJson(Map<String, dynamic> json) =>
    PosTransaction(
      json['id'] as int?,
      json['txnNumber'] as String,
      json['posDeviceId'] as int,
      json['revenueSourceId'] as int,
      json['gfsCode'] as String,
      json['adminHierarchyId'] as int,
      json['taxPayerId'] as int,
      (json['amount'] as num).toDouble(),
      json['quantity'] as int,
      json['cashPayerName'] as String?,
      json['receiptNumber'] as String,
      DateTime.parse(json['transactionDate'] as String),
      json['isPrinted'] as bool,
      json['printError'] as String?,
      json['financialYearId'] as int,
      json['cashPayerAddress'] as String?,
    );

Map<String, dynamic> _$PosTransactionToJson(PosTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'txnNumber': instance.txnNumber,
      'posDeviceId': instance.posDeviceId,
      'revenueSourceId': instance.revenueSourceId,
      'gfsCode': instance.gfsCode,
      'adminHierarchyId': instance.adminHierarchyId,
      'taxPayerId': instance.taxPayerId,
      'amount': instance.amount,
      'quantity': instance.quantity,
      'cashPayerName': instance.cashPayerName,
      'cashPayerAddress': instance.cashPayerAddress,
      'receiptNumber': instance.receiptNumber,
      'transactionDate': instance.transactionDate.toIso8601String(),
      'isPrinted': instance.isPrinted,
      'printError': instance.printError,
      'financialYearId': instance.financialYearId,
    };
