import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:diamond_clean_user/features/auth/data/repositories/auth_repository.dart';
import 'package:diamond_clean_user/features/history/cubit/history_state.dart';
import 'package:diamond_clean_user/features/history/data/models/order_model.dart';
import 'package:diamond_clean_user/features/history/data/repositories/history_repository.dart';
import 'package:diamond_clean_user/core/constants/app_strings.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final HistoryRepository _historyRepository;
  final AuthRepository _authRepository;
  StreamSubscription<List<OrderModel>>? _ordersSubscription;

  HistoryCubit({
    required HistoryRepository historyRepository,
    required AuthRepository authRepository,
  }) : _historyRepository = historyRepository,
       _authRepository = authRepository,
       super(const HistoryLoading());

  Future<void> loadTodayOrders() async {
    emit(const HistoryLoading());

    final carNumber = await _authRepository.getSavedCarNumber();
    if (carNumber == null || carNumber.isEmpty) {
      emit(const HistoryError(AppStrings.carNumberNotDefined));
      return;
    }

    await _ordersSubscription?.cancel();
    _ordersSubscription = _historyRepository
        .watchTodayOrdersByCar(carNumber)
        .listen(
          (orders) {
            final totalOrders = orders.length;
            final totalPieces = orders.fold<int>(
              0,
              (sum, order) => sum + order.totalPieces,
            );

            // Group by date
            final Map<String, List<OrderModel>> rawGroups = {};
            for (var order in orders) {
              final dateKey = order.date.isEmpty
                  ? AppStrings.dateNotDefined
                  : order.date;
              rawGroups.putIfAbsent(dateKey, () => []).add(order);
            }

            // Sort keys chronologically descending (newest first)
            final sortedKeys = rawGroups.keys.toList()
              ..sort((a, b) {
                final dateA = DateTime.tryParse(a);
                final dateB = DateTime.tryParse(b);
                if (dateA == null || dateB == null) return 0;
                return dateB.compareTo(dateA);
              });

            final Map<String, List<OrderModel>> sortedGroups = {};
            for (var key in sortedKeys) {
              sortedGroups[key] = rawGroups[key]!;
            }

            emit(
              HistoryLoaded(
                groupedOrders: sortedGroups,
                totalOrders: totalOrders,
                totalPieces: totalPieces,
              ),
            );
          },
          onError: (error) {
            final message = error is HistoryRepositoryException
                ? error.message
                : AppStrings.cannotLoadOrdersNowTryAgain;
            emit(HistoryError(message));
          },
        );
  }

  @override
  Future<void> close() async {
    await _ordersSubscription?.cancel();
    return super.close();
  }
}
