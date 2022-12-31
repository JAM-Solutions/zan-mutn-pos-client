import 'package:json_annotation/json_annotation.dart';
import 'package:zanmutm_pos_client/src/models/pos_transaction.dart';

part 'pos_charge.g.dart';

@JsonSerializable(explicitToJson: true)
class PosCharge {
  final int id;
  final String uuid;
  final int? taxCollectorId;
  final String? billReferenceNo;
  final int? financialYearId;
  final bool? isActive;
  final DateTime? completeDate;
  final double amount;
  final List<PosTransaction> transactions;

  PosCharge(
      this.id,
      this.uuid,
      this.taxCollectorId,
      this.billReferenceNo,
      this.financialYearId,
      this.isActive,
      this.completeDate,
      this.amount,
      this.transactions);

  factory PosCharge.fromJson(Map<String, dynamic> json) =>
      _$PosChargeFromJson(json);
  Map<String, dynamic> toJson() => _$PosChargeToJson(this);
}
