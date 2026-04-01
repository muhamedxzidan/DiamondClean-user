import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cpc_clean_user/features/orders/cubit/new_order_cubit.dart';
import 'package:cpc_clean_user/features/orders/cubit/new_order_state.dart';
import 'package:cpc_clean_user/core/theme/app_colors.dart';

class ItemCounterRow extends StatelessWidget {
  final String itemName;

  const ItemCounterRow({super.key, required this.itemName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            itemName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          // Counter UI
          BlocSelector<NewOrderCubit, NewOrderState, int>(
            selector: (state) {
              if (state is NewOrderItemsUpdated) {
                return state.items
                    .where((item) => item.name == itemName)
                    .fold(0, (_, item) => item.quantity);
              }
              return 0;
            },
            builder: (context, currentCount) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: currentCount > 0
                        ? () => context.read<NewOrderCubit>().decrementItem(
                            itemName,
                          )
                        : null,
                    icon: const Icon(Icons.remove_circle, size: 30),
                    color: AppColors.errorLight,
                    disabledColor: AppColors.grey300,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                  Container(
                    width: 36,
                    alignment: Alignment.center,
                    child: Text(
                      '$currentCount',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        context.read<NewOrderCubit>().incrementItem(itemName),
                    icon: const Icon(Icons.add_circle, size: 30),
                    color: AppColors.success,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
