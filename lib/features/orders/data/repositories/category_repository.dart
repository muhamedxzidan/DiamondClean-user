import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diamond_clean_user/core/constants/firebase_constants.dart';
import 'package:diamond_clean_user/core/constants/app_strings.dart';
import 'package:diamond_clean_user/features/orders/data/models/category_model.dart';

class CategoryRepositoryException implements Exception {
  final String message;

  const CategoryRepositoryException(this.message);

  @override
  String toString() => message;
}

class CategoryRepository {
  final FirebaseFirestore _firestore;

  CategoryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseCollections.categories)
          .orderBy(FirestoreFields.createdAt)
          .get();

      return snapshot.docs
          .map((doc) => CategoryModel.fromJson(doc.id, doc.data()))
          .toList(growable: false);
    } on FirebaseException catch (e) {
      final msg = switch (e.code) {
        'permission-denied' => AppStrings.errorPermissionDenied,
        'unavailable' ||
        'deadline-exceeded' => AppStrings.errorServerUnavailable,
        _ => AppStrings.errorFetchingCategories,
      };
      throw CategoryRepositoryException(msg);
    } catch (_) {
      throw const CategoryRepositoryException(
        AppStrings.errorFetchingCategories,
      );
    }
  }

  Future<String> createCategory(String name) async {
    try {
      final docRef = await _firestore
          .collection(FirebaseCollections.categories)
          .add({'name': name, 'createdAt': FieldValue.serverTimestamp()});
      return docRef.id;
    } on FirebaseException catch (e) {
      final msg = switch (e.code) {
        'permission-denied' => AppStrings.errorPermissionDenied,
        'unavailable' ||
        'deadline-exceeded' => AppStrings.errorServerUnavailable,
        _ => AppStrings.errorFetchingCategories,
      };
      throw CategoryRepositoryException(msg);
    } catch (_) {
      throw const CategoryRepositoryException(
        AppStrings.errorFetchingCategories,
      );
    }
  }
}
