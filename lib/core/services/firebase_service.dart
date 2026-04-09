import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamond_clean_user/core/constants/app_strings.dart';
import 'package:diamond_clean_user/core/services/firebase_service_operations.dart';

class FirebaseServiceException implements Exception {
  final String message;

  FirebaseServiceException(this.message);

  @override
  String toString() => message;
}

/// Shared result type for order creation — used by [OrderRepository].
class OrderCreationResult {
  final int serialNumber;
  final String customerCode;

  const OrderCreationResult({
    required this.serialNumber,
    required this.customerCode,
  });
}

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> checkCustomerExists(String phoneOrCode) async {
    try {
      return await checkCustomerExistsOperation(
        firestore: _firestore,
        phoneOrCode: phoneOrCode,
      );
    } on FirebaseServiceException {
      rethrow;
    } catch (_) {
      throw FirebaseServiceException(AppStrings.errorCheckingCustomer);
    }
  }

  Future<List<Map<String, dynamic>>> searchOrdersByCustomerIdentifier(
    String phoneOrCode,
  ) async {
    try {
      return await searchOrdersByCustomerIdentifierOperation(
        firestore: _firestore,
        phoneOrCode: phoneOrCode,
      );
    } on FirebaseServiceException {
      rethrow;
    } catch (_) {
      throw FirebaseServiceException(AppStrings.failedToLoadOrdersDb);
    }
  }

  Future<bool> checkCarIsActive(String carNumber) async {
    try {
      return await checkCarIsActiveOperation(
        firestore: _firestore,
        carNumber: carNumber,
      );
    } on FirebaseServiceException {
      rethrow;
    } catch (_) {
      throw FirebaseServiceException(AppStrings.errorCheckingCar);
    }
  }
}
