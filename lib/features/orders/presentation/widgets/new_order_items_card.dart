import 'package:flutter/material.dart';
import 'package:cpc_clean_user/core/constants/app_strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cpc_clean_user/features/orders/cubit/new_order_cubit.dart';
import 'package:cpc_clean_user/features/orders/cubit/new_order_state.dart';
import 'package:cpc_clean_user/features/orders/presentation/widgets/item_counter_row.dart';
import 'package:cpc_clean_user/core/theme/app_colors.dart';

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
            ...NewOrderCubit.itemNames.map((itemName) {
              return ItemCounterRow(itemName: itemName);
            }),
            const Divider(height: 24),
            BlocSelector<NewOrderCubit, NewOrderState, int>(
              selector: (state) => context.read<NewOrderCubit>().totalPieces,
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
