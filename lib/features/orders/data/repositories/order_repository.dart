import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpc_clean_user/core/constants/app_constants.dart';
import 'package:cpc_clean_user/core/constants/app_strings.dart';
import 'package:cpc_clean_user/core/constants/firebase_constants.dart';
import 'package:cpc_clean_user/core/services/firebase_service.dart';
import 'package:cpc_clean_user/core/utils/phone_utils.dart';
import 'package:cpc_clean_user/features/orders/data/models/customer_lookup_model.dart';

class OrderRepositoryException implements Exception {
  final String message;

  const OrderRepositoryException(this.message);

  @override
  String toString() => message;
}

/// Formats an integer serial into the canonical customer code, e.g. "CPC-1".
String _buildCustomerCode(int serial) => 'CPC-$serial';

class OrderRepository {
  final FirebaseService _firebaseService;
  final FirebaseFirestore _firestore;

  OrderRepository({FirebaseService? firebaseService})
    : _firebaseService = firebaseService ?? FirebaseService(),
      _firestore = FirebaseFirestore.instance;

  // ─── Public API ──────────────────────────────────────────────────────────

  /// Looks up a customer by phone number (11 digits) or numeric customer-code.
  ///
  /// Input is always pure digits:
  ///   - 11 digits  → phone lookup via [FirebaseService.checkCustomerExists].
  ///   - other      → customer-code lookup (prepends "CPC-").
  Future<CustomerLookupModel?> lookupCustomer(String phoneOrCode) async {
    try {
      final input = normalizePhone(phoneOrCode);
      if (input.isEmpty) return null;

      Map<String, dynamic>? data;

      if (input.length == AppConstants.egyptPhoneLength) {
        // Delegate to service which handles doc-ID + field fallback queries.
        data = await _firebaseService.checkCustomerExists(input);
      } else {
        final snapshot = await _firestore
            .collection(FirebaseCollections.customers)
            .where(FirestoreFields.customerCode, isEqualTo: 'CPC-$input')
            .limit(1)
            .get();
        if (snapshot.docs.isNotEmpty) data = snapshot.docs.first.data();
      }

      if (data == null) return null;
      return CustomerLookupModel.fromFirestore(data);
    } on FirebaseServiceException catch (e) {
      throw OrderRepositoryException(e.message);
    } on FirebaseException catch (e) {
      final msg = switch (e.code) {
        'permission-denied' => AppStrings.errorPermissionDenied,
        'unavailable' ||
        'deadline-exceeded' => AppStrings.errorServerUnavailable,
        _ => AppStrings.errorFetchingCustomerData,
      };
      throw OrderRepositoryException(msg);
    } catch (_) {
      throw const OrderRepositoryException(
        AppStrings.errorFetchingCustomerData,
      );
    }
  }

