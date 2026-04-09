import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:diamond_clean_user/core/constants/app_strings.dart';
import 'package:diamond_clean_user/core/theme/app_colors.dart';
import 'package:diamond_clean_user/features/orders/cubit/category_cubit.dart';
import 'package:diamond_clean_user/features/orders/cubit/category_state.dart';
import 'package:diamond_clean_user/features/orders/cubit/new_order_cubit.dart';
import 'package:diamond_clean_user/features/orders/cubit/new_order_state.dart';
import 'package:diamond_clean_user/features/orders/presentation/widgets/item_counter_row.dart';

class NewOrderItemsCard extends StatelessWidget {
  const NewOrderItemsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.surfaceWhite,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.itemsDetailsTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Divider(height: 24),
            BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, categoryState) {
                return switch (categoryState) {
                  CategoryLoading() => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  CategoryError(:final message) => Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          Text(
                            message,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () =>
                                context.read<CategoryCubit>().loadCategories(),
                            child: const Text(AppStrings.retry),
                          ),
                        ],
                      ),
                    ),
                  ),
                  CategoryLoaded(:final categories) => Column(
                    children: categories
                        .map((category) => ItemCounterRow(itemName: category.name))
                        .toList(),
                  ),
                  // TODO: Handle this case.
                  CategoryCreating() => throw UnimplementedError(),
                  // TODO: Handle this case.
                  CategoryCreated() => throw UnimplementedError(),
                };
              },
            ),
            const Divider(height: 24),
            BlocSelector<NewOrderCubit, NewOrderState, int>(
              selector: (state) =>
                  state is NewOrderItemsUpdated ? state.totalPieces : 0,
              builder: (context, totalPieces) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${AppStrings.totalPiecesPrefix} $totalPieces',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
