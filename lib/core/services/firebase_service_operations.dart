import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kimo_clean/core/constants/app_strings.dart';
import 'package:kimo_clean/core/constants/firebase_constants.dart';

String _normalizePhoneValue(String phone) {
  return phone.replaceAll(RegExp(r'[^0-9]'), '');
}

String _buildCustomerCodeValue(int customerSerial) {
  return 'KC-${customerSerial.toString().padLeft(5, '0')}';
}

Future<Map<String, dynamic>?> checkCustomerExistsOperation({
  required FirebaseFirestore firestore,
  required String phoneOrCode,
}) async {
  final rawValue = phoneOrCode.trim();
  final normalizedPhone = _normalizePhoneValue(rawValue);

  if (normalizedPhone.length == 11) {
    final docSnapshot = await firestore
        .collection(FirebaseCollections.customers)
        .doc(normalizedPhone)
        .get();
    if (docSnapshot.exists) {
      return docSnapshot.data();
    }
  }

  final byCodeSnapshot = await firestore
      .collection(FirebaseCollections.customers)
      .where('customerCode', isEqualTo: rawValue.toUpperCase())
      .limit(1)
      .get();

  if (byCodeSnapshot.docs.isNotEmpty) {
    return byCodeSnapshot.docs.first.data();
  }

  if (normalizedPhone.length == 11) {
    final byPhoneFieldSnapshot = await firestore
        .collection(FirebaseCollections.customers)
        .where('phoneNumber', isEqualTo: normalizedPhone)
        .limit(1)
        .get();

    if (byPhoneFieldSnapshot.docs.isNotEmpty) {
      return byPhoneFieldSnapshot.docs.first.data();
    }
  }

  return null;
}

Future<List<Map<String, dynamic>>> searchOrdersByCustomerIdentifierOperation({
  required FirebaseFirestore firestore,
  required String phoneOrCode,
}) async {
  final rawValue = phoneOrCode.trim();
  final normalizedPhone = _normalizePhoneValue(rawValue);
  final matchedDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
  final seenDocIds = <String>{};

  if (normalizedPhone.isNotEmpty) {
    final byPhoneSnapshot = await firestore
        .collection(FirebaseCollections.orders)
        .where('customerPhone', isEqualTo: normalizedPhone)
        .get();

    for (final doc in byPhoneSnapshot.docs) {
      if (seenDocIds.add(doc.id)) {
        matchedDocs.add(doc);
      }
    }
  }

  final byCodeSnapshot = await firestore
      .collection(FirebaseCollections.orders)
      .where('customerCode', isEqualTo: rawValue.toUpperCase())
      .get();

  for (final doc in byCodeSnapshot.docs) {
    if (seenDocIds.add(doc.id)) {
      matchedDocs.add(doc);
    }
  }

  matchedDocs.sort((a, b) {
    final aTimestamp = a.data()['createdAt'] as Timestamp?;
    final bTimestamp = b.data()['createdAt'] as Timestamp?;
    return (bTimestamp?.millisecondsSinceEpoch ?? 0).compareTo(
      aTimestamp?.millisecondsSinceEpoch ?? 0,
    );
  });

  return matchedDocs.map((doc) => doc.data()).toList(growable: false);
}

Future<bool> checkCarIsActiveOperation({
  required FirebaseFirestore firestore,
  required String carNumber,
}) async {
  final docSnapshot = await firestore
      .collection(FirebaseCollections.cars)
      .doc(carNumber)
      .get();
  if (docSnapshot.exists && docSnapshot.data() != null) {
    return docSnapshot.data()!['isActive'] as bool? ?? false;
  }
  return false;
}

Future<(int serialNumber, String customerCode)> createNewOrderOperation({
  required FirebaseFirestore firestore,
  required String phone,
  required String name,
  required String address,
  required Map<String, int> items,
  required int totalPieces,
  required String carNumber,
  required String driverName,
}) async {
  final normalizedPhone = _normalizePhoneValue(phone);
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

  return firestore.runTransaction<(int, String)>((transaction) async {
    final counterSnapshot = await transaction.get(counterRef);
    int lastOrderId = 0;
    if (counterSnapshot.exists && counterSnapshot.data() != null) {
      final data = counterSnapshot.data()!;
      lastOrderId = (data['last_order_id'] as int?) ?? 0;
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
      customerCode = _buildCustomerCodeValue(customerSerial);
    }

    transaction.set(counterRef, {
      'last_order_id': serialNumber,
    }, SetOptions(merge: true));

    transaction.set(customerRef, {
      'name': name,
      'address': address,
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
      'customerName': name,
      'customerAddress': address,
      'items': items,
      'totalPieces': totalPieces,
      'carNumber': carNumber,
      'driverName': driverName,
      'status': AppStrings.statusReceived,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return (serialNumber, customerCode);
  });
}
