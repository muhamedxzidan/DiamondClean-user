import 'package:equatable/equatable.dart';
import 'package:diamond_clean_user/features/orders/data/models/category_model.dart';

sealed class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

final class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

final class CategoryLoaded extends CategoryState {
  final List<CategoryModel> categories;

  const CategoryLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

final class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}

final class CategoryCreating extends CategoryState {
  const CategoryCreating();
}

final class CategoryCreated extends CategoryState {
  final String categoryId;
  final String categoryName;

  const CategoryCreated(this.categoryId, this.categoryName);

  @override
  List<Object?> get props => [categoryId, categoryName];
}
