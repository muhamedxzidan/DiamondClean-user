import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final bool hasDimensions;
  final DateTime? createdAt;

  const CategoryModel({
    required this.id,
    required this.name,
    this.hasDimensions = true,
    this.createdAt,
  });

  factory CategoryModel.fromJson(String id, Map<String, dynamic> json) {
    return CategoryModel(
      id: id,
      name: json['name'] as String? ?? '',
      hasDimensions: json['hasDimensions'] as bool? ?? true,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hasDimensions': hasDimensions,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