  /// Creates a new order in a Firestore transaction.
  ///
  /// Atomically increments the order counter, creates/updates the customer
  /// document, and writes the order document.
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
      final normalizedPhone = normalizePhone(phone);
      return await _runCreateOrderTransaction(
        normalizedPhone: normalizedPhone,
        customerName: customerName,
        customerAddress: customerAddress,
        items: items,
        totalPieces: totalPieces,
        carNumber: carNumber,
        driverName: driverName,
      );
    } on FirebaseException catch (e) {
      final msg = switch (e.code) {
        'permission-denied' => AppStrings.errorPermissionDeniedOrder,
        'unavailable' ||
        'deadline-exceeded' => AppStrings.errorServerUnavailable,
        'not-found' => AppStrings.errorDatabaseConfig,
        'aborted' => AppStrings.errorConflictSaving,
        _ =>
          '${AppStrings.errorFailedToSaveOrderPrefix} ${e.message ?? e.code}',
      };
      throw OrderRepositoryException(msg);
    } on FirebaseServiceException catch (e) {
      throw OrderRepositoryException(e.message);
    } catch (_) {
      throw const OrderRepositoryException(AppStrings.errorSavingOrder);
    }
  }

  // ─── Private ─────────────────────────────────────────────────────────────

  Future<OrderCreationResult> _runCreateOrderTransaction({
    required String normalizedPhone,
    required String customerName,
    required String customerAddress,
    required Map<String, int> items,
    required int totalPieces,
    required String carNumber,
    required String driverName,
  }) {
    final counterRef = _firestore
        .collection(FirebaseCollections.counters)
        .doc(FirebaseDocumentIds.orderCounter);
    final customerCounterRef = _firestore
        .collection(FirebaseCollections.counters)
        .doc(FirebaseDocumentIds.customerCounter);
    final newOrderRef = _firestore.collection(FirebaseCollections.orders).doc();
    final customerRef = _firestore
        .collection(FirebaseCollections.customers)
        .doc(normalizedPhone);

    return _firestore.runTransaction<OrderCreationResult>((tx) async {
      // ── Order serial ──────────────────────────────────────────────────────
      final counterSnap = await tx.get(counterRef);
      final lastOrderId =
          (counterSnap.data()?['last_order_id'] as num?)?.toInt() ?? 0;
      final serialNumber = lastOrderId + 1;

      // ── Customer serial & code ────────────────────────────────────────────
      final customerSnap = await tx.get(customerRef);
      final existing = customerSnap.data();

      int customerSerial = (existing?[FirestoreFields.customerSerial] as num?)?.toInt() ?? 0;
      String customerCode = (existing?[FirestoreFields.customerCode] as String? ?? '').trim();

      if (customerSerial == 0) {
        final ccSnap = await tx.get(customerCounterRef);
        final lastCId =
            (ccSnap.data()?['last_customer_id'] as num?)?.toInt() ?? 0;
        customerSerial = lastCId + 1;
        tx.set(customerCounterRef, {
          'last_customer_id': customerSerial,
        }, SetOptions(merge: true));
      }

      if (customerCode.isEmpty) {
        customerCode = _buildCustomerCode(customerSerial);
      }

      // ── Write order counter ───────────────────────────────────────────────
      tx.set(counterRef, {
        'last_order_id': serialNumber,
      }, SetOptions(merge: true));

      // ── Write / update customer ───────────────────────────────────────────
      // Only write the full document if customer is new or data changed.
      // Returning customer with same name/address → update timestamp only.
      final bool isNewCustomer = existing == null;
      final bool dataChanged =
          existing != null &&
          (existing['name'] != customerName ||
              existing['address'] != customerAddress);

      if (isNewCustomer || dataChanged) {
        tx.set(customerRef, {
          'name': customerName,
          'address': customerAddress,
          'phone': normalizedPhone,
          'phoneNumber': normalizedPhone,
          FirestoreFields.customerCode: customerCode,
          FirestoreFields.customerSerial: customerSerial,
          'lastOrderDate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        // Existing customer, same data — only update the last order date.
        tx.update(customerRef, {'lastOrderDate': FieldValue.serverTimestamp()});
      }

      // ── Write order document ──────────────────────────────────────────────
      tx.set(newOrderRef, {
        'serialNumber': serialNumber,
        FirestoreFields.customerPhone: normalizedPhone,
        'customerPhoneNumber': normalizedPhone,
        FirestoreFields.customerCode: customerCode,
        FirestoreFields.customerSerial: customerSerial,
        FirestoreFields.customerName: customerName,
        'customerAddress': customerAddress,
        'items': items,
        'totalPieces': totalPieces,
        FirestoreFields.carNumber: carNumber,
        'driverName': driverName,
        'status': AppStrings.statusReceived,
        FirestoreFields.createdAt: FieldValue.serverTimestamp(),
      });

      return OrderCreationResult(
        serialNumber: serialNumber,
        customerCode: customerCode,
      );
    });
  }
}
