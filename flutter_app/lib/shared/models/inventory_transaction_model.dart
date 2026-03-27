import 'package:equatable/equatable.dart';

/// Inventory Transaction Model
class InventoryTransactionModel extends Equatable {
  const InventoryTransactionModel({
    required this.id,
    required this.itemId,
    required this.transactionType,
    required this.quantity,
    required this.unitPrice,
    required this.date,
    this.remarks,
    this.createdAt,
  });

  final String id;
  final String itemId;
  final String
      transactionType; // 'stock_in', 'stock_out', 'wastage', 'adjustment'
  final String quantity;
  final String unitPrice;
  final DateTime date;
  final String? remarks;
  final DateTime? createdAt;

  factory InventoryTransactionModel.fromJson(Map<String, dynamic> json) {
    return InventoryTransactionModel(
      id: json['id'].toString(),
      itemId: json['item_id'].toString(),
      transactionType: json['transaction_type'] as String,
      quantity: json['quantity']?.toString() ?? '0',
      unitPrice: json['unit_price']?.toString() ?? '0',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      remarks: json['remarks'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'transaction_type': transactionType,
      'quantity': quantity,
      'unit_price': unitPrice,
      'date': date.toIso8601String(),
      if (remarks != null) 'remarks': remarks,
    };
  }

  @override
  List<Object?> get props => [
        id,
        itemId,
        transactionType,
        quantity,
        unitPrice,
        date,
        remarks,
        createdAt,
      ];
}
