import 'package:flutter/material.dart';
import 'package:diamond_clean_user/core/constants/app_strings.dart';
import 'package:diamond_clean_user/core/theme/app_colors.dart';

class DailyHistorySummaryCard extends StatelessWidget {
  final int totalOrders;
  final int totalPieces;

  const DailyHistorySummaryCard({
    super.key,
    required this.totalOrders,
    required this.totalPieces,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppStrings.totalOrdersTodayPrefix} $totalOrders',
            style: const TextStyle(
              color: AppColors.surfaceWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${AppStrings.totalPiecesReceivedPrefix} $totalPieces',
            style: const TextStyle(color: AppColors.textWhite70, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
