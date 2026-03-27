import 'package:kimo_clean/core/services/firebase_service.dart';
import 'package:kimo_clean/features/orders/data/models/customer_lookup_model.dart';
import 'package:kimo_clean/core/constants/app_strings.dart';

class OrderRepositoryException implements Exception {
  final String message;

  const OrderRepositoryException(this.message);

  @override
  String toString() => message;
}

class OrderRepository {
  final FirebaseService _firebaseService;

  OrderRepository({FirebaseService? firebaseService})
    : _firebaseService = firebaseService ?? FirebaseService();

  Future<CustomerLookupModel?> lookupCustomerByPhone(String phone) async {
    try {
      final customerData = await _firebaseService.checkCustomerExists(phone);
      if (customerData == null) {
        return null;
      }

      return CustomerLookupModel(
        name: customerData['name'] as String? ?? AppStrings.unknown,
        address: customerData['address'] as String? ?? AppStrings.unknown,
        customerSerial: (customerData['customerSerial'] as num?)?.toInt(),
      );
    } on FirebaseServiceException catch (e) {
      throw OrderRepositoryException(e.message);
    } catch (_) {
      throw const OrderRepositoryException(
        AppStrings.errorFetchingCustomerData,
      );
    }
  }

  Future<int> createOrder({
    required String phone,
    required String customerName,
    required String customerAddress,
    required Map<String, int> items,
    required int totalPieces,
    required String carNumber,
    required String driverName,
  }) async {
    try {
      return await _firebaseService.createNewOrder(
        phone: phone,
        name: customerName,
        address: customerAddress,
        items: items,
        totalPieces: totalPieces,
        carNumber: carNumber,
        driverName: driverName,
      );
    } on FirebaseServiceException catch (e) {
      throw OrderRepositoryException(e.message);
    } catch (_) {
      throw const OrderRepositoryException(AppStrings.errorSavingOrder);
    }
  }
}
