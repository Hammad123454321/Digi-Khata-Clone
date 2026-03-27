import 'package:equatable/equatable.dart';
import '../../../shared/models/inventory_transaction_model.dart';
import '../../../shared/models/stock_alert_model.dart';
import '../../../shared/models/stock_item_model.dart';

/// Stock States
abstract class StockState extends Equatable {
  const StockState();

  @override
  List<Object?> get props => [];
}

class StockInitial extends StockState {
  const StockInitial();
}

class StockLoading extends StockState {
  const StockLoading();
}

class StockItemsLoaded extends StockState {
  const StockItemsLoaded({
    required this.items,
    this.hasMore = false,
    this.alerts,
  });

  final List<StockItemModel> items;
  final bool hasMore;
  final List<StockAlertModel>? alerts;

  @override
  List<Object?> get props => [items, hasMore, alerts];
}

class StockItemCreated extends StockState {
  const StockItemCreated(this.item);

  final StockItemModel item;

  @override
  List<Object?> get props => [item];
}

class InventoryTransactionCreated extends StockState {
  const InventoryTransactionCreated(this.transaction);

  final InventoryTransactionModel transaction;

  @override
  List<Object?> get props => [transaction];
}

class InventoryTransactionsLoaded extends StockState {
  const InventoryTransactionsLoaded({
    required this.transactions,
    this.itemId,
  });

  final List<InventoryTransactionModel> transactions;
  final String? itemId;

  @override
  List<Object?> get props => [transactions, itemId];
}

class StockAlertsLoaded extends StockState {
  const StockAlertsLoaded(this.alerts);

  final List<StockAlertModel> alerts;

  @override
  List<Object?> get props => [alerts];
}

class StockAlertResolved extends StockState {
  const StockAlertResolved(this.alertId);

  final String alertId;

  @override
  List<Object?> get props => [alertId];
}

class StockError extends StockState {
  const StockError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
