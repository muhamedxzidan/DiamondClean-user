import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kimo_clean/core/constants/app_strings.dart';
import 'package:kimo_clean/features/auth/data/repositories/auth_repository.dart';
import 'package:kimo_clean/features/orders/data/models/order_item_model.dart';
import 'package:kimo_clean/features/orders/data/repositories/order_repository.dart';
import 'package:kimo_clean/features/orders/cubit/new_order_state.dart';

class NewOrderCubit extends Cubit<NewOrderState> {
  final OrderRepository _orderRepository;
  final AuthRepository _authRepository;

  NewOrderCubit({
    required AuthRepository authRepository,
    required OrderRepository orderRepository,
  }) : _authRepository = authRepository,
       _orderRepository = orderRepository,
       super(NewOrderInitial());

  // --- Item names (static list, could come from repo later) ---
  static const List<String> itemNames = [
    AppStrings.categoryCarpet,
    AppStrings.categoryCarpetCover,
    AppStrings.categoryDuvet,
    AppStrings.categoryBlanket,
    AppStrings.categoryCurtains,
    AppStrings.categoryOther,
  ];

  // Internal mutable state for item quantities
  final Map<String, int> _quantities = {for (final name in itemNames) name: 0};

  int get totalPieces => _quantities.values.fold(0, (a, b) => a + b);

  List<OrderItem> get _itemsList => _quantities.entries
      .map((e) => OrderItem(name: e.key, quantity: e.value))
      .toList();

  int quantityFor(String itemName) => _quantities[itemName] ?? 0;

  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Called when phone number reaches 11 digits.
  Future<void> lookupCustomer(String phone) async {
    final normalizedPhone = _normalizePhone(phone);
    if (normalizedPhone.length != 11) {
      emit(NewOrderItemsUpdated(items: _itemsList, totalPieces: totalPieces));
      return;
    }

    emit(NewOrderPhoneLookupLoading());

    try {
      final customerData = await _orderRepository.lookupCustomerByPhone(
        normalizedPhone,
      );

      if (customerData != null) {
        emit(
          NewOrderPhoneLookupSuccess(
            customerName: customerData.name,
            address: customerData.address,
            customerSerial: customerData.customerSerial,
          ),
        );
        emit(NewOrderItemsUpdated(items: _itemsList, totalPieces: totalPieces));
      } else {
        emit(NewOrderItemsUpdated(items: _itemsList, totalPieces: totalPieces));
      }
    } on OrderRepositoryException {
      emit(NewOrderItemsUpdated(items: _itemsList, totalPieces: totalPieces));
    } catch (e) {
      emit(NewOrderItemsUpdated(items: _itemsList, totalPieces: totalPieces));
    }
  }

  /// Increment quantity for a given item.
  void incrementItem(String itemName) {
    _quantities[itemName] = (_quantities[itemName] ?? 0) + 1;
    emit(NewOrderItemsUpdated(items: _itemsList, totalPieces: totalPieces));
  }

  /// Decrement quantity for a given item (minimum 0).
  void decrementItem(String itemName) {
    final current = _quantities[itemName] ?? 0;
    if (current > 0) {
      _quantities[itemName] = current - 1;
      emit(NewOrderItemsUpdated(items: _itemsList, totalPieces: totalPieces));
    }
  }

  /// Validates and triggers save action.
  Future<void> saveOrder({
    required String phone,
    required String name,
    required String address,
    String? notes,
  }) async {
    final normalizedPhone = _normalizePhone(phone);
    if (normalizedPhone.length != 11) {
      emit(NewOrderValidationError(AppStrings.phoneLengthValidation));
      return;
    }

    if (totalPieces == 0) {
      emit(NewOrderValidationError(AppStrings.atLeastOneCategoryValidation));
      return;
    }

    emit(NewOrderSaveLoading());

    try {
      // Get the items that actually have quantities > 0
      final Map<String, int> selectedItems = {};
      _quantities.forEach((key, value) {
        if (value > 0) {
          selectedItems[key] = value;
        }
      });

      final totalPiecesSnapshot = totalPieces;
      final selectedItemsSnapshot = Map<String, int>.from(selectedItems);

      // Get car number from authenticated session
      final carNumber = await _authRepository.getSavedCarNumber() ?? '';
      final savedAgentName = await _authRepository.getSavedAgentName();
      final driverName =
          (savedAgentName == null || savedAgentName.trim().isEmpty)
          ? AppStrings.undefined
          : savedAgentName.trim();

      final serialNumber = await _orderRepository.createOrder(
        phone: normalizedPhone,
        customerName: name,
        customerAddress: address,
        items: selectedItemsSnapshot,
        totalPieces: totalPiecesSnapshot,
        carNumber: carNumber,
        driverName: driverName,
      );

      // Reset internal quantities
      for (final key in _quantities.keys.toList()) {
        _quantities[key] = 0;
      }

      emit(
        NewOrderSaveSuccess(
          serialNumber: serialNumber,
          customerName: name,
          phone: normalizedPhone,
          address: address,
          items: selectedItemsSnapshot,
          totalPieces: totalPiecesSnapshot,
          notes: notes,
        ),
      );
    } catch (e) {
      if (e is OrderRepositoryException) {
        emit(NewOrderSaveError(e.message));
      } else {
        emit(NewOrderSaveError(AppStrings.unexpectedError));
      }
    }
  }

  /// Resets items back to initial after save.
  void reset() {
    for (final key in _quantities.keys.toList()) {
      _quantities[key] = 0;
    }
    emit(NewOrderInitial());
  }
}
