import 'package:equatable/equatable.dart';
import 'package:diamond_clean_user/features/orders/data/models/order_item_model.dart';

sealed class NewOrderState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class NewOrderInitial extends NewOrderState {}

final class NewOrderPhoneLookupLoading extends NewOrderState {}

final class NewOrderPhoneLookupSuccess extends NewOrderState {
  final String phone;
  final String customerName;
  final String address;
  final String customerCode;
  final int? customerSerial;

  NewOrderPhoneLookupSuccess({
    required this.phone,
    required this.customerName,
    required this.address,
    required this.customerCode,
    this.customerSerial,
  });

  @override
  List<Object?> get props => [
    phone,
    customerName,
    address,
    customerCode,
    customerSerial,
  ];
}

final class NewOrderCustomerLookupNotFound extends NewOrderState {
  final String query;

  NewOrderCustomerLookupNotFound(this.query);

  @override
  List<Object?> get props => [query];
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
  final String customerCode;
  final String customerName;
  final String phone;
  final String address;
  final Map<String, int> items;
  final int totalPieces;
  final String? notes;

  NewOrderSaveSuccess({
    required this.serialNumber,
    required this.customerCode,
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
    customerCode,
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
