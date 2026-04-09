import 'package:flutter/material.dart';
import 'package:diamond_clean_user/core/constants/app_strings.dart';
import 'package:diamond_clean_user/core/routes/routes.dart';
import 'package:diamond_clean_user/core/theme/app_colors.dart';

class NewOrderButton extends StatelessWidget {
  const NewOrderButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed(Routes.newOrder);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: AppColors.surfaceWhite,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(48), // Large button
            elevation: 8,
          ),
          child: const Icon(
            Icons.add_business_rounded, // Better suited for new order
            size: 64,
            semanticLabel:
                AppStrings.drawerNewOrder, // Refactored hardcoded string
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.drawerNewOrder,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
