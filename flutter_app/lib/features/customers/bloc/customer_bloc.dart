import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/result.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../shared/models/customer_model.dart';
import 'customer_event.dart';
import 'customer_state.dart';

/// Customer BLoC
class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  CustomerBloc({
    required CustomerRepository customerRepository,
  })  : _customerRepository = customerRepository,
        super(const CustomerInitial()) {
    on<CreateCustomerEvent>(_onCreateCustomer);
    on<LoadCustomersEvent>(_onLoadCustomers);
    on<RecordCustomerPaymentEvent>(_onRecordPayment);
    on<LoadCustomerTransactionsEvent>(_onLoadTransactions);
  }

  final CustomerRepository _customerRepository;

  Future<void> _onCreateCustomer(
    CreateCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(const CustomerLoading());
    final result = await _customerRepository.createCustomer(
      name: event.name,
      phone: event.phone,
      email: event.email,
      address: event.address,
    );

    switch (result) {
      case Success(:final data):
        emit(CustomerCreated(data));
      case FailureResult(:final failure):
        emit(CustomerError(failure.message ?? 'Failed to create customer'));
    }
  }

  Future<void> _onLoadCustomers(
    LoadCustomersEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(const CustomerLoading());
    final result = await _customerRepository.getCustomers(
      isActive: event.isActive,
      search: event.search,
    );

    switch (result) {
      case Success(:final data):
        emit(CustomersLoaded(customers: data));
      case FailureResult(:final failure):
        emit(CustomerError(failure.message ?? 'Failed to load customers'));
    }
  }

  Future<void> _onRecordPayment(
    RecordCustomerPaymentEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(const CustomerLoading());
    final result = await _customerRepository.recordPayment(
      customerId: event.customerId,
      amount: event.amount,
      date: event.date,
      remarks: event.remarks,
    );

    switch (result) {
      case Success():
        emit(const CustomerPaymentRecorded());
      case FailureResult(:final failure):
        emit(CustomerError(failure.message ?? 'Failed to record payment'));
    }
  }

  Future<void> _onLoadTransactions(
    LoadCustomerTransactionsEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(const CustomerLoading());
    final result = await _customerRepository.getTransactions(event.customerId);

    switch (result) {
      case Success(:final data):
        emit(CustomerTransactionsLoaded(data));
      case FailureResult(:final failure):
        emit(CustomerError(failure.message ?? 'Failed to load transactions'));
    }
  }
}
