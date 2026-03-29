import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kimo_clean/core/constants/firebase_constants.dart';
import 'package:kimo_clean/core/utils/phone_utils.dart';

Future<Map<String, dynamic>?> checkCustomerExistsOperation({
  required FirebaseFirestore firestore,
  required String phoneOrCode,
}) async {
  final rawValue = phoneOrCode.trim();
  final phone = normalizePhone(rawValue);

  // ── Phone input (11 digits) — lookup by doc ID only.
  // Doc ID is the phone number, so one read is enough.
  if (phone.length == 11) {
    final doc = await firestore
        .collection(FirebaseCollections.customers)
        .doc(phone)
        .get();
    return doc.exists ? doc.data() : null;
  }

  // ── Non-phone input — lookup by customerCode field (e.g. "KC-00001").
  final byCode = await firestore
      .collection(FirebaseCollections.customers)
      .where('customerCode', isEqualTo: rawValue.toUpperCase())
      .limit(1)
      .get();
  if (byCode.docs.isNotEmpty) return byCode.docs.first.data();

  return null;
}

Future<List<Map<String, dynamic>>> searchOrdersByCustomerIdentifierOperation({
  required FirebaseFirestore firestore,
  required String phoneOrCode,
}) async {
  final rawValue = phoneOrCode.trim();
  final phone = normalizePhone(rawValue);
  final matchedDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
  final seenDocIds = <String>{};

  if (phone.isNotEmpty) {
    final byPhone = await firestore
        .collection(FirebaseCollections.orders)
        .where('customerPhone', isEqualTo: phone)
        .get();
    for (final doc in byPhone.docs) {
      if (seenDocIds.add(doc.id)) matchedDocs.add(doc);
    }
  }

  final byCode = await firestore
      .collection(FirebaseCollections.orders)
      .where('customerCode', isEqualTo: rawValue.toUpperCase())
      .get();
  for (final doc in byCode.docs) {
    if (seenDocIds.add(doc.id)) matchedDocs.add(doc);
  }

  matchedDocs.sort((a, b) {
    final aMs = (a.data()['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
    final bMs = (b.data()['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
    return bMs.compareTo(aMs);
  });

  return matchedDocs.map((doc) => doc.data()).toList(growable: false);
}

Future<bool> checkCarIsActiveOperation({
  required FirebaseFirestore firestore,
  required String carNumber,
}) async {
  final doc = await firestore
      .collection(FirebaseCollections.cars)
      .doc(carNumber)
      .get();
  if (!doc.exists || doc.data() == null) return false;
  return doc.data()!['isActive'] as bool? ?? false;
}
