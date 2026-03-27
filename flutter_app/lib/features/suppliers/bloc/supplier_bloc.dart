import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/result.dart';
import '../../../data/repositories/supplier_repository.dart';
import '../../../shared/models/supplier_model.dart';
import 'supplier_event.dart';
import 'supplier_state.dart';

/// Supplier BLoC
class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  SupplierBloc({
    required SupplierRepository supplierRepository,
  })  : _supplierRepository = supplierRepository,
        super(const SupplierInitial()) {
    on<CreateSupplierEvent>(_onCreateSupplier);
    on<LoadSuppliersEvent>(_onLoadSuppliers);
    on<RecordSupplierPaymentEvent>(_onRecordPayment);
  }

  final SupplierRepository _supplierRepository;

  Future<void> _onCreateSupplier(
    CreateSupplierEvent event,
    Emitter<SupplierState> emit,
  ) async {
    emit(const SupplierLoading());
    final result = await _supplierRepository.createSupplier(
      name: event.name,
      phone: event.phone,
      email: event.email,
      address: event.address,
    );

    switch (result) {
      case Success(:final data):
        emit(SupplierCreated(data));
      case FailureResult(:final failure):
        emit(SupplierError(failure.message ?? 'Failed to create supplier'));
    }
  }

  Future<void> _onLoadSuppliers(
    LoadSuppliersEvent event,
    Emitter<SupplierState> emit,
  ) async {
    emit(const SupplierLoading());
    final result = await _supplierRepository.getSuppliers(
      isActive: event.isActive,
      search: event.search,
    );

    switch (result) {
      case Success(:final data):
        emit(SuppliersLoaded(suppliers: data));
      case FailureResult(:final failure):
        emit(SupplierError(failure.message ?? 'Failed to load suppliers'));
    }
  }

  Future<void> _onRecordPayment(
    RecordSupplierPaymentEvent event,
    Emitter<SupplierState> emit,
  ) async {
    emit(const SupplierLoading());
    final result = await _supplierRepository.recordPayment(
      supplierId: event.supplierId,
      amount: event.amount,
      date: event.date,
      remarks: event.remarks,
    );

    switch (result) {
      case Success():
        emit(const SupplierPaymentRecorded());
      case FailureResult(:final failure):
        emit(SupplierError(failure.message ?? 'Failed to record payment'));
    }
  }
}
