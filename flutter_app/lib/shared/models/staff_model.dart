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

/// Staff Model
class StaffModel extends Equatable {
  const StaffModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.role,
    this.address,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    final resolved = _unwrapPayload(json);
    final id = _nullableString(resolved['id'] ?? resolved['_id']);
    final name = _nullableString(resolved['name']);
    if (id == null || name == null) {
      throw const FormatException('Invalid staff payload');
    }

    return StaffModel(
      id: id,
      name: name,
      phone: _nullableString(resolved['phone']),
      email: _nullableString(resolved['email']),
      role: _nullableString(resolved['role']),
      address: _nullableString(resolved['address']),
      isActive: resolved['is_active'] as bool?,
      createdAt: _parseDate(resolved['created_at']),
      updatedAt: _parseDate(resolved['updated_at']),
    );
  }

  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? role;
  final String? address;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (role != null) 'role': role,
      if (address != null) 'address': address,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        email,
        role,
        address,
        isActive,
        createdAt,
        updatedAt,
      ];

  static Map<String, dynamic> _unwrapPayload(Map<String, dynamic> json) {
    if (json['data'] is Map) {
      return Map<String, dynamic>.from(json['data'] as Map);
    }
    if (json['staff'] is Map) {
      return Map<String, dynamic>.from(json['staff'] as Map);
    }
    return json;
  }
}
