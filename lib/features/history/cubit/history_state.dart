import 'package:equatable/equatable.dart';
import 'package:diamond_clean_user/features/history/data/models/order_model.dart';

sealed class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

final class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

final class HistoryLoaded extends HistoryState {
  final Map<String, List<OrderModel>> groupedOrders;
  final int totalOrders;
  final int totalPieces;

  const HistoryLoaded({
    required this.groupedOrders,
    required this.totalOrders,
    required this.totalPieces,
  });

  @override
  List<Object?> get props => [groupedOrders, totalOrders, totalPieces];
}

final class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
