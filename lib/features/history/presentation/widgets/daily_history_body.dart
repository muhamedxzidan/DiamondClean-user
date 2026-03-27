import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kimo_clean/core/constants/app_strings.dart';
import 'package:kimo_clean/features/history/cubit/history_cubit.dart';
import 'package:kimo_clean/features/history/cubit/history_state.dart';
import 'package:kimo_clean/features/history/presentation/widgets/daily_history_orders_list.dart';
import 'package:kimo_clean/features/history/presentation/widgets/daily_history_summary_card.dart';

class DailyHistoryBody extends StatelessWidget {
  const DailyHistoryBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryCubit, HistoryState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state is HistoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is HistoryError) {
          return Center(child: Text(state.message));
        }

        if (state is! HistoryLoaded) {
          return const SizedBox.shrink();
        }

        if (state.groupedOrders.isEmpty) {
          return const Center(
            child: Text(
              AppStrings.noOrdersYet,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          );
        }

        return Column(
          children: [
            DailyHistorySummaryCard(
              totalOrders: state.totalOrders,
              totalPieces: state.totalPieces,
            ),
            Expanded(
              child: DailyHistoryOrdersList(groupedOrders: state.groupedOrders),
            ),
          ],
        );
      },
    );
  }
}
