import 'package:equatable/equatable.dart';

/// Supplier Events
abstract class SupplierEvent extends Equatable {
  const SupplierEvent();

  @override
  List<Object?> get props => [];
}

class CreateSupplierEvent extends SupplierEvent {
  const CreateSupplierEvent({
    required this.name,
    this.phone,
    this.email,
    this.address,
  });

  final String name;
  final String? phone;
  final String? email;
  final String? address;

  @override
  List<Object?> get props => [name, phone, email, address];
}

class LoadSuppliersEvent extends SupplierEvent {
  const LoadSuppliersEvent({
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

class RecordSupplierPaymentEvent extends SupplierEvent {
  const RecordSupplierPaymentEvent({
    required this.supplierId,
    required this.amount,
    required this.date,
    this.remarks,
  });

  final String supplierId;
  final String amount;
  final DateTime date;
  final String? remarks;

  @override
  List<Object?> get props => [supplierId, amount, date, remarks];
}
