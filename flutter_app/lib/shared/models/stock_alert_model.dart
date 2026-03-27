import 'package:equatable/equatable.dart';

/// Stock Alert Model
class StockAlertModel extends Equatable {
  const StockAlertModel({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.currentStock,
    required this.threshold,
    required this.isResolved,
    this.createdAt,
  });

  final String id;
  final String itemId;
  final String itemName;
  final String currentStock;
  final String threshold;
  final bool isResolved;
  final DateTime? createdAt;

  factory StockAlertModel.fromJson(Map<String, dynamic> json) {
    return StockAlertModel(
      id: json['id'].toString(),
      itemId: json['item_id'].toString(),
      itemName: json['item_name'] as String,
      currentStock: json['current_stock'] as String,
      threshold: json['threshold'] as String,
      isResolved: json['is_resolved'] as bool,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        itemId,
        itemName,
        currentStock,
        threshold,
        isResolved,
        createdAt,
      ];
}
