import 'package:equatable/equatable.dart';

/// Stock Events
abstract class StockEvent extends Equatable {
  const StockEvent();

  @override
  List<Object?> get props => [];
}

class CreateStockItemEvent extends StockEvent {
  const CreateStockItemEvent({
    required this.name,
    required this.purchasePrice,
    required this.salePrice,
    required this.unit,
    required this.openingStock,
    this.description,
  });

  final String name;
  final String purchasePrice;
  final String salePrice;
  final String unit;
  final String openingStock;
  final String? description;

  @override
  List<Object?> get props => [
        name,
        purchasePrice,
        salePrice,
        unit,
        openingStock,
        description,
      ];
}

class LoadStockItemsEvent extends StockEvent {
  const LoadStockItemsEvent({
    this.isActive,
    this.search,
    this.refresh = false,
  });

  final bool? isActive;
  final String? search;
  final bool refresh;

  @override
  List<Object?> get props => [isActive, search, refresh];
}

class CreateInventoryTransactionEvent extends StockEvent {
  const CreateInventoryTransactionEvent({
    required this.itemId,
    required this.transactionType,
    required this.quantity,
    required this.unitPrice,
    required this.date,
    this.remarks,
  });

  final String itemId;
  final String transactionType;
  final String quantity;
  final String unitPrice;
  final DateTime date;
  final String? remarks;

  @override
  List<Object?> get props =>
      [itemId, transactionType, quantity, unitPrice, date, remarks];
}

class LoadInventoryTransactionsEvent extends StockEvent {
  const LoadInventoryTransactionsEvent({
    this.itemId,
    this.limit = 100,
    this.offset = 0,
  });

  final String? itemId;
  final int limit;
  final int offset;

  @override
  List<Object?> get props => [itemId, limit, offset];
}

class LoadStockAlertsEvent extends StockEvent {
  const LoadStockAlertsEvent();
}

class ResolveStockAlertEvent extends StockEvent {
  const ResolveStockAlertEvent(this.alertId);

  final String alertId;

  @override
  List<Object?> get props => [alertId];
}
