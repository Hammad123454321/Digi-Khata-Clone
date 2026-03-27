import 'package:equatable/equatable.dart';

/// Expense Category Model
class ExpenseCategoryModel extends Equatable {
  const ExpenseCategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.isActive,
  });

  final String id;
  final String name;
  final String? description;
  final bool? isActive;

  factory ExpenseCategoryModel.fromJson(Map<String, dynamic> json) {
    return ExpenseCategoryModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
    };
  }

  @override
  List<Object?> get props => [id, name, description, isActive];
}

/// Expense Model
class ExpenseModel extends Equatable {
  const ExpenseModel({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.date,
    required this.paymentMode,
    this.description,
    this.createdAt,
  });

  final String id;
  final String categoryId;
  final String amount;
  final DateTime date;
  final String paymentMode; // 'cash' or 'bank'
  final String? description;
  final DateTime? createdAt;

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'].toString(),
      categoryId: json['category_id'].toString(),
      amount: json['amount'] as String,
      date: DateTime.parse(json['date'] as String),
      paymentMode: json['payment_mode'] as String,
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'amount': amount,
      'date': date.toIso8601String(),
      'payment_mode': paymentMode,
      if (description != null) 'description': description,
    };
  }

  @override
  List<Object?> get props => [
        id,
        categoryId,
        amount,
        date,
        paymentMode,
        description,
        createdAt,
      ];
}
