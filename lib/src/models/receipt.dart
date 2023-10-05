import 'package:flutter/foundation.dart';

class Receipt {
  final Uint8List? logo;
  final String gov;
  final String council;
  final String phone;
  final String email;
  final String title;
  final String recNumber;
  final String payer;
  final String total;
  final String receTotal;
  final String status;
  final String paid;
  final String paidDate;
  final String printedBy;
  final String qr;
  final String receiptTime;
  final String collectionPointName;

  Receipt(
      this.logo,
      this.gov,
      this.council,
      this.phone,
      this.email,
      this.title,
      this.recNumber,
      this.payer,
      this.total,
      this.receTotal,
      this.status,
      this.paid,
      this.paidDate,
      this.printedBy,
      this.qr,
      this.receiptTime, this.collectionPointName
      );
}
