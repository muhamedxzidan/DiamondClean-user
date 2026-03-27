import 'package:equatable/equatable.dart';
import 'package:kimo_clean/features/orders/data/models/order_item_model.dart';

sealed class NewOrderState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class NewOrderInitial extends NewOrderState {}

final class NewOrderPhoneLookupLoading extends NewOrderState {}

final class NewOrderPhoneLookupSuccess extends NewOrderState {
  final String customerName;
  final String address;
  final int? customerSerial;

  NewOrderPhoneLookupSuccess({
    required this.customerName,
    required this.address,
    this.customerSerial,
  });

  @override
  List<Object?> get props => [customerName, address, customerSerial];
}

final class NewOrderItemsUpdated extends NewOrderState {
  final List<OrderItem> items;
  final int totalPieces;

  NewOrderItemsUpdated({required this.items, required this.totalPieces});

  @override
  List<Object?> get props => [items, totalPieces];
}

final class NewOrderSaveLoading extends NewOrderState {}

final class NewOrderSaveSuccess extends NewOrderState {
  final int serialNumber;
  final String customerName;
  final String phone;
  final String address;
  final Map<String, int> items;
  final int totalPieces;
  final String? notes;

  NewOrderSaveSuccess({
    required this.serialNumber,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.items,
    required this.totalPieces,
    this.notes,
  });

  @override
  List<Object?> get props => [
    serialNumber,
    customerName,
    phone,
    address,
    items,
    totalPieces,
    notes,
  ];
}

final class NewOrderSaveError extends NewOrderState {
  final String message;

  NewOrderSaveError(this.message);

  @override
  List<Object?> get props => [message];
}

final class NewOrderValidationError extends NewOrderState {
  final String message;

  NewOrderValidationError(this.message);

  @override
  List<Object?> get props => [message];
}
