import 'package:kimo_clean/features/orders/data/models/order_item_model.dart';

class OrderItemsManager {
  final Map<String, int> _quantities;

  OrderItemsManager(List<String> itemNames)
    : _quantities = {for (final name in itemNames) name: 0};

  int get totalPieces => _quantities.values.fold(0, (a, b) => a + b);

  List<OrderItem> get itemsList => _quantities.entries
      .map((e) => OrderItem(name: e.key, quantity: e.value))
      .toList();

  int quantityFor(String itemName) => _quantities[itemName] ?? 0;

  void increment(String itemName) {
    _quantities[itemName] = (_quantities[itemName] ?? 0) + 1;
  }

  void decrement(String itemName) {
    final current = _quantities[itemName] ?? 0;
    if (current > 0) {
      _quantities[itemName] = current - 1;
    }
  }

  Map<String, int> selectedItems() {
    final selected = <String, int>{};
    _quantities.forEach((key, value) {
      if (value > 0) selected[key] = value;
    });
    return selected;
  }

  void reset() {
    for (final key in _quantities.keys) {
      _quantities[key] = 0;
    }
  }
}
