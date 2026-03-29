import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kimo_clean/core/constants/app_strings.dart';
import 'package:kimo_clean/features/auth/data/repositories/auth_repository.dart';
import 'package:kimo_clean/features/orders/cubit/new_order_state.dart';
import 'package:kimo_clean/features/orders/cubit/order_items_manager.dart';
import 'package:kimo_clean/features/orders/data/repositories/order_repository.dart';

class NewOrderCubit extends Cubit<NewOrderState> {
  final OrderRepository _orderRepository;
  final AuthRepository _authRepository;
  NewOrderCubit({
    required AuthRepository authRepository,
    required OrderRepository orderRepository,
  }) : _authRepository = authRepository,
       _orderRepository = orderRepository,
       super(NewOrderInitial());

  static const itemNames = [
    AppStrings.categoryCarpet,
    AppStrings.categoryCarpetCover,
    AppStrings.categoryDuvet,
    AppStrings.categoryBlanket,
    AppStrings.categoryCurtains,
    AppStrings.categoryOther,
  ];
  late final OrderItemsManager _itemsManager = OrderItemsManager(itemNames);

  int get totalPieces => _itemsManager.totalPieces;
  int quantityFor(String itemName) => _itemsManager.quantityFor(itemName);
  String _normalizePhone(String phone) =>
      phone.replaceAll(RegExp(r'[^0-9]'), '');
  void _emitItemsUpdated() => emit(
    NewOrderItemsUpdated(
      items: _itemsManager.itemsList,
      totalPieces: totalPieces,
    ),
  );

  Future<void> lookupCustomer(String phoneOrCode) async {
    final numericQuery = _normalizePhone(phoneOrCode);
    if (numericQuery.isEmpty) return;
    emit(NewOrderPhoneLookupLoading());

    try {
      final customerData = await _orderRepository.lookupCustomer(numericQuery);
      if (customerData != null) {
        emit(
          NewOrderPhoneLookupSuccess(
            phone: customerData.phone,
            customerName: customerData.name,
            address: customerData.address,
            customerCode: customerData.customerCode,
            customerSerial: customerData.customerSerial,
          ),
        );
      } else {
        emit(NewOrderCustomerLookupNotFound(numericQuery));
      }
    } on OrderRepositoryException catch (e) {
      emit(NewOrderValidationError(e.message));
    } catch (_) {
      emit(NewOrderValidationError(AppStrings.errorFetchingCustomerData));
    }
  }

  void clearLookupState() => _emitItemsUpdated();
  void incrementItem(String itemName) {
    _itemsManager.increment(itemName);
    _emitItemsUpdated();
  }

  void decrementItem(String itemName) {
    _itemsManager.decrement(itemName);
    _emitItemsUpdated();
  }

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
      final selectedItemsSnapshot = Map<String, int>.from(
        _itemsManager.selectedItems(),
      );
      final totalPiecesSnapshot = totalPieces;
      final carNumber = await _authRepository.getSavedCarNumber() ?? '';
      final savedAgentName = await _authRepository.getSavedAgentName();
      final driverName =
          (savedAgentName == null || savedAgentName.trim().isEmpty)
          ? AppStrings.undefined
          : savedAgentName.trim();

      final createOrderResult = await _orderRepository.createOrder(
        phone: normalizedPhone,
        customerName: name,
        customerAddress: address,
        items: selectedItemsSnapshot,
        totalPieces: totalPiecesSnapshot,
        carNumber: carNumber,
        driverName: driverName,
      );

      _itemsManager.reset();
      emit(
        NewOrderSaveSuccess(
          serialNumber: createOrderResult.serialNumber,
          customerCode: createOrderResult.customerCode,
          customerName: name,
          phone: normalizedPhone,
          address: address,
          items: selectedItemsSnapshot,
          totalPieces: totalPiecesSnapshot,
          notes: notes,
        ),
      );
    } catch (e) {
      emit(
        NewOrderSaveError(
          e is OrderRepositoryException
              ? e.message
              : AppStrings.unexpectedError,
        ),
      );
    }
  }

  void reset() {
    _itemsManager.reset();
    emit(NewOrderInitial());
  }
}
