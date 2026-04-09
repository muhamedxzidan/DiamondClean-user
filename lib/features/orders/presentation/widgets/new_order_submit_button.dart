import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:diamond_clean_user/features/orders/cubit/new_order_cubit.dart';
import 'package:diamond_clean_user/features/orders/cubit/new_order_state.dart';
import 'package:diamond_clean_user/core/constants/app_strings.dart';

class NewOrderSubmitButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NewOrderSubmitButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewOrderCubit, NewOrderState>(
      buildWhen: (previous, current) {
        final wasSaving = previous is NewOrderSaveLoading;
        final isSaving = current is NewOrderSaveLoading;
        return wasSaving != isSaving;
      },
      builder: (context, state) {
        final isSaving = state is NewOrderSaveLoading;
        return ElevatedButton.icon(
          onPressed: isSaving ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
          ),
          icon: isSaving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send_rounded),
          label: Text(
            isSaving
                ? AppStrings.savingInProgress
                : AppStrings.saveAndSendToWhatsapp,
            style: const TextStyle(fontSize: 18),
          ),
        );
      },
    );
  }
}
