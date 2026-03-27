import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/result.dart';
import '../../../data/repositories/reports_repository.dart';
import 'reports_event.dart';
import 'reports_state.dart';

/// Reports BLoC
class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  ReportsBloc({
    required ReportsRepository reportsRepository,
  })  : _reportsRepository = reportsRepository,
        super(const ReportsInitial()) {
    on<LoadSalesReportEvent>(_onLoadSalesReport);
    on<LoadCashFlowReportEvent>(_onLoadCashFlowReport);
    on<LoadExpenseReportEvent>(_onLoadExpenseReport);
    on<LoadStockReportEvent>(_onLoadStockReport);
    on<LoadProfitLossReportEvent>(_onLoadProfitLossReport);
  }

  final ReportsRepository _reportsRepository;

  Future<void> _onLoadSalesReport(
    LoadSalesReportEvent event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsLoading());
    final result = await _reportsRepository.getSalesReport(
      startDate: event.startDate,
      endDate: event.endDate,
    );

    switch (result) {
      case Success(:final data):
        emit(SalesReportLoaded(data));
      case FailureResult(:final failure):
        emit(ReportsError(failure.message ?? 'Failed to load sales report'));
    }
  }

  Future<void> _onLoadCashFlowReport(
    LoadCashFlowReportEvent event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsLoading());
    final result = await _reportsRepository.getCashFlowReport(
      startDate: event.startDate,
      endDate: event.endDate,
    );

    switch (result) {
      case Success(:final data):
        emit(CashFlowReportLoaded(data));
      case FailureResult(:final failure):
        emit(
            ReportsError(failure.message ?? 'Failed to load cash flow report'));
    }
  }

  Future<void> _onLoadExpenseReport(
    LoadExpenseReportEvent event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsLoading());
    final result = await _reportsRepository.getExpenseReport(
      startDate: event.startDate,
      endDate: event.endDate,
    );

    switch (result) {
      case Success(:final data):
        emit(ExpenseReportLoaded(data));
      case FailureResult(:final failure):
        emit(ReportsError(failure.message ?? 'Failed to load expense report'));
    }
  }

  Future<void> _onLoadStockReport(
    LoadStockReportEvent event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsLoading());
    final result = await _reportsRepository.getStockReport();

    switch (result) {
      case Success(:final data):
        emit(StockReportLoaded(data));
      case FailureResult(:final failure):
        emit(ReportsError(failure.message ?? 'Failed to load stock report'));
    }
  }

  Future<void> _onLoadProfitLossReport(
    LoadProfitLossReportEvent event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsLoading());
    final result = await _reportsRepository.getProfitLossReport(
      startDate: event.startDate,
      endDate: event.endDate,
    );

    switch (result) {
      case Success(:final data):
        emit(ProfitLossReportLoaded(data));
      case FailureResult(:final failure):
        emit(ReportsError(
            failure.message ?? 'Failed to load profit & loss report'));
    }
  }
}
