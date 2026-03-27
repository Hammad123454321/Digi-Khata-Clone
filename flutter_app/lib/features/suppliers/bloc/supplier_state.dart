import 'package:equatable/equatable.dart';
import '../../../shared/models/supplier_model.dart';

/// Supplier States
abstract class SupplierState extends Equatable {
  const SupplierState();

  @override
  List<Object?> get props => [];
}

class SupplierInitial extends SupplierState {
  const SupplierInitial();
}

class SupplierLoading extends SupplierState {
  const SupplierLoading();
}

class SuppliersLoaded extends SupplierState {
  const SuppliersLoaded({
    required this.suppliers,
    this.hasMore = false,
  });

  final List<SupplierModel> suppliers;
  final bool hasMore;

  @override
  List<Object?> get props => [suppliers, hasMore];
}

class SupplierCreated extends SupplierState {
  const SupplierCreated(this.supplier);

  final SupplierModel supplier;

  @override
  List<Object?> get props => [supplier];
}

class SupplierPaymentRecorded extends SupplierState {
  const SupplierPaymentRecorded();
}

class SupplierError extends SupplierState {
  const SupplierError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
