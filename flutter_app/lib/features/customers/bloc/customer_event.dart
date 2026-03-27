import 'package:equatable/equatable.dart';

/// Customer Events
abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class CreateCustomerEvent extends CustomerEvent {
  const CreateCustomerEvent({
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

class LoadCustomersEvent extends CustomerEvent {
  const LoadCustomersEvent({
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

class RecordCustomerPaymentEvent extends CustomerEvent {
  const RecordCustomerPaymentEvent({
    required this.customerId,
    required this.amount,
    required this.date,
    this.remarks,
  });

  final String customerId;
  final String amount;
  final DateTime date;
  final String? remarks;

  @override
  List<Object?> get props => [customerId, amount, date, remarks];
}

class LoadCustomerTransactionsEvent extends CustomerEvent {
  const LoadCustomerTransactionsEvent(this.customerId);

  final String customerId;

  @override
  List<Object?> get props => [customerId];
}
