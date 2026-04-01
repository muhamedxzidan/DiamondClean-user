import 'package:flutter/material.dart';
import 'package:cpc_clean_user/features/history/data/models/order_model.dart';
import 'package:cpc_clean_user/core/constants/app_strings.dart';
import 'package:cpc_clean_user/core/theme/app_colors.dart';

class HistoryOrderCard extends StatelessWidget {
  const HistoryOrderCard({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.customerName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  order.serialNumber,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.badge_outlined, size: 20, color: AppColors.grey600),
                const SizedBox(width: 8),
                Text(
                  '${AppStrings.customerCodeLabel}: ${order.customerCode}',
                  style: TextStyle(fontSize: 14, color: AppColors.grey700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.layers_rounded, size: 20, color: AppColors.grey600),
                const SizedBox(width: 8),
                Text(
                  '${order.totalPieces} ${AppStrings.pieces}',
                  style: TextStyle(fontSize: 16, color: AppColors.grey800),
                ),
                const Spacer(),
                Icon(
                  Icons.access_time_rounded,
                  size: 20,
                  color: AppColors.grey600,
                ),
                const SizedBox(width: 4),
                Text(
                  order.time,
                  style: TextStyle(fontSize: 14, color: AppColors.grey600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: order.status == AppStrings.statusReceived
                      ? AppColors.successBackground
                      : AppColors.infoBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: order.status == AppStrings.statusReceived
                        ? AppColors.successBorder
                        : AppColors.infoBorder,
                  ),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(
                    color: order.status == AppStrings.statusReceived
                        ? AppColors.successDark
                        : AppColors.infoText,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
