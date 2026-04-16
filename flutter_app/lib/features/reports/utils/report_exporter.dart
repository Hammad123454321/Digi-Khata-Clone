import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/di/injection.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/storage/local_storage_service.dart';

class ReportShareResult {
  const ReportShareResult({
    required this.success,
    this.message,
    this.usedFallback = false,
  });

  final bool success;
  final String? message;
  final bool usedFallback;
}

class ReportExporter {
  ReportExporter._();

  static const double _outerBorder = 1.2;
  static const double _innerBorder = 0.75;

  static Future<ReportShareResult> shareReportPdf({
    required AppLocalizations loc,
    required String title,
    required Map<String, dynamic> report,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (_isStockReport(report)) {
        return await _shareStockReportPdf(
          loc: loc,
          title: title,
          report: report,
          startDate: startDate,
          endDate: endDate,
        );
      }

      final doc = pw.Document();
      final generatedAt = DateTime.now();
      final localStorage = getIt<LocalStorageService>();
      final logo = await _loadLogo();

      final scalarRows = _extractScalarRows(report);
      final listSections = _extractListSections(report);

      final tableModel = _buildTableModel(
        loc: loc,
        scalarRows: scalarRows,
        listSections: listSections,
      );
      final totals = _buildTotalsRows(
        loc: loc,
        scalarRows: scalarRows,
        tableRowsCount: tableModel.rows.length,
      );

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(18, 18, 18, 18),
          build: (_) => [
            _buildHeader(
              title: title,
              logo: logo,
              qrData: '$title|${generatedAt.toIso8601String()}',
              businessName: localStorage.getBusinessName() ?? 'Business',
              businessPhone: localStorage.getUserPhone() ?? '',
            ),
            pw.SizedBox(height: 12),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: _buildMetaTable([
                    (loc.report, title),
                    (
                      loc.dateRange,
                      _buildDateRangeText(
                        startDate: startDate,
                        endDate: endDate,
                      ),
                    ),
                    (loc.entries, '${tableModel.actualRowsCount}'),
                    (loc.date, DateFormat('dd/MM/yyyy').format(generatedAt)),
                  ]),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: _buildMetaTable(
                    scalarRows.take(4).isEmpty
                        ? [(loc.total, '-')]
                        : scalarRows.take(4).toList(growable: false),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 12),
            _buildTable(
              headers: tableModel.headers,
              rows: tableModel.rows,
            ),
            pw.SizedBox(height: tableModel.rows.length <= 10 ? 120 : 12),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    loc.additionalNotes,
                    style: const pw.TextStyle(fontSize: 8.2),
                  ),
                ),
                pw.SizedBox(width: 10),
                _buildTotalsPanel(totals),
              ],
            ),
            pw.SizedBox(height: 10),
            _buildNotesPanel(loc),
            pw.SizedBox(height: 10),
            _buildFooter(
              generatedBy: localStorage.getUserName() ?? loc.system,
              generatedAt: generatedAt,
            ),
          ],
        ),
      );

      final bytes = await doc.save();
      final filename = _buildFileName(title, generatedAt);
      return await _sharePdfWithFallback(
        bytes: bytes,
        filename: filename,
      );
    } catch (e) {
      return ReportShareResult(
        success: false,
        message: 'Failed to generate report PDF: $e',
      );
    }
  }

  static bool _isStockReport(Map<String, dynamic> report) {
    return report.containsKey('period_summary') &&
        report.containsKey('sold_items') &&
        report.containsKey('profit_loss_summary');
  }

  static Future<ReportShareResult> _shareStockReportPdf({
    required AppLocalizations loc,
    required String title,
    required Map<String, dynamic> report,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final doc = pw.Document();
    final generatedAt = DateTime.now();
    final localStorage = getIt<LocalStorageService>();
    final logo = await _loadLogo();

    final periodSummary = _mapFromDynamic(report['period_summary']);
    final profitLossSummary = _mapFromDynamic(report['profit_loss_summary']);
    final soldItems = _listOfMaps(report['sold_items']);
    final customerBreakdown =
        _listOfMaps(report['sold_items_customer_breakdown']);

    final kpiRows = <List<String>>[
      [
        'Stock Gone',
        _stringifyCell(periodSummary['sold_qty'] ?? report['total_sold_qty']),
      ],
      [
        'Stock Left',
        _stringifyCell(periodSummary['left_qty']),
      ],
      [
        'Sales',
        _stringifyCell(
          periodSummary['sold_value'] ?? profitLossSummary['sales_revenue'],
        ),
      ],
      [
        'Gross Profit',
        _stringifyCell(profitLossSummary['gross_profit']),
      ],
    ];

    final soldItemsRows = soldItems
        .asMap()
        .entries
        .map(
          (entry) => <String>[
            '${entry.key + 1}',
            _stringifyCell(entry.value['item_name']),
            _stringifyCell(entry.value['sold_qty']),
            _stringifyCell(entry.value['unit']),
            _stringifyCell(entry.value['sold_amount']),
            _stringifyCell(entry.value['left_qty']),
            _stringifyCell(entry.value['left_value']),
            _stringifyCell(entry.value['gross_profit']),
          ],
        )
        .toList(growable: false);

    final customerRows = <List<String>>[];
    for (final item in customerBreakdown) {
      final itemName = _stringifyCell(item['item_name']);
      final customers = _listOfMaps(item['customers']);
      for (final customer in customers) {
        customerRows.add([
          '${customerRows.length + 1}',
          itemName,
          _stringifyCell(customer['customer_name']),
          _stringifyCell(customer['qty']),
          _stringifyCell(customer['amount']),
          _stringifyCell(customer['invoice_count']),
          _stringifyCell(customer['last_sale_at']),
        ]);
      }
    }

    final profitRows = <List<String>>[
      ['Sales Revenue', _stringifyCell(profitLossSummary['sales_revenue'])],
      ['COGS', _stringifyCell(profitLossSummary['cogs'])],
      ['Gross Profit', _stringifyCell(profitLossSummary['gross_profit'])],
      [
        'Gross Margin %',
        _stringifyCell(profitLossSummary['gross_margin_percent']),
      ],
    ];

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(18, 18, 18, 18),
        build: (_) => [
          _buildHeader(
            title: title,
            logo: logo,
            qrData: '$title|${generatedAt.toIso8601String()}',
            businessName: localStorage.getBusinessName() ?? 'Business',
            businessPhone: localStorage.getUserPhone() ?? '',
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _buildMetaTable([
                  (loc.report, title),
                  (
                    loc.dateRange,
                    _buildDateRangeText(
                      startDate: startDate,
                      endDate: endDate,
                    ),
                  ),
                  (
                    loc.entries,
                    _stringifyCell(
                      periodSummary['sold_entries'] ?? soldItems.length,
                    ),
                  ),
                  (loc.date, DateFormat('dd/MM/yyyy').format(generatedAt)),
                ]),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: _buildSimpleTable(
                  headers: const ['KPI', 'Value'],
                  rows: kpiRows,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Sold Items',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          _buildSimpleTable(
            headers: const [
              '#',
              'Item',
              'Sold Qty',
              'Unit',
              'Sales',
              'Left Qty',
              'Left Value',
              'Gross Profit',
            ],
            rows: soldItemsRows.isEmpty
                ? const [
                    [
                      '-',
                      'No sold items in selected range',
                      '-',
                      '-',
                      '-',
                      '-',
                      '-',
                      '-',
                    ],
                  ]
                : soldItemsRows,
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Customer-wise Breakdown',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          _buildSimpleTable(
            headers: const [
              '#',
              'Item',
              'Customer',
              'Qty',
              'Amount',
              'Invoices',
              'Last Sale',
            ],
            rows: customerRows.isEmpty
                ? const [
                    [
                      '-',
                      'No customer-wise sales in selected range',
                      '-',
                      '-',
                      '-',
                      '-',
                      '-',
                    ],
                  ]
                : customerRows,
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Profit/Loss Summary',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          _buildSimpleTable(
            headers: const ['Metric', 'Value'],
            rows: profitRows,
          ),
          pw.SizedBox(height: 10),
          _buildFooter(
            generatedBy: localStorage.getUserName() ?? loc.system,
            generatedAt: generatedAt,
          ),
        ],
      ),
    );

    final bytes = await doc.save();
    final filename = _buildFileName(title, generatedAt);
    return await _sharePdfWithFallback(
      bytes: bytes,
      filename: filename,
    );
  }

  static Future<ReportShareResult> _sharePdfWithFallback({
    required Uint8List bytes,
    required String filename,
  }) async {
    try {
      await Printing.sharePdf(
        bytes: bytes,
        filename: filename,
      );
      return const ReportShareResult(success: true);
    } catch (_) {
      try {
        final tempDir = await getTemporaryDirectory();
        final filePath = path.join(tempDir.path, filename);
        final file = File(filePath);
        await file.writeAsBytes(bytes, flush: true);

        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'application/pdf')],
          subject: filename,
        );
        return const ReportShareResult(
          success: true,
          usedFallback: true,
        );
      } catch (e) {
        return ReportShareResult(
          success: false,
          message: 'Failed to share report PDF: $e',
        );
      }
    }
  }

  static Future<pw.MemoryImage?> _loadLogo() async {
    try {
      final bytes = await rootBundle.load('app-logo.jpeg');
      return pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  static pw.Widget _buildHeader({
    required String title,
    required pw.MemoryImage? logo,
    required String qrData,
    required String businessName,
    required String businessPhone,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: _outerBorder),
        borderRadius: const pw.BorderRadius.all(
          pw.Radius.circular(4),
        ),
      ),
      padding: const pw.EdgeInsets.all(7),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Container(
            width: 70,
            height: 70,
            decoration: pw.BoxDecoration(
              border:
                  pw.Border.all(color: PdfColors.black, width: _innerBorder),
            ),
            alignment: pw.Alignment.center,
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: qrData,
              width: 58,
              height: 58,
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                if (logo != null)
                  pw.SizedBox(
                    width: 78,
                    height: 48,
                    child: pw.Image(logo),
                  )
                else
                  pw.Text(
                    'DIGI KHATA',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                pw.SizedBox(height: 3),
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(width: 10),
          pw.SizedBox(
            width: 150,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  businessName,
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.right,
                ),
                if (businessPhone.trim().isNotEmpty) ...[
                  pw.SizedBox(height: 3),
                  pw.Text(
                    businessPhone.trim(),
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildMetaTable(List<(String, String)> rows) {
    return pw.Table(
      columnWidths: {
        0: const pw.FixedColumnWidth(78),
      },
      children: rows
          .map(
            (row) => pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.fromLTRB(0, 1, 4, 5),
                  child: pw.Text(
                    row.$1,
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontSize: 7.8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Container(
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(
                        color: PdfColors.black,
                        width: _innerBorder,
                      ),
                    ),
                  ),
                  padding: const pw.EdgeInsets.fromLTRB(3, 1, 2, 5),
                  child: pw.Text(
                    row.$2,
                    style: const pw.TextStyle(fontSize: 7.8),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          )
          .toList(growable: false),
    );
  }

  static pw.Widget _buildTable({
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      headerStyle: pw.TextStyle(
        fontSize: 8,
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: const pw.TextStyle(fontSize: 7.7),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      border: pw.TableBorder.all(color: PdfColors.black, width: _innerBorder),
      cellHeight: 18,
      headerHeight: 18,
      columnWidths: {
        for (var i = 0; i < headers.length; i++)
          i: i == 0
              ? const pw.FixedColumnWidth(22)
              : (i == 1
                  ? const pw.FlexColumnWidth(3.6)
                  : (i == headers.length - 1
                      ? const pw.FixedColumnWidth(56)
                      : const pw.FixedColumnWidth(40))),
      },
      cellAlignments: {
        for (var i = 0; i < headers.length; i++)
          i: i == 0 ? pw.Alignment.center : pw.Alignment.centerLeft,
      },
    );
  }

  static pw.Widget _buildSimpleTable({
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      headerStyle: pw.TextStyle(
        fontSize: 8,
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: const pw.TextStyle(fontSize: 7.6),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      border: pw.TableBorder.all(color: PdfColors.black, width: _innerBorder),
      cellHeight: 18,
      headerHeight: 18,
      cellAlignments: {
        for (var i = 0; i < headers.length; i++)
          i: i == 0 ? pw.Alignment.center : pw.Alignment.centerLeft,
      },
    );
  }

  static pw.Widget _buildTotalsPanel(List<(String, String)> totals) {
    return pw.Container(
      width: 205,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: _outerBorder),
      ),
      child: pw.Table(
        children: totals
            .map(
              (row) => pw.TableRow(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 3,
                    ),
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        right: pw.BorderSide(
                          color: PdfColors.black,
                          width: _innerBorder,
                        ),
                        bottom: pw.BorderSide(
                          color: PdfColors.black,
                          width: _innerBorder,
                        ),
                      ),
                    ),
                    child: pw.Text(
                      row.$1,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 7.8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 3,
                    ),
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(
                          color: PdfColors.black,
                          width: _innerBorder,
                        ),
                      ),
                    ),
                    child: pw.Text(
                      row.$2,
                      textAlign: pw.TextAlign.right,
                      style: const pw.TextStyle(fontSize: 7.8),
                    ),
                  ),
                ],
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  static pw.Widget _buildNotesPanel(AppLocalizations loc) {
    pw.Widget noteBox(String label) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 4),
        height: 20,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.black, width: _outerBorder),
        ),
        alignment: pw.Alignment.center,
        child: pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 7.8,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      );
    }

    return pw.Row(
      children: [
        pw.Expanded(child: pw.SizedBox()),
        pw.SizedBox(width: 10),
        pw.SizedBox(
          width: 205,
          child: pw.Column(
            children: [
              noteBox(loc.additionalNotes),
              noteBox(loc.remarks),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter({
    required String generatedBy,
    required DateTime generatedAt,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 5),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.black, width: _outerBorder),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            generatedBy,
            style: const pw.TextStyle(fontSize: 7.8),
          ),
          pw.Row(
            children: [
              pw.Text(
                '1/1',
                style: const pw.TextStyle(fontSize: 7.8),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                DateFormat('dd/MM/yyyy hh:mm a').format(generatedAt),
                style: const pw.TextStyle(fontSize: 7.8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _buildDateRangeText({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (startDate == null || endDate == null) return '-';
    final formatter = DateFormat('dd/MM/yyyy');
    return '${formatter.format(startDate)} - ${formatter.format(endDate)}';
  }

  static String _buildFileName(String title, DateTime generatedAt) {
    final safeTitle =
        title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    final stamp = DateFormat('yyyyMMdd_HHmm').format(generatedAt);
    return '${safeTitle}_$stamp.pdf';
  }

  static _ReportTableModel _buildTableModel({
    required AppLocalizations loc,
    required List<(String, String)> scalarRows,
    required List<(String, List<Map<String, dynamic>>)> listSections,
  }) {
    if (listSections.isNotEmpty) {
      final rows = listSections.first.$2;
      final headers = _extractHeaders(rows);
      final headerLabels = <String>[
        '#',
        ...headers.map(_toLabel),
      ];
      final tableRows =
          rows.take(30).toList(growable: false).asMap().entries.map(
        (entry) {
          final index = entry.key + 1;
          final row = entry.value;
          return [
            '$index',
            ...headers.map((header) => _stringifyCell(row[header])),
          ];
        },
      ).toList(growable: true);

      const minRows = 10;
      if (tableRows.length < minRows) {
        final missing = minRows - tableRows.length;
        final columnCount = headerLabels.length;
        for (var i = 0; i < missing; i++) {
          tableRows.add(List<String>.filled(columnCount, ''));
        }
      }

      return _ReportTableModel(
        headers: headerLabels,
        rows: tableRows,
        actualRowsCount: rows.length,
      );
    }

    final headerLabels = <String>['#', loc.entries, loc.total];
    final tableRows =
        scalarRows.take(30).toList(growable: false).asMap().entries.map(
      (entry) {
        final index = entry.key + 1;
        final row = entry.value;
        return ['$index', row.$1, row.$2];
      },
    ).toList(growable: true);

    const minRows = 10;
    if (tableRows.length < minRows) {
      final missing = minRows - tableRows.length;
      for (var i = 0; i < missing; i++) {
        tableRows.add(List<String>.filled(headerLabels.length, ''));
      }
    }

    return _ReportTableModel(
      headers: headerLabels,
      rows: tableRows,
      actualRowsCount: scalarRows.length,
    );
  }

  static List<(String, String)> _buildTotalsRows({
    required AppLocalizations loc,
    required List<(String, String)> scalarRows,
    required int tableRowsCount,
  }) {
    final numericRows = scalarRows
        .where(
          (row) => _looksLikeTotalField(row.$1) || _isNumericLike(row.$2),
        )
        .take(5)
        .toList(growable: false);

    if (numericRows.isNotEmpty) {
      return numericRows;
    }

    return [
      (loc.entries, '$tableRowsCount'),
      ...scalarRows.take(4),
    ];
  }

  static List<(String, String)> _extractScalarRows(
    Map<String, dynamic> report,
  ) {
    final rows = <(String, String)>[];
    report.forEach((key, value) {
      if (key == 'is_offline' || value is List || value is Map) {
        return;
      }
      rows.add((_toLabel(key), _stringifyCell(value)));
    });
    return rows;
  }

  static List<(String, List<Map<String, dynamic>>)> _extractListSections(
    Map<String, dynamic> report,
  ) {
    final sections = <(String, List<Map<String, dynamic>>)>[];
    report.forEach((key, value) {
      if (value is! List || value.isEmpty) return;
      final rows = value
          .whereType<Map>()
          .map((entry) => Map<String, dynamic>.from(entry))
          .toList(growable: false);
      if (rows.isNotEmpty) {
        sections.add((key, rows));
      }
    });
    return sections;
  }

  static List<String> _extractHeaders(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return const ['details'];
    final first = rows.first;
    final keys = first.keys.toList(growable: false);
    if (keys.length <= 7) {
      return keys;
    }
    return keys.take(7).toList(growable: false);
  }

  static Map<String, dynamic> _mapFromDynamic(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const {};
  }

  static List<Map<String, dynamic>> _listOfMaps(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList(growable: false);
  }

  static bool _isNumericLike(String value) {
    final normalized =
        value.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.\\-]'), '');
    return normalized.isNotEmpty && double.tryParse(normalized) != null;
  }

  static bool _looksLikeTotalField(String key) {
    final lower = key.toLowerCase();
    return lower.contains('total') ||
        lower.contains('balance') ||
        lower.contains('amount') ||
        lower.contains('profit') ||
        lower.contains('loss') ||
        lower.contains('value');
  }

  static String _stringifyCell(dynamic value) {
    if (value == null) return '-';
    if (value is DateTime) {
      return DateFormat('dd/MM/yyyy').format(value);
    }
    final text = value.toString().trim();
    return text.isEmpty ? '-' : text;
  }

  static String _toLabel(String key) {
    final raw = key.replaceAll('_', ' ').trim();
    if (raw.isEmpty) return key;
    return raw[0].toUpperCase() + raw.substring(1);
  }
}

class _ReportTableModel {
  const _ReportTableModel({
    required this.headers,
    required this.rows,
    required this.actualRowsCount,
  });

  final List<String> headers;
  final List<List<String>> rows;
  final int actualRowsCount;
}
class ReportShareResult {
  const ReportShareResult({
    required this.success,
    this.message,
    this.usedFallback = false,
  });

  final bool success;
  final String? message;
  final bool usedFallback;
}
