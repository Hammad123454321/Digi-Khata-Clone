import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../../core/di/injection.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../data/repositories/invoice_repository.dart';
import '../../../shared/models/invoice_model.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/invoice_pdf_builder.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../bloc/invoice_bloc.dart';
import 'create_invoice_screen.dart';

/// Invoice detail screen with PDF preview.
class InvoiceDetailScreen extends StatelessWidget {
  const InvoiceDetailScreen({
    super.key,
    required this.invoice,
    this.pdfBytes,
  });

  final InvoiceModel invoice;
  final List<int>? pdfBytes;

  InvoiceRepository get _invoiceRepository => getIt<InvoiceRepository>();

  Future<InvoiceModel> _loadDisplayInvoice() async {
    if (invoice.items != null && invoice.items!.isNotEmpty) {
      return invoice;
    }
    final result = await _invoiceRepository.getInvoiceById(invoice.id);
    if (result.isSuccess && result.dataOrNull != null) {
      return result.dataOrNull!;
    }
    return invoice;
  }

  Future<Uint8List> _generatePdf(
    AppLocalizations loc,
    InvoiceModel displayInvoice,
  ) async {
    final localStorage = getIt<LocalStorageService>();
    return InvoicePdfBuilder.build(
      loc: loc,
      invoice: displayInvoice,
      businessName: localStorage.getBusinessName(),
      businessPhone: localStorage.getUserPhone(),
      generatedBy: localStorage.getUserName(),
    );
  }

  Future<void> _editInvoice(
      BuildContext context, InvoiceModel displayInvoice) async {
    InvoiceBloc? invoiceBloc;
    try {
      invoiceBloc = context.read<InvoiceBloc>();
    } catch (_) {
      invoiceBloc = null;
    }

    final createdOrUpdated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => invoiceBloc != null
            ? BlocProvider.value(
                value: invoiceBloc,
                child: CreateInvoiceScreen(
                  existingInvoice: displayInvoice,
                  initialCustomerId: displayInvoice.customerId,
                ),
              )
            : BlocProvider(
                create: (_) => InvoiceBloc(
                  invoiceRepository: getIt<InvoiceRepository>(),
                ),
                child: CreateInvoiceScreen(
                  existingInvoice: displayInvoice,
                  initialCustomerId: displayInvoice.customerId,
                ),
              ),
      ),
    );

    if (createdOrUpdated == true && context.mounted) {
      Navigator.of(context).pop('updated');
    }
  }

  Future<void> _deleteInvoice(
      BuildContext context, InvoiceModel displayInvoice) async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: loc.delete,
      message: loc.deleteCustomerConfirm.replaceAll(
          '{name}', '${loc.invoice} ${displayInvoice.invoiceNumber}'),
      confirmText: loc.delete,
      cancelText: loc.cancel,
      isDestructive: true,
    );
    if (confirmed != true || !context.mounted) return;

    final result = await _invoiceRepository.deleteInvoice(displayInvoice.id);
    if (!context.mounted) return;
    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.success),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.of(context).pop('deleted');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.failureOrNull?.message ?? loc.failedToLoadData),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return FutureBuilder<InvoiceModel>(
      future: _loadDisplayInvoice(),
      builder: (context, snapshot) {
        final displayInvoice = snapshot.data ?? invoice;

        return Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              '${loc.invoice} ${displayInvoice.invoiceNumber}',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () => Navigator.of(context).pop('share'),
                tooltip: loc.share,
              ),
              PopupMenuButton<_InvoiceMenuAction>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (action) async {
                  if (action == _InvoiceMenuAction.edit) {
                    await _editInvoice(context, displayInvoice);
                    return;
                  }
                  if (action == _InvoiceMenuAction.delete) {
                    await _deleteInvoice(context, displayInvoice);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<_InvoiceMenuAction>(
                    value: _InvoiceMenuAction.edit,
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(loc.edit),
                      ],
                    ),
                  ),
                  PopupMenuItem<_InvoiceMenuAction>(
                    value: _InvoiceMenuAction.delete,
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          loc.delete,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: snapshot.connectionState == ConnectionState.waiting
              ? const LoadingOverlay(isLoading: true, child: SizedBox())
              : _InvoiceBody(
                  invoice: displayInvoice,
                  pdfBytes: pdfBytes,
                  buildPdf: () => _generatePdf(loc, displayInvoice),
                ),
        );
      },
    );
  }
}

class _InvoiceBody extends StatelessWidget {
  const _InvoiceBody({
    required this.invoice,
    required this.pdfBytes,
    required this.buildPdf,
  });

  final InvoiceModel invoice;
  final List<int>? pdfBytes;
  final Future<Uint8List> Function() buildPdf;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final formatter = CurrencyUtils.formatCurrency;

    return Column(
      children: [
        Expanded(
          child: pdfBytes != null
              ? PdfPreview(
                  build: (PdfPageFormat format) async {
                    return Uint8List.fromList(pdfBytes!);
                  },
                  allowPrinting: true,
                  allowSharing: true,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  canDebug: false,
                )
              : FutureBuilder<Uint8List>(
                  future: buildPdf(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingOverlay(
                          isLoading: true, child: SizedBox());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child:
                            Text('${loc.errorLoadingPdf}: ${snapshot.error}'),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }
                    return PdfPreview(
                      build: (PdfPageFormat format) async => snapshot.data!,
                      allowPrinting: true,
                      allowSharing: true,
                      canChangeOrientation: false,
                      canChangePageFormat: false,
                      canDebug: false,
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.14),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(loc.totalAmount, style: theme.textTheme.titleMedium),
                  Text(
                    formatter(double.tryParse(invoice.totalAmount) ?? 0),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              if (invoice.invoiceType == 'credit') ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(loc.paid, style: theme.textTheme.bodyMedium),
                    Text(
                      formatter(double.tryParse(invoice.paidAmount) ?? 0),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.balance,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formatter(
                        (double.tryParse(invoice.totalAmount) ?? 0) -
                            (double.tryParse(invoice.paidAmount) ?? 0),
                      ),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.errorColor,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

enum _InvoiceMenuAction {
  edit,
  delete,
}
