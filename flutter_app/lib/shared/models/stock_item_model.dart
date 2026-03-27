import 'package:equatable/equatable.dart';

/// Stock Item Model
class StockItemModel extends Equatable {
  const StockItemModel({
    required this.id,
    required this.name,
    required this.purchasePrice,
    required this.salePrice,
    required this.unit,
    required this.currentStock,
    this.description,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String purchasePrice;
  final String salePrice;
  final String unit;
  final String currentStock;
  final String? description;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory StockItemModel.fromJson(Map<String, dynamic> json) {
    return StockItemModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      purchasePrice: json['purchase_price'] as String,
      salePrice: json['sale_price'] as String,
      unit: json['unit'] as String,
      currentStock: json['current_stock'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'purchase_price': purchasePrice,
      'sale_price': salePrice,
      'unit': unit,
      if (description != null) 'description': description,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        purchasePrice,
        salePrice,
        unit,
        currentStock,
        description,
        isActive,
        createdAt,
        updatedAt,
      ];
}
