import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/localization/app_localizations.dart';
import '../models/invoice_model.dart';

class InvoicePdfBuilder {
  InvoicePdfBuilder._();

  static const double _outerBorder = 1.2;
  static const double _innerBorder = 0.75;

  static Future<Uint8List> build({
    required AppLocalizations loc,
    required InvoiceModel invoice,
    String? businessName,
    String? businessPhone,
    String? businessAddress,
    String? generatedBy,
    DateTime? generatedAt,
  }) async {
    final pdf = pw.Document();
    final createdAt = generatedAt ?? DateTime.now();
    final items = invoice.items ?? const <InvoiceItemModel>[];
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final dateTimeFormatter = DateFormat('dd/MM/yyyy hh:mm a');

    final subtotal = _parseAmount(invoice.subtotal);
    final taxAmount = _parseAmount(invoice.taxAmount);
    final discountAmount = _parseAmount(invoice.discountAmount);
    final totalAmount = _parseAmount(invoice.totalAmount);
    final paidAmount = _parseAmount(invoice.paidAmount);
    final balance = totalAmount - paidAmount;
    final totalQty = items.fold<double>(
      0,
      (sum, item) => sum + _parseAmount(item.quantity),
    );
    final taxPercent = subtotal > 0 ? (taxAmount / subtotal) * 100 : 0.0;
    final discountPercent =
        subtotal > 0 ? (discountAmount / subtotal) * 100 : 0.0;

    final logo = await _loadLogo();
    final rows = _buildItemRows(
      loc: loc,
      invoice: invoice,
      items: items,
      discountPercent: discountPercent,
      taxPercent: taxPercent,
    );

    final totals = <(String, String)>[
      (loc.subtotal, _money(subtotal)),
      (loc.discountAmount, _money(discountAmount)),
      (loc.taxAmount, _money(taxAmount)),
      (loc.totalAmount, _money(totalAmount)),
      (loc.paid, _money(paidAmount)),
      (loc.balance, _money(balance)),
    ];

    final businessTitle =
        (businessName ?? '').trim().isEmpty ? 'Business' : businessName!.trim();
    final businessPhoneText = (businessPhone ?? '').trim();
    final businessAddressText = (businessAddress ?? '').trim();
    final generatedByText =
        (generatedBy ?? '').trim().isEmpty ? loc.system : generatedBy!.trim();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(18, 18, 18, 18),
        build: (_) => [
          _buildHeader(
            title: loc.invoice,
            logo: logo,
            qrData:
                '${invoice.invoiceNumber}|${invoice.date.toIso8601String()}|${invoice.totalAmount}',
            businessTitle: businessTitle,
            businessPhone: businessPhoneText,
            businessAddress: businessAddressText,
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _buildMetaTable([
                  (loc.invoice, invoice.invoiceNumber),
                  (loc.date, dateFormatter.format(invoice.date)),
                  (loc.type, invoice.invoiceType.toUpperCase()),
                  (loc.entries, '${items.isEmpty ? 1 : items.length}'),
                ]),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: _buildMetaTable([
                  (loc.totalAmount, _money(totalAmount)),
                  (loc.paid, _money(paidAmount)),
                  (loc.balance, _money(balance)),
                  (
                    loc.quantity,
                    NumberFormat('0.##', 'en').format(totalQty),
                  ),
                ]),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          _buildItemsTable(loc: loc, rows: rows),
          pw.SizedBox(height: rows.length <= 10 ? 120 : 12),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${loc.total}: ${_money(totalAmount)}',
                      style: const pw.TextStyle(fontSize: 8.2),
                    ),
                    if ((invoice.remarks ?? '').trim().isNotEmpty) ...[
                      pw.SizedBox(height: 6),
                      pw.Text(
                        '${loc.remarks}: ${invoice.remarks!.trim()}',
                        style: const pw.TextStyle(fontSize: 8.2),
                      ),
                    ],
                  ],
                ),
              ),
              pw.SizedBox(width: 10),
              _buildTotalsPanel(totals),
            ],
          ),
          pw.SizedBox(height: 10),
          _buildNotesPanel(loc: loc),
          pw.SizedBox(height: 10),
          _buildFooter(
            generatedBy: generatedByText,
            generatedAt: createdAt,
            dateTimeFormatter: dateTimeFormatter,
          ),
        ],
      ),
    );

    return Uint8List.fromList(await pdf.save());
  }

  static pw.Widget _buildHeader({
    required String title,
    required pw.MemoryImage? logo,
    required String qrData,
    required String businessTitle,
    required String businessPhone,
    required String businessAddress,
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
                  businessTitle,
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.right,
                ),
                if (businessPhone.isNotEmpty) ...[
                  pw.SizedBox(height: 3),
                  pw.Text(
                    businessPhone,
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
                if (businessAddress.isNotEmpty) ...[
                  pw.SizedBox(height: 3),
                  pw.Text(
                    businessAddress,
                    textAlign: pw.TextAlign.right,
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
                  ),
                ),
              ],
            ),
          )
          .toList(growable: false),
    );
  }

  static pw.Widget _buildItemsTable({
    required AppLocalizations loc,
    required List<List<String>> rows,
  }) {
    return pw.TableHelper.fromTextArray(
      headers: [
        '#',
        loc.item,
        loc.unit,
        loc.quantity,
        loc.unitPrice,
        'Disc%',
        'Tax%',
        loc.amount,
      ],
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
        0: const pw.FixedColumnWidth(22),
        1: const pw.FlexColumnWidth(3.8),
        2: const pw.FixedColumnWidth(24),
        3: const pw.FixedColumnWidth(22),
        4: const pw.FixedColumnWidth(36),
        5: const pw.FixedColumnWidth(26),
        6: const pw.FixedColumnWidth(26),
        7: const pw.FixedColumnWidth(56),
      },
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
        6: pw.Alignment.centerRight,
        7: pw.Alignment.centerRight,
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

  static pw.Widget _buildNotesPanel({
    required AppLocalizations loc,
  }) {
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
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Text(
            loc.additionalNotes,
            style: const pw.TextStyle(fontSize: 7.8),
          ),
        ),
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
    required DateFormat dateTimeFormatter,
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
                dateTimeFormatter.format(generatedAt),
                style: const pw.TextStyle(fontSize: 7.8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static List<List<String>> _buildItemRows({
    required AppLocalizations loc,
    required InvoiceModel invoice,
    required List<InvoiceItemModel> items,
    required double discountPercent,
    required double taxPercent,
  }) {
    final rows = items.isEmpty
        ? <List<String>>[
            [
              '1',
              loc.invoice,
              '-',
              '1',
              _money(_parseAmount(invoice.totalAmount)),
              NumberFormat('0.00', 'en').format(discountPercent),
              NumberFormat('0.00', 'en').format(taxPercent),
              _money(_parseAmount(invoice.totalAmount)),
            ],
          ]
        : items.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final item = entry.value;
            final quantity = _parseAmount(item.quantity);
            final unitPrice = _parseAmount(item.unitPrice);
            final totalPrice = _parseAmount(item.totalPrice) > 0
                ? _parseAmount(item.totalPrice)
                : quantity * unitPrice;
            return [
              '$index',
              item.itemName,
              '-',
              quantity % 1 == 0
                  ? quantity.toInt().toString()
                  : NumberFormat('0.##', 'en').format(quantity),
              _money(unitPrice),
              NumberFormat('0.00', 'en').format(discountPercent),
              NumberFormat('0.00', 'en').format(taxPercent),
              _money(totalPrice),
            ];
          }).toList(growable: true);

    const minRows = 10;
    if (rows.length < minRows) {
      final blanks = minRows - rows.length;
      for (var i = 0; i < blanks; i++) {
        rows.add(List<String>.filled(8, ''));
      }
    }

    return rows;
  }

  static Future<pw.MemoryImage?> _loadLogo() async {
    try {
      final bytes = await rootBundle.load('app-logo.jpeg');
      return pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  static double _parseAmount(String? value) {
    return double.tryParse(value ?? '') ?? 0;
  }

  static String _money(num value) {
    final symbol = 'Rs';
    return '$symbol ${NumberFormat('#,##0.00', 'en').format(value)}';
  }
}
