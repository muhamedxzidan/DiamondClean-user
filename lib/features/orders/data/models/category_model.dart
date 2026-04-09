import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final DateTime? createdAt;

  const CategoryModel({
    required this.id,
    required this.name,
    this.createdAt,
  });

  factory CategoryModel.fromJson(String id, Map<String, dynamic> json) {
    return CategoryModel(
      id: id,
      name: json['name'] as String? ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
