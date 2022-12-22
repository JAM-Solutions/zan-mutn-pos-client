import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:zanmutm_pos_client/src/models/pos_configuration.dart';
import 'package:zanmutm_pos_client/src/models/revenue_source.dart';
import 'package:zanmutm_pos_client/src/models/user.dart';

part 'pos_transaction.g.dart';

@JsonSerializable(explicitToJson: true)
class PosTransaction {
  final int? id;
  final String transactionNumber;
  final int posDeviceId;
  final int revenueSourceId;
  final String gfsCode;
  final int adminHierarchyId;
  final int taxPayerId;
  final double amount;
  final int quantity;
  final String? cashPayerName;
  final String? cashPayerAddress;
  final String receiptNumber;
  final DateTime transactionDate;
  bool isPrinted;
  final String? printError;
  final int financialYearId;

  PosTransaction(
      this.id,
      this.transactionNumber,
      this.posDeviceId,
      this.revenueSourceId,
      this.gfsCode,
      this.adminHierarchyId,
      this.taxPayerId,
      this.amount,
      this.quantity,
      this.cashPayerName,
      this.receiptNumber,
      this.transactionDate,
      this.isPrinted,
      this.printError,
      this.financialYearId,
      this.cashPayerAddress);

  factory PosTransaction.fromJson(Map<String, dynamic> json) => _$PosTransactionFromJson(json);

  Map<String,dynamic> toJson() => _$PosTransactionToJson(this);

  factory PosTransaction.fromCashCollection(
      PosConfiguration posConfig,
      RevenueSource revenueSource,
      User user,
      Map<String, dynamic> cashBill,
      int financialYearId
      )  {
    return PosTransaction(null,
        DateTime.now().toIso8601String(),
        posConfig.posDeviceId,
        revenueSource.id,
        revenueSource.gfsCode,
        user.adminHierarchyId!,
        user.taxPayerId!,
        cashBill['amount'],
        cashBill['quantity'],
        cashBill['name'],
        DateTime.now().toIso8601String(),
        DateTime.now(),
        false,
        null,
        financialYearId,
        cashBill['address']);
  }

}
