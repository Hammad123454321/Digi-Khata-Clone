import 'package:equatable/equatable.dart';

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

/// Supplier Model
class SupplierModel extends Equatable {
  const SupplierModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.isActive,
    this.balance,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final bool? isActive;
  final String? balance;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      phone: _nullableString(json['phone']),
      email: _nullableString(json['email']),
      address: _nullableString(json['address']),
      isActive: json['is_active'] as bool?,
      balance: _nullableString(json['balance']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        email,
        address,
        isActive,
        balance,
        createdAt,
        updatedAt,
      ];
}
