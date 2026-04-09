import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:diamond_clean_user/core/constants/app_strings.dart';
import 'package:diamond_clean_user/features/orders/cubit/category_state.dart';
import 'package:diamond_clean_user/features/orders/data/repositories/category_repository.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _categoryRepository;

  CategoryCubit({required CategoryRepository categoryRepository})
    : _categoryRepository = categoryRepository,
      super(const CategoryLoading());

  Future<void> loadCategories() async {
    emit(const CategoryLoading());
    try {
      final categories = await _categoryRepository.fetchCategories();
      emit(CategoryLoaded(categories));
    } on CategoryRepositoryException catch (e) {
      emit(CategoryError(e.message));
    } catch (_) {
      emit(const CategoryError(AppStrings.unexpectedError));
    }
  }

  Future<void> createCategory(String name) async {
    emit(const CategoryCreating());
    try {
      final categoryId = await _categoryRepository.createCategory(name);
      emit(CategoryCreated(categoryId, name));
      await loadCategories();
    } on CategoryRepositoryException catch (e) {
      emit(CategoryError(e.message));
    } catch (_) {
      emit(const CategoryError(AppStrings.unexpectedError));
    }
  }
}
