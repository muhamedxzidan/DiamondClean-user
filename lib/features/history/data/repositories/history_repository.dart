import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kimo_clean/core/constants/firebase_constants.dart';
import 'package:kimo_clean/features/history/data/models/order_model.dart';
import 'package:kimo_clean/core/constants/app_strings.dart';

class HistoryRepositoryException implements Exception {
  final String message;

  const HistoryRepositoryException(this.message);

  @override
  String toString() => message;
}

class HistoryRepository {
  final FirebaseFirestore _firestore;

  HistoryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<OrderModel>> watchTodayOrdersByCar(String carNumber) {
    try {
      return _firestore
          .collection(FirebaseCollections.orders)
          .where('carNumber', isEqualTo: carNumber)
          .snapshots()
          .map((snapshot) {
            final docs = [...snapshot.docs]
              ..sort(
                (a, b) => _createdAtMillis(b).compareTo(_createdAtMillis(a)),
              );

            return docs
                .map((doc) => OrderModel.fromFirestore(doc.data()))
                .toList(growable: false);
          });
    } on FirebaseException catch (e) {
      return Stream<List<OrderModel>>.error(
        HistoryRepositoryException(
          e.message ?? AppStrings.failedToLoadOrdersDb,
        ),
      );
    } catch (_) {
      return Stream<List<OrderModel>>.error(
        const HistoryRepositoryException(
          AppStrings.unexpectedErrorLoadingOrders,
        ),
      );
    }
  }

  int _createdAtMillis(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final timestamp = doc.data()['createdAt'] as Timestamp?;
    return timestamp?.millisecondsSinceEpoch ?? 0;
  }
}
