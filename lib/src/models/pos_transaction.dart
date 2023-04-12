import 'package:json_annotation/json_annotation.dart';
import 'package:zanmutm_pos_client/src/models/cart_item.dart';
import 'package:zanmutm_pos_client/src/models/user.dart';

part 'pos_transaction.g.dart';

@JsonSerializable(explicitToJson: true)
class PosTransaction {
  final int? id;
  final String? trxNumber;
  final int? revenueSourceId;
  final String? gfsCode;
  final int? adminHierarchyId;
  final int? taxPayerId;
  final String? taxCollectorUuid;
  final double amount;
  final int quantity;
  final String? cashPayerName;
  final String? cashPayerAddress;
  final String? receiptNumber;
  final DateTime transactionDate;
  bool isPrinted;
  final String? printError;
  final int? financialYearId;
  final int? posDeviceId;

  PosTransaction(
      this.id,
      this.trxNumber,
      this.revenueSourceId,
      this.gfsCode,
      this.adminHierarchyId,
      this.taxPayerId,
      this.taxCollectorUuid,
      this.amount,
      this.quantity,
      this.cashPayerName,
      this.receiptNumber,
      this.transactionDate,
      this.isPrinted,
      this.printError,
      this.financialYearId,
      this.posDeviceId,
      this.cashPayerAddress);

  factory PosTransaction.fromJson(Map<String, dynamic> json) => _$PosTransactionFromJson(json);

  Map<String,dynamic> toJson() => _$PosTransactionToJson(this);

  factory PosTransaction.fromCashCollection(
      String transactionId,
      String receiptNumber,
      DateTime transactionDate,
      RevenueItem cartItem,
      User user,
      Map<String, dynamic> payerDetail,
      int financialYearId,
      bool isPrinted,
      String? printError,
      int posDeviceId
      )  {
    return PosTransaction(
        null,
        transactionId,
        cartItem.revenueSource.id,
        cartItem.revenueSource.gfsCode,
        user.adminHierarchyId!,
        user.taxPayerId!,
        user.taxCollectorUuid!,
        cartItem.amount,
        cartItem.quantity,
        payerDetail['name'],
        receiptNumber,
        transactionDate,
        isPrinted,
        printError,
        financialYearId,
  posDeviceId,
        payerDetail['address']);
  }

}
