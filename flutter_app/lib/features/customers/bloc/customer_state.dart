import 'package:equatable/equatable.dart';
import '../../../shared/models/customer_model.dart';

/// Customer States
abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {
  const CustomerInitial();
}

class CustomerLoading extends CustomerState {
  const CustomerLoading();
}

class CustomersLoaded extends CustomerState {
  const CustomersLoaded({
    required this.customers,
    this.hasMore = false,
  });

  final List<CustomerModel> customers;
  final bool hasMore;

  @override
  List<Object?> get props => [customers, hasMore];
}

class CustomerCreated extends CustomerState {
  const CustomerCreated(this.customer);

  final CustomerModel customer;

  @override
  List<Object?> get props => [customer];
}

class CustomerPaymentRecorded extends CustomerState {
  const CustomerPaymentRecorded();
}

class CustomerTransactionsLoaded extends CustomerState {
  const CustomerTransactionsLoaded(this.transactions);

  final List<Map<String, dynamic>> transactions;

  @override
  List<Object?> get props => [transactions];
}

class CustomerError extends CustomerState {
  const CustomerError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
