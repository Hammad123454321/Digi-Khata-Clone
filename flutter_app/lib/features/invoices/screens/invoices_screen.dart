import 'dart:typed_data';
import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../core/utils/currency_utils.dart';
import '../../../core/di/injection.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/routes/app_router.dart';
import '../../../data/repositories/invoice_repository.dart';
import '../../../data/repositories/reports_repository.dart';
import '../../../shared/models/invoice_model.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/modern_components.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/utils/invoice_pdf_builder.dart';
import '../../../core/localization/app_localizations.dart';
import '../../reports/bloc/reports_bloc.dart';
import '../../reports/screens/sales_report_screen.dart';
import '../bloc/invoice_bloc.dart';
import '../bloc/invoice_event.dart';
import '../bloc/invoice_state.dart';
import 'invoice_detail_screen.dart';
import 'create_invoice_screen.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  DateTimeRange? _dateRange;
  String? _selectedType; // 'cash', 'credit', or null for all
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<InvoiceModel> _cachedInvoices = [];
  bool _isSharingPdf = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );
    _loadInvoices();
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  DateTimeRange _currentRange() {
    final now = DateTime.now();
    return _dateRange ??
        DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
  }

  void _loadInvoices({bool refresh = false}) {
    final range = _currentRange();
    context.read<InvoiceBloc>().add(
          LoadInvoicesEvent(
            startDate: range.start,
            endDate: range.end,
            invoiceType: _selectedType,
            refresh: refresh,
          ),
        );
  }

  void _applyFilters() {
    setState(() {});
  }

  Future<void> _selectDateRange() async {
    final range = _currentRange();
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: range,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        _dateRange = picked;
      });
      _loadInvoices(refresh: true);
    }
  }

  Future<void> _openSalesReport() async {
    final range = _currentRange();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ReportsBloc(
            reportsRepository: getIt<ReportsRepository>(),
          ),
          child: SalesReportScreen(
            startDate: range.start,
            endDate: range.end,
          ),
        ),
      ),
    );
  }

  void _setTypeFilter(String? type) {
    setState(() {
      _selectedType = type;
    });
    _loadInvoices(refresh: true);
  }

  List<InvoiceModel> _filterInvoices(List<InvoiceModel> invoices) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = invoices.where((invoice) {
      if (_selectedType != null && invoice.invoiceType != _selectedType) {
        return false;
      }
      if (query.isEmpty) return true;
      final invoiceNumber = invoice.invoiceNumber.toLowerCase();
      final amount = invoice.totalAmount.toLowerCase();
      final type = invoice.invoiceType.toLowerCase();
      return invoiceNumber.contains(query) ||
          amount.contains(query) ||
          type.contains(query);
    }).toList();

    filtered.sort((a, b) {
      final dateCompare = b.date.compareTo(a.date);
      if (dateCompare != 0) return dateCompare;
      final createdAtA = a.createdAt;
      final createdAtB = b.createdAt;
      if (createdAtA != null && createdAtB != null) {
        final createdCompare = createdAtB.compareTo(createdAtA);
        if (createdCompare != 0) return createdCompare;
      }
      return b.invoiceNumber.compareTo(a.invoiceNumber);
    });
    return filtered;
  }

  Future<void> _openCreateInvoice(String invoiceType) async {
    final invoiceBloc = context.read<InvoiceBloc>();
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: invoiceBloc,
          child: CreateInvoiceScreen(
            defaultInvoiceType: invoiceType,
          ),
        ),
      ),
    );

    if (result == true && mounted) {
      _loadInvoices(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.invoices,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(AppRouter.settings),
              child: Text(
                loc.viewSettingsHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
      ),
      body: BlocConsumer<InvoiceBloc, InvoiceState>(
        listener: (context, state) {
          if (state is InvoiceError && _cachedInvoices.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading =
              (state is InvoiceLoading && _cachedInvoices.isEmpty) ||
                  _isSharingPdf;
          if (state is InvoicesLoaded) {
            _cachedInvoices = state.invoices;
          }

          if (state is InvoiceError && _cachedInvoices.isEmpty) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => _loadInvoices(refresh: true),
            );
          }

          return LoadingOverlay(
            isLoading: isLoading,
            child: _buildInvoicesContent(theme),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _openCreateInvoice('cash'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text('${loc.cash} ${loc.invoice}'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _openCreateInvoice('credit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text('${loc.credit} ${loc.invoice}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoicesContent(ThemeData theme) {
    final loc = AppLocalizations.of(context)!;
    final dateFormatter = DateFormat.yMMMd(loc.locale.languageCode);
    final timeFormatter = DateFormat.jm(loc.locale.languageCode);
    final range = _currentRange();

    final filteredInvoices = _filterInvoices(_cachedInvoices);
    final totalSales = filteredInvoices.fold<double>(
      0,
      (sum, invoice) => sum + (double.tryParse(invoice.totalAmount) ?? 0),
    );
    final cashSales = filteredInvoices.fold<double>(
      0,
      (sum, invoice) => invoice.invoiceType == 'cash'
          ? sum + (double.tryParse(invoice.totalAmount) ?? 0)
          : sum,
    );
    final creditSales = filteredInvoices.fold<double>(
      0,
      (sum, invoice) => invoice.invoiceType == 'credit'
          ? sum + (double.tryParse(invoice.totalAmount) ?? 0)
          : sum,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CurrencyUtils.formatCurrency(totalSales),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.totalSales,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _InvoiceMiniStat(
                        label: loc.cashLabel,
                        amount: cashSales,
                        color: AppTheme.successColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InvoiceMiniStat(
                        label: loc.creditLabel,
                        amount: creditSales,
                        color: AppTheme.errorColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                QuickActionButton(
                  icon: Icons.assessment_outlined,
                  label: loc.report,
                  onTap: _openSalesReport,
                ),
                const SizedBox(width: 12),
                QuickActionButton(
                  icon: Icons.calendar_today,
                  label: loc.setDate,
                  onTap: _selectDateRange,
                ),
                const SizedBox(width: 12),
                QuickActionButton(
                  icon: Icons.receipt_long,
                  label: loc.createInvoice,
                  onTap: () => _openCreateInvoice('cash'),
                ),
              ],
            ),
          ),
        ),
        if (_dateRange != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.filter_alt,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  '${dateFormatter.format(range.start)} - ${dateFormatter.format(range.end)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            decoration: InputDecoration(
              hintText: loc.search,
              prefixIcon: const Icon(Icons.search),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              _TypeChip(
                label: loc.all,
                isSelected: _selectedType == null,
                onTap: () => _setTypeFilter(null),
              ),
              const SizedBox(width: 8),
              _TypeChip(
                label: loc.cash,
                isSelected: _selectedType == 'cash',
                onTap: () => _setTypeFilter('cash'),
              ),
              const SizedBox(width: 8),
              _TypeChip(
                label: loc.credit,
                isSelected: _selectedType == 'credit',
                onTap: () => _setTypeFilter('credit'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  loc.entries,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  loc.cashLabel,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.successColor,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  loc.creditLabel,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.errorColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _cachedInvoices.isEmpty
              ? Center(
                  child: EmptyState(
                    icon: Icons.receipt_long,
                    title: loc.noInvoices,
                    message: loc.createFirstInvoice,
                  ),
                )
              : filteredInvoices.isEmpty
                  ? Center(
                      child: Text(
                        loc.noTransactionsFound,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: filteredInvoices.length,
                      itemBuilder: (context, index) {
                        final invoice = filteredInvoices[index];
                        final isCash = invoice.invoiceType == 'cash';
                        final amount = CurrencyUtils.formatCurrency(
                          double.tryParse(invoice.totalAmount) ?? 0,
                        );
                        final dateText =
                            '${dateFormatter.format(invoice.date)} • ${timeFormatter.format(invoice.date)}';

                        return AppCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.zero,
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    InvoiceDetailScreen(invoice: invoice),
                              ),
                            );
                            if (result == 'share') {
                              _shareInvoice(invoice);
                              return;
                            }
                            if (result == 'updated' || result == 'deleted') {
                              _loadInvoices(refresh: true);
                            }
                          },
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              invoice.invoiceNumber,
                                              style: theme.textTheme.titleSmall
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.share_outlined,
                                              size: 18,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints:
                                                const BoxConstraints.tightFor(
                                              width: 32,
                                              height: 32,
                                            ),
                                            onPressed: () =>
                                                _shareInvoice(invoice),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dateText,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        isCash
                                            ? '${loc.cash} ${loc.invoice}'
                                            : loc.creditInvoice,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: isCash
                                              ? AppTheme.successColor
                                              : AppTheme.errorColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              _InvoiceAmountCell(
                                amount: isCash ? amount : '',
                                highlight: isCash,
                                color: AppTheme.successColor,
                              ),
                              _InvoiceAmountCell(
                                amount: isCash ? '' : amount,
                                highlight: !isCash,
                                color: AppTheme.errorColor,
                                isLast: true,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Future<void> _shareInvoice(InvoiceModel invoice) async {
    if (_isSharingPdf) return;
    final loc = AppLocalizations.of(context)!;
    setState(() => _isSharingPdf = true);
    try {
      final detailsResult = await getIt<InvoiceRepository>().getInvoiceById(
        invoice.id,
      );
      final displayInvoice = detailsResult.dataOrNull ?? invoice;
      final localStorage = getIt<LocalStorageService>();
      final bytes = await InvoicePdfBuilder.build(
        loc: loc,
        invoice: displayInvoice,
        businessName: localStorage.getBusinessName(),
        businessPhone: localStorage.getUserPhone(),
        generatedBy: localStorage.getUserName(),
      );
      if (!mounted) return;
      await _sharePdf(context, bytes, displayInvoice);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${loc.errorSharingInvoice}: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSharingPdf = false);
      }
    }
  }

  Future<void> _sharePdf(
    BuildContext context,
    List<int> pdfBytes,
    InvoiceModel? invoice,
  ) async {
    final loc = AppLocalizations.of(context)!;
    if (invoice == null) return;

    try {
      final fileName =
          'invoice_${invoice.invoiceNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final formatter = CurrencyUtils.formatCurrency;

      if (!kIsWeb && mounted) {
        final shareOption = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(loc.shareInvoice),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.chat, color: AppTheme.successColor),
                  title: Text(loc.whatsapp),
                  onTap: () => Navigator.of(context).pop('whatsapp'),
                ),
                ListTile(
                  leading: const Icon(Icons.share),
                  title: Text(loc.otherApps),
                  onTap: () => Navigator.of(context).pop('other'),
                ),
              ],
            ),
          ),
        );

        if (shareOption == 'whatsapp') {
          await _shareViaWhatsApp(
              context, pdfBytes, invoice, fileName, formatter);
          return;
        }
      }

      if (kIsWeb) {
        await Share.shareXFiles(
          [
            XFile.fromData(
              Uint8List.fromList(pdfBytes),
              mimeType: 'application/pdf',
              name: fileName,
            )
          ],
          text:
              '${loc.invoice} ${invoice.invoiceNumber}\n${loc.total}: ${formatter(double.parse(invoice.totalAmount))}',
          subject: '${loc.invoice} ${invoice.invoiceNumber}',
        );
      } else {
        try {
          final tempDir = await getTemporaryDirectory();
          final filePath = path.join(tempDir.path, fileName);
          await Share.shareXFiles(
            [
              XFile.fromData(
                Uint8List.fromList(pdfBytes),
                mimeType: 'application/pdf',
                name: fileName,
                path: filePath,
              )
            ],
            text:
                '${loc.invoice} ${invoice.invoiceNumber}\n${loc.total}: ${formatter(double.parse(invoice.totalAmount))}',
            subject: '${loc.invoice} ${invoice.invoiceNumber}',
          );
        } catch (e) {
          await Share.shareXFiles(
            [
              XFile.fromData(
                Uint8List.fromList(pdfBytes),
                mimeType: 'application/pdf',
                name: fileName,
              )
            ],
            text:
                '${loc.invoice} ${invoice.invoiceNumber}\n${loc.total}: ${formatter(double.parse(invoice.totalAmount))}',
            subject: '${loc.invoice} ${invoice.invoiceNumber}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc.errorSharingInvoice}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _shareViaWhatsApp(
    BuildContext context,
    List<int> pdfBytes,
    InvoiceModel invoice,
    String fileName,
    String Function(num) formatter,
  ) async {
    final loc = AppLocalizations.of(context)!;
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = path.join(tempDir.path, fileName);
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      final message = '${loc.invoice} ${invoice.invoiceNumber}\n'
          '${loc.date}: ${DateFormat.yMMMd(loc.locale.languageCode).format(invoice.date)}\n'
          '${loc.total}: ${formatter(double.parse(invoice.totalAmount))}\n'
          '${loc.type}: ${invoice.invoiceType.toUpperCase()}';

      final whatsappUrl =
          'whatsapp://send?text=${Uri.encodeComponent(message)}';
      final whatsappWebUrl =
          'https://wa.me/?text=${Uri.encodeComponent(message)}';

      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(
          Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.whatsappOpenedAttachPdf),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else if (await canLaunchUrl(Uri.parse(whatsappWebUrl))) {
        await launchUrl(
          Uri.parse(whatsappWebUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: message,
        );
      }
    } catch (e) {
      await Share.shareXFiles(
        [
          XFile.fromData(
            Uint8List.fromList(pdfBytes),
            mimeType: 'application/pdf',
            name: fileName,
          )
        ],
        text: '${loc.invoice} ${invoice.invoiceNumber}',
      );
    }
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _InvoiceMiniStat extends StatelessWidget {
  const _InvoiceMiniStat({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            CurrencyUtils.formatCurrency(amount),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceAmountCell extends StatelessWidget {
  const _InvoiceAmountCell({
    required this.amount,
    required this.highlight,
    required this.color,
    this.isLast = false,
  });

  final String amount;
  final bool highlight;
  final Color color;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: highlight ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: isLast
              ? const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                )
              : null,
        ),
        child: Text(
          amount,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: highlight ? color : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
