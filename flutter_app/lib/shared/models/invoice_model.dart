import 'package:equatable/equatable.dart';

String _stringOrDefault(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

String? _nullableString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

DateTime? _parseDate(dynamic value) {
  if (value is DateTime) return value;
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

/// Invoice Item Model
class InvoiceItemModel extends Equatable {
  const InvoiceItemModel({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  final String id;
  final String? itemId;
  final String itemName;
  final String quantity;
  final String unitPrice;
  final String totalPrice;

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: _stringOrDefault(json['id'], fallback: ''),
      itemId: _nullableString(json['item_id']),
      itemName: _stringOrDefault(json['item_name'], fallback: ''),
      quantity: _stringOrDefault(json['quantity'], fallback: '0'),
      unitPrice: _stringOrDefault(json['unit_price'], fallback: '0'),
      totalPrice: _stringOrDefault(json['total_price'], fallback: '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (itemId != null) 'item_id': itemId,
      'item_name': itemName,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }

  @override
  List<Object?> get props =>
      [id, itemId, itemName, quantity, unitPrice, totalPrice];
}

/// Invoice Model
class InvoiceModel extends Equatable {
  const InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    this.customerId,
    required this.invoiceType,
    required this.date,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.paidAmount,
    this.remarks,
    this.pdfPath,
    this.items,
    this.createdAt,
  });

  final String id;
  final String invoiceNumber;
  final String? customerId;
  final String invoiceType; // 'cash' or 'credit'
  final DateTime date;
  final String subtotal;
  final String taxAmount;
  final String discountAmount;
  final String totalAmount;
  final String paidAmount;
  final String? remarks;
  final String? pdfPath;
  final List<InvoiceItemModel>? items;
  final DateTime? createdAt;

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: _stringOrDefault(json['id'], fallback: ''),
      invoiceNumber: _stringOrDefault(json['invoice_number'], fallback: ''),
      customerId: _nullableString(json['customer_id']),
      invoiceType: json['invoice_type'] as String? ?? 'cash',
      date: _parseDate(json['date']) ?? DateTime.now(),
      subtotal: _stringOrDefault(json['subtotal'], fallback: '0'),
      taxAmount: _stringOrDefault(json['tax_amount'], fallback: '0'),
      discountAmount: _stringOrDefault(json['discount_amount'], fallback: '0'),
      totalAmount: _stringOrDefault(json['total_amount'], fallback: '0'),
      paidAmount: _stringOrDefault(json['paid_amount'], fallback: '0'),
      remarks: _nullableString(json['remarks']),
      pdfPath: _nullableString(json['pdf_path']),
      items: json['items'] != null
          ? (json['items'] as List<dynamic>)
              .map((e) => InvoiceItemModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      createdAt: _parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (customerId != null) 'customer_id': customerId,
      'invoice_type': invoiceType,
      'date': date.toIso8601String(),
      'items': items?.map((e) => e.toJson()).toList() ?? [],
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
      if (remarks != null) 'remarks': remarks,
    };
  }

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        customerId,
        invoiceType,
        date,
        subtotal,
        taxAmount,
        discountAmount,
        totalAmount,
        paidAmount,
        remarks,
        pdfPath,
        items,
        createdAt,
      ];
}
