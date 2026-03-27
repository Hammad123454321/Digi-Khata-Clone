import 'package:equatable/equatable.dart';

/// Invoice Events
abstract class InvoiceEvent extends Equatable {
  const InvoiceEvent();

  @override
  List<Object?> get props => [];
}

class CreateInvoiceEvent extends InvoiceEvent {
  const CreateInvoiceEvent({
    this.customerId,
    required this.invoiceType,
    required this.date,
    required this.items,
    required this.taxAmount,
    required this.discountAmount,
    this.remarks,
  });

  final String? customerId;
  final String invoiceType;
  final DateTime date;
  final List<Map<String, dynamic>> items;
  final String taxAmount;
  final String discountAmount;
  final String? remarks;

  @override
  List<Object?> get props => [
        customerId,
        invoiceType,
        date,
        items,
        taxAmount,
        discountAmount,
        remarks,
      ];
}

class LoadInvoicesEvent extends InvoiceEvent {
  const LoadInvoicesEvent({
    this.startDate,
    this.endDate,
    this.customerId,
    this.invoiceType,
    this.refresh = false,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final String? customerId;
  final String? invoiceType;
  final bool refresh;

  @override
  List<Object?> get props =>
      [startDate, endDate, customerId, invoiceType, refresh];
}

class DownloadInvoicePdfEvent extends InvoiceEvent {
  const DownloadInvoicePdfEvent(this.invoiceId);

  final String invoiceId;

  @override
  List<Object?> get props => [invoiceId];
}
