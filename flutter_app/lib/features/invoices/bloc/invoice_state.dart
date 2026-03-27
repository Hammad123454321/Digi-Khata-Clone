import 'package:equatable/equatable.dart';
import '../../../shared/models/invoice_model.dart';

/// Invoice States
abstract class InvoiceState extends Equatable {
  const InvoiceState();

  @override
  List<Object?> get props => [];
}

class InvoiceInitial extends InvoiceState {
  const InvoiceInitial();
}

class InvoiceLoading extends InvoiceState {
  const InvoiceLoading();
}

class InvoicesLoaded extends InvoiceState {
  const InvoicesLoaded({
    required this.invoices,
    this.hasMore = false,
  });

  final List<InvoiceModel> invoices;
  final bool hasMore;

  @override
  List<Object?> get props => [invoices, hasMore];
}

class InvoiceCreated extends InvoiceState {
  const InvoiceCreated(this.invoice);

  final InvoiceModel invoice;

  @override
  List<Object?> get props => [invoice];
}

class InvoicePdfDownloaded extends InvoiceState {
  const InvoicePdfDownloaded(this.pdfBytes);

  final List<int> pdfBytes;

  @override
  List<Object?> get props => [pdfBytes];
}

class InvoiceError extends InvoiceState {
  const InvoiceError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
