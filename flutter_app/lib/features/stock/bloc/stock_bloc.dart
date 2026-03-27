import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/result.dart';
import '../../../data/repositories/stock_repository.dart';
import '../../../shared/models/inventory_transaction_model.dart';
import '../../../shared/models/stock_alert_model.dart';
import '../../../shared/models/stock_item_model.dart';
import 'stock_event.dart';
import 'stock_state.dart';

/// Stock BLoC
class StockBloc extends Bloc<StockEvent, StockState> {
  StockBloc({
    required StockRepository stockRepository,
  })  : _stockRepository = stockRepository,
        super(const StockInitial()) {
    on<CreateStockItemEvent>(_onCreateItem);
    on<LoadStockItemsEvent>(_onLoadItems);
    on<CreateInventoryTransactionEvent>(_onCreateTransaction);
    on<LoadInventoryTransactionsEvent>(_onLoadTransactions);
    on<LoadStockAlertsEvent>(_onLoadAlerts);
    on<ResolveStockAlertEvent>(_onResolveAlert);
  }

  final StockRepository _stockRepository;

  Future<void> _onCreateItem(
    CreateStockItemEvent event,
    Emitter<StockState> emit,
  ) async {
    emit(const StockLoading());
    final result = await _stockRepository.createItem(
      name: event.name,
      purchasePrice: event.purchasePrice,
      salePrice: event.salePrice,
      unit: event.unit,
      openingStock: event.openingStock,
      description: event.description,
    );

    switch (result) {
      case Success(:final data):
        emit(StockItemCreated(data));
      case FailureResult(:final failure):
        emit(StockError(failure.message ?? 'Failed to create item'));
    }
  }

  Future<void> _onLoadItems(
    LoadStockItemsEvent event,
    Emitter<StockState> emit,
  ) async {
    // Don't emit loading if we already have items (preserve current state)
    if (state is! StockItemsLoaded) {
      emit(const StockLoading());
    }
    final result = await _stockRepository.getItems(
      isActive: event.isActive,
      search: event.search,
    );

    switch (result) {
      case Success(:final data):
        // Preserve alerts if they exist
        List<StockAlertModel>? currentAlerts;
        if (state is StockItemsLoaded) {
          currentAlerts = (state as StockItemsLoaded).alerts;
        } else if (state is StockAlertsLoaded) {
          currentAlerts = (state as StockAlertsLoaded).alerts;
        }
        emit(StockItemsLoaded(items: data, alerts: currentAlerts));
      case FailureResult(:final failure):
        emit(StockError(failure.message ?? 'Failed to load items'));
    }
  }

  Future<void> _onCreateTransaction(
    CreateInventoryTransactionEvent event,
    Emitter<StockState> emit,
  ) async {
    emit(const StockLoading());
    final result = await _stockRepository.createTransaction(
      itemId: event.itemId,
      transactionType: event.transactionType,
      quantity: event.quantity,
      unitPrice: event.unitPrice,
      date: event.date,
      remarks: event.remarks,
    );

    switch (result) {
      case Success(:final data):
        emit(InventoryTransactionCreated(data));
      case FailureResult(:final failure):
        emit(StockError(failure.message ?? 'Failed to create transaction'));
    }
  }

  Future<void> _onLoadTransactions(
    LoadInventoryTransactionsEvent event,
    Emitter<StockState> emit,
  ) async {
    emit(const StockLoading());
    final result = await _stockRepository.getTransactions(
      itemId: event.itemId,
      limit: event.limit,
      offset: event.offset,
    );

    switch (result) {
      case Success(:final data):
        emit(
          InventoryTransactionsLoaded(
            transactions: data,
            itemId: event.itemId,
          ),
        );
      case FailureResult(:final failure):
        emit(StockError(failure.message ?? 'Failed to load transactions'));
    }
  }

  Future<void> _onLoadAlerts(
    LoadStockAlertsEvent event,
    Emitter<StockState> emit,
  ) async {
    // Don't emit loading if we already have items (preserve current state)
    if (state is! StockItemsLoaded) {
      emit(const StockLoading());
    }
    final result = await _stockRepository.getAlerts();

    switch (result) {
      case Success(:final data):
        // Preserve items if they exist (even if empty)
        List<StockItemModel> currentItems = [];
        if (state is StockItemsLoaded) {
          currentItems = (state as StockItemsLoaded).items;
        }
        // Always emit StockItemsLoaded to maintain consistent state
        // This ensures the UI can always check for StockItemsLoaded
        emit(StockItemsLoaded(items: currentItems, alerts: data));
      case FailureResult(:final failure):
        // Don't overwrite items state if alerts fail - just preserve items
        if (state is StockItemsLoaded) {
          // Keep the items state, just without alerts
          final currentItems = (state as StockItemsLoaded).items;
          emit(StockItemsLoaded(items: currentItems, alerts: null));
        } else {
          // Only emit error if we don't have items loaded
          emit(StockError(failure.message ?? 'Failed to load alerts'));
        }
    }
  }

  Future<void> _onResolveAlert(
    ResolveStockAlertEvent event,
    Emitter<StockState> emit,
  ) async {
    emit(const StockLoading());
    final result = await _stockRepository.resolveAlert(event.alertId);

    switch (result) {
      case Success():
        emit(StockAlertResolved(event.alertId));
      case FailureResult(:final failure):
        emit(StockError(failure.message ?? 'Failed to resolve alert'));
    }
  }
}
