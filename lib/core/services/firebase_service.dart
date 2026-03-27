import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kimo_clean/core/constants/app_strings.dart';

/// Custom exception to provide generic application-facing errors.
class FirebaseServiceException implements Exception {
  final String message;
  FirebaseServiceException(this.message);

  @override
  String toString() => message;
}

/// Service responsible for handling Firebase Firestore interactions.
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// 1. Queries the `customers` collection where the Document ID is the phone number.
  /// Returns a Map with customer data (name, address) if found, or null if not.
  Future<Map<String, dynamic>?> checkCustomerExists(String phone) async {
    try {
      final normalizedPhone = _normalizePhone(phone);
      final docSnapshot = await _firestore
          .collection('customers')
          .doc(normalizedPhone)
          .get();

      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
      return null;
    } catch (e, stackTrace) {
      log(
        'Error checking customer existence: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw FirebaseServiceException(AppStrings.errorCheckingCustomer);
    }
  }

  /// 2. Queries the `cars` collection where the Document ID is the car number.
  /// Returns the boolean field `isActive`. (This will be used to log the driver out if deactivated).
  Future<bool> checkCarIsActive(String carNumber) async {
    try {
      final docSnapshot = await _firestore
          .collection('cars')
          .doc(carNumber)
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        return data['isActive'] as bool? ?? false;
      }
      return false; // Car not found or data is missing
    } catch (e, stackTrace) {
      log('Error checking car status: $e', error: e, stackTrace: stackTrace);
      throw FirebaseServiceException(AppStrings.errorCheckingCar);
    }
  }

  /// 3. Creates a new order using a Firestore Transaction to ensure the sequential
  /// order ID is safe from race conditions if multiple drivers save at the exact same time.
  Future<int> createNewOrder({
    required String phone,
    required String name,
    required String address,
    required Map<String, int> items,
    required int totalPieces,
    required String carNumber,
    required String driverName,
  }) async {
    try {
      final normalizedPhone = _normalizePhone(phone);
      final counterRef = _firestore.collection('counters').doc('order_counter');
      final customerCounterRef = _firestore
          .collection('counters')
          .doc('customer_counter');
      // Create a new document reference for the order
      final newOrderRef = _firestore.collection('orders').doc();
      final customerRef = _firestore
          .collection('customers')
          .doc(normalizedPhone);

      // Execute exactly what was requested through a fully isolated transaction
      final generatedSerialNumber = await _firestore.runTransaction<int>((
        transaction,
      ) async {
        // a. Read the counters collection, document order_counter.
        final counterSnapshot = await transaction.get(counterRef);

        int lastOrderId = 0;
        if (counterSnapshot.exists && counterSnapshot.data() != null) {
          final data = counterSnapshot.data()!;
          lastOrderId = data['last_order_id'] as int? ?? 0;
        }

        // b. Get the new serialNumber by incrementing last_order_id by 1
        final serialNumber = lastOrderId + 1;

        int customerSerial;
        final customerSnapshot = await transaction.get(customerRef);
        final existingCustomerData = customerSnapshot.data();

        if (customerSnapshot.exists && existingCustomerData != null) {
          customerSerial =
              (existingCustomerData['customerSerial'] as num?)?.toInt() ?? 0;
        } else {
          customerSerial = 0;
        }

        if (customerSerial == 0) {
          final customerCounterSnapshot = await transaction.get(
            customerCounterRef,
          );
          int lastCustomerId = 0;
          if (customerCounterSnapshot.exists &&
              customerCounterSnapshot.data() != null) {
            final customerCounterData = customerCounterSnapshot.data()!;
            lastCustomerId =
                (customerCounterData['last_customer_id'] as num?)?.toInt() ?? 0;
          }

          customerSerial = lastCustomerId + 1;
          transaction.set(customerCounterRef, {
            'last_customer_id': customerSerial,
          }, SetOptions(merge: true));
        }

        // c. Update the order_counter document with the new last_order_id.
        transaction.set(counterRef, {
          'last_order_id': serialNumber,
        }, SetOptions(merge: true));

        // d. Set/Merge customer data in the customers collection (Doc ID: phone).
        final customerData = {
          'name': name,
          'address': address,
          'phone': normalizedPhone,
          'customerSerial': customerSerial,
          'lastOrderDate': FieldValue.serverTimestamp(),
        };
        transaction.set(customerRef, customerData, SetOptions(merge: true));

        // e. Add a new document to the orders collection containing the specified fields.
        final orderData = {
          'serialNumber': serialNumber,
          'customerPhone': normalizedPhone,
          'customerSerial': customerSerial,
          'customerName': name,
          'customerAddress': address,
          'items': items,
          'totalPieces': totalPieces,
          'carNumber': carNumber,
          'driverName': driverName,
          'status': AppStrings.statusReceived,
          'createdAt': FieldValue.serverTimestamp(),
        };
        transaction.set(newOrderRef, orderData);

        // Return the sequentially generated serialNumber to the caller
        return serialNumber;
      });

      return generatedSerialNumber;
    } on FirebaseException catch (e, stackTrace) {
      log(
        'Firebase error creating order: [${e.code}] ${e.message}',
        error: e,
        stackTrace: stackTrace,
      );

      final String userMessage = switch (e.code) {
        'permission-denied' => AppStrings.errorPermissionDeniedOrder,
        'unavailable' ||
        'deadline-exceeded' => AppStrings.errorServerUnavailable,
        'not-found' => AppStrings.errorDatabaseConfig,
        'aborted' => AppStrings.errorConflictSaving,
        _ =>
          '${AppStrings.errorFailedToSaveOrderPrefix} ${e.message ?? e.code}',
      };
      throw FirebaseServiceException(userMessage);
    } catch (e, stackTrace) {
      log(
        'Unexpected error creating order: $e',
        error: e,
        stackTrace: stackTrace,
      );
      throw FirebaseServiceException(
        '${AppStrings.errorUnexpectedSaving} ($e)',
      );
    }
  }
}
