import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:kimo_clean/features/history/data/models/order_model.dart';
import 'package:kimo_clean/features/history/presentation/widgets/history_order_card.dart';
import 'package:kimo_clean/core/constants/app_strings.dart';
import 'package:kimo_clean/core/theme/app_colors.dart';

class DailyHistoryOrdersList extends StatelessWidget {
  final Map<String, List<OrderModel>> groupedOrders;

  const DailyHistoryOrdersList({super.key, required this.groupedOrders});

  @override
  Widget build(BuildContext context) {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final List<String> dates = groupedOrders.keys.toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final orders = groupedOrders[date]!;

          return ExpansionTile(
            initiallyExpanded: date == todayStr,
            iconColor: Theme.of(context).colorScheme.primary,
            collapsedIconColor: AppColors.grey600,
            title: Text(
              date == todayStr ? '${AppStrings.todayPrefix} $date' : date,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              '${orders.length} ${AppStrings.ordersLabel} | ${orders.fold<int>(0, (sum, order) => sum + order.totalPieces)} ${AppStrings.pieces}',
              style: TextStyle(color: AppColors.grey700, fontSize: 13),
            ),
            children: orders
                .map((order) => HistoryOrderCard(order: order))
                .toList(),
          );
        },
      ),
    );
  }
}
