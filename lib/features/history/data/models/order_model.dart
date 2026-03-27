/// Represents a submitted order in the daily history.
class OrderModel {
  final String customerName;
  final String serialNumber;
  final int totalPieces;
  final String time;
  final String date;
  final String status;

  const OrderModel({
    required this.customerName,
    required this.serialNumber,
    required this.totalPieces,
    required this.time,
    required this.date,
    required this.status,
  });
}
