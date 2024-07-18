import 'package:json_annotation/json_annotation.dart';

part 'bill.g.dart';

@JsonSerializable(explicitToJson: true)
class Bill {
  final int id;
  final String uuid;
  final DateTime? dueTime;
  final DateTime? expireDate;
  final double amount;
  final String? controlNumber;
  final String? statusName;
  final DateTime? createdAt;

  Bill(this.id, this.uuid, this.dueTime, this.expireDate, this.amount,
      this.controlNumber, this.statusName, this.createdAt);

  factory Bill.fromJson(Map<String, dynamic> json) => _$BillFromJson(json);

  Map<String, dynamic> toJson() => _$BillToJson(this);
}
