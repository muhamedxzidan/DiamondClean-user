import 'package:equatable/equatable.dart';

/// Represents a single item type with its quantity in an order.
class OrderItem extends Equatable {
  final String name;
  final int quantity;

  const OrderItem({required this.name, required this.quantity});

  @override
  List<Object?> get props => [name, quantity];

  OrderItem copyWith({int? quantity}) {
    return OrderItem(name: name, quantity: quantity ?? this.quantity);
  }
}
