import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kimo_clean/core/constants/app_strings.dart';
import 'package:kimo_clean/core/services/firebase_service_operations.dart';

class FirebaseServiceException implements Exception {
  final String message;

  FirebaseServiceException(this.message);

  @override
  String toString() => message;
}

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
    } catch (_) {
      throw FirebaseServiceException(AppStrings.errorCheckingCar);
    }
  }

  Future<OrderCreationResult> createNewOrder({
    required String phone,
    required String name,
    required String address,
    required Map<String, int> items,
    required int totalPieces,
    required String carNumber,
    required String driverName,
  }) async {
    try {
      final result = await createNewOrderOperation(
        firestore: _firestore,
        phone: phone,
        name: name,
        address: address,
        items: items,
        totalPieces: totalPieces,
        carNumber: carNumber,
        driverName: driverName,
      );
      return OrderCreationResult(
        serialNumber: result.$1,
        customerCode: result.$2,
      );
    } on FirebaseException catch (e) {
      final userMessage = switch (e.code) {
        'permission-denied' => AppStrings.errorPermissionDeniedOrder,
        'unavailable' ||
        'deadline-exceeded' => AppStrings.errorServerUnavailable,
        'not-found' => AppStrings.errorDatabaseConfig,
        'aborted' => AppStrings.errorConflictSaving,
        _ =>
          '${AppStrings.errorFailedToSaveOrderPrefix} ${e.message ?? e.code}',
      };
      throw FirebaseServiceException(userMessage);
    } catch (e) {
      throw FirebaseServiceException(
        '${AppStrings.errorUnexpectedSaving} ($e)',
      );
    }
  }
}
