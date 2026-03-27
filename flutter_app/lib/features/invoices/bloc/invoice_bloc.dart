import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/result.dart';
import '../../../data/repositories/invoice_repository.dart';
import '../../../shared/models/invoice_model.dart';
import 'invoice_event.dart';
import 'invoice_state.dart';

/// Invoice BLoC
class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  InvoiceBloc({
    required InvoiceRepository invoiceRepository,
  })  : _invoiceRepository = invoiceRepository,
        super(const InvoiceInitial()) {
    on<CreateInvoiceEvent>(_onCreateInvoice);
    on<LoadInvoicesEvent>(_onLoadInvoices);
    on<DownloadInvoicePdfEvent>(_onDownloadPdf);
  }

  final InvoiceRepository _invoiceRepository;

  Future<void> _onCreateInvoice(
    CreateInvoiceEvent event,
    Emitter<InvoiceState> emit,
  ) async {
    try {
      emit(const InvoiceLoading());
      final result = await _invoiceRepository.createInvoice(
        customerId: event.customerId,
        invoiceType: event.invoiceType,
        date: event.date,
        items: event.items,
        taxAmount: event.taxAmount,
        discountAmount: event.discountAmount,
        remarks: event.remarks,
      );

      switch (result) {
        case Success(:final data):
          emit(InvoiceCreated(data));
        case FailureResult(:final failure):
          emit(InvoiceError(failure.message ?? 'Failed to create invoice'));
      }
    } catch (e) {
      emit(InvoiceError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onLoadInvoices(
    LoadInvoicesEvent event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(const InvoiceLoading());
    final result = await _invoiceRepository.getInvoices(
      startDate: event.startDate,
      endDate: event.endDate,
      customerId: event.customerId,
      invoiceType: event.invoiceType,
    );

    switch (result) {
      case Success(:final data):
        emit(InvoicesLoaded(invoices: data));
      case FailureResult(:final failure):
        emit(InvoiceError(failure.message ?? 'Failed to load invoices'));
    }
  }

  Future<void> _onDownloadPdf(
    DownloadInvoicePdfEvent event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(const InvoiceLoading());
    final result = await _invoiceRepository.getInvoicePdf(event.invoiceId);

    switch (result) {
      case Success(:final data):
        emit(InvoicePdfDownloaded(data));
      case FailureResult(:final failure):
        emit(InvoiceError(failure.message ?? 'Failed to download PDF'));
    }
  }
}
