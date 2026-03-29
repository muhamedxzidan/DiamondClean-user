import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Represents a submitted order in the daily history.
class OrderModel {
  final String customerName;
  final String customerCode;
  final String serialNumber;
  final int totalPieces;
  final String time;
  final String date;
  final String status;

  const OrderModel({
    required this.customerName,
    required this.customerCode,
    required this.serialNumber,
    required this.totalPieces,
    required this.time,
    required this.date,
    required this.status,
  });

  factory OrderModel.fromFirestore(Map<String, dynamic>? data) {
    final rawData = data ?? <String, dynamic>{};
    final serialNumber = rawData['serialNumber'];
    final serialText = serialNumber is int
        ? '#$serialNumber'
        : (serialNumber as String?) ?? '#';

    final createdAt = rawData['createdAt'] as Timestamp?;
    final formattedTime = createdAt == null
        ? ''
        : DateFormat('hh:mm a').format(createdAt.toDate());
    final formattedDate = createdAt == null
        ? ''
        : DateFormat('yyyy-MM-dd').format(createdAt.toDate());

    return OrderModel(
      customerName: rawData['customerName'] as String? ?? 'Unknown',
      customerCode: rawData['customerCode'] as String? ?? 'Undefined',
      serialNumber: serialText,
      totalPieces: (rawData['totalPieces'] as num?)?.toInt() ?? 0,
      time: formattedTime,
      date: formattedDate,
      status: rawData['status'] as String? ?? 'Unknown',
    );
  }
}
