import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kimo_clean/core/constants/app_strings.dart';
import 'package:kimo_clean/core/constants/firebase_constants.dart';
import 'package:kimo_clean/core/services/firebase_service.dart';
import 'package:kimo_clean/features/orders/data/models/customer_lookup_model.dart';

class OrderRepositoryException implements Exception {
  final String message;

  const OrderRepositoryException(this.message);

  @override
  String toString() => message;
}

String _normalizePhone(String phone) {
  return phone.replaceAll(RegExp(r'[^0-9]'), '');
}

String _buildCustomerCode(int customerSerial) {
  return 'KC-$customerSerial';
}

CustomerLookupModel _mapLookupModel(Map<String, dynamic> customerData) {
  return CustomerLookupModel.fromFirestore(customerData);
}

Future<OrderCreationResult> _runCreateOrderTransaction({
  required FirebaseFirestore firestore,
  required String normalizedPhone,
  required String customerName,
  required String customerAddress,
  required Map<String, int> items,
  required int totalPieces,
  required String carNumber,
  required String driverName,
}) async {
  final counterRef = firestore
      .collection(FirebaseCollections.counters)
      .doc(FirebaseDocumentIds.orderCounter);
  final customerCounterRef = firestore
      .collection(FirebaseCollections.counters)
      .doc(FirebaseDocumentIds.customerCounter);
  final newOrderRef = firestore.collection(FirebaseCollections.orders).doc();
  final customerRef = firestore
      .collection(FirebaseCollections.customers)
      .doc(normalizedPhone);

  return firestore.runTransaction<OrderCreationResult>((transaction) async {
    final counterSnapshot = await transaction.get(counterRef);
    int lastOrderId = 0;
    if (counterSnapshot.exists && counterSnapshot.data() != null) {
      final data = counterSnapshot.data()!;
      lastOrderId = (data['last_order_id'] as num?)?.toInt() ?? 0;
    }
    final serialNumber = lastOrderId + 1;

    final customerSnapshot = await transaction.get(customerRef);
    final existingCustomerData = customerSnapshot.data();

    int customerSerial = 0;
    String customerCode = '';

    if (customerSnapshot.exists && existingCustomerData != null) {
      customerSerial =
          (existingCustomerData['customerSerial'] as num?)?.toInt() ?? 0;
      customerCode = (existingCustomerData['customerCode'] as String? ?? '')
          .trim();
    }

    if (customerSerial == 0) {
      final customerCounterSnapshot = await transaction.get(customerCounterRef);
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

    if (customerCode.isEmpty) {
      customerCode = _buildCustomerCode(customerSerial);
    }

    transaction.set(counterRef, {
      'last_order_id': serialNumber,
    }, SetOptions(merge: true));

    transaction.set(customerRef, {
      'name': customerName,
      'address': customerAddress,
      'phone': normalizedPhone,
      'phoneNumber': normalizedPhone,
      'customerCode': customerCode,
      'customerSerial': customerSerial,
      'lastOrderDate': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    transaction.set(newOrderRef, {
      'serialNumber': serialNumber,
      'customerPhone': normalizedPhone,
      'customerPhoneNumber': normalizedPhone,
      'customerCode': customerCode,
      'customerSerial': customerSerial,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'items': items,
      'totalPieces': totalPieces,
      'carNumber': carNumber,
      'driverName': driverName,
      'status': AppStrings.statusReceived,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return OrderCreationResult(
      serialNumber: serialNumber,
      customerCode: customerCode,
    );
  });
}

class OrderRepository {
  final FirebaseService _firebaseService;
  final FirebaseFirestore _firestore;

  OrderRepository({FirebaseService? firebaseService})
    : _firebaseService = firebaseService ?? FirebaseService(),
      _firestore = FirebaseFirestore.instance;

  Future<CustomerLookupModel?> lookupCustomer(String phoneOrCode) async {
    try {
      final numericInput = _normalizePhone(phoneOrCode);
      if (numericInput.isEmpty) {
        return null;
      }

      Map<String, dynamic>? customerData;

      if (numericInput.length == 11) {
        final byPhoneSnapshot = await _firestore
            .collection(FirebaseCollections.customers)
            .where('phone', isEqualTo: numericInput)
            .limit(1)
            .get();

        if (byPhoneSnapshot.docs.isNotEmpty) {
          customerData = byPhoneSnapshot.docs.first.data();
        }

        customerData ??= await _firebaseService.checkCustomerExists(
          numericInput,
        );
      } else {
        final normalizedCustomerCode = 'KC-$numericInput';
        final byCodeSnapshot = await _firestore
            .collection(FirebaseCollections.customers)
            .where('customerCode', isEqualTo: normalizedCustomerCode)
            .limit(1)
            .get();

        if (byCodeSnapshot.docs.isNotEmpty) {
          customerData = byCodeSnapshot.docs.first.data();
        }
      }

      if (customerData == null) {
        return null;
      }

      return _mapLookupModel(customerData);
    } on FirebaseServiceException catch (e) {
      throw OrderRepositoryException(e.message);
    } on FirebaseException catch (e) {
      final userMessage = switch (e.code) {
        'permission-denied' => AppStrings.errorPermissionDenied,
        'unavailable' ||
        'deadline-exceeded' => AppStrings.errorServerUnavailable,
        _ => AppStrings.errorFetchingCustomerData,
      };
      throw OrderRepositoryException(userMessage);
    } catch (_) {
      throw const OrderRepositoryException(
        AppStrings.errorFetchingCustomerData,
      );
    }
  }

  Future<OrderCreationResult> createOrder({
    required String phone,
    required String customerName,
    required String customerAddress,
    required Map<String, int> items,
    required int totalPieces,
    required String carNumber,
    required String driverName,
  }) async {
    try {
      final normalizedPhone = _normalizePhone(phone);
      return await _runCreateOrderTransaction(
        firestore: _firestore,
        normalizedPhone: normalizedPhone,
        customerName: customerName,
        customerAddress: customerAddress,
        items: items,
        totalPieces: totalPieces,
        carNumber: carNumber,
        driverName: driverName,
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
      throw OrderRepositoryException(userMessage);
    } on FirebaseServiceException catch (e) {
      throw OrderRepositoryException(e.message);
    } catch (_) {
      throw const OrderRepositoryException(AppStrings.errorSavingOrder);
    }
  }
}
