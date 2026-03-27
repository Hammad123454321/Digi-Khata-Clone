import 'package:equatable/equatable.dart';

/// Business Model
class BusinessModel extends Equatable {
  const BusinessModel({
    required this.id,
    required this.name,
    this.phone,
    this.ownerName,
    this.email,
    this.address,
    this.area,
    this.city,
    this.businessCategory,
    this.businessType,
    this.customBusinessType,
    this.isActive,
    this.languagePreference,
    this.maxDevices,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? phone;
  final String? ownerName;
  final String? email;
  final String? address;
  final String? area;
  final String? city;
  final String? businessCategory;
  final String? businessType;
  final String? customBusinessType;
  final bool? isActive;
  final String? languagePreference;
  final int? maxDevices;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      phone: json['phone'] as String? ?? '',
      ownerName: json['owner_name'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      area: json['area'] as String?,
      city: json['city'] as String?,
      businessCategory: json['business_category'] as String?,
      businessType: json['business_type'] as String?,
      customBusinessType: json['custom_business_type'] as String?,
      isActive: json['is_active'] as bool?,
      languagePreference: json['language_preference'] as String?,
      maxDevices: json['max_devices'] as int?,
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
      'id': id,
      'name': name,
      'phone': phone,
      if (ownerName != null) 'owner_name': ownerName,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (area != null) 'area': area,
      if (city != null) 'city': city,
      if (businessCategory != null) 'business_category': businessCategory,
      if (businessType != null) 'business_type': businessType,
      if (customBusinessType != null)
        'custom_business_type': customBusinessType,
      if (isActive != null) 'is_active': isActive,
      if (languagePreference != null) 'language_preference': languagePreference,
      if (maxDevices != null) 'max_devices': maxDevices,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        ownerName,
        email,
        address,
        area,
        city,
        businessCategory,
        businessType,
        customBusinessType,
        isActive,
        languagePreference,
        maxDevices,
        createdAt,
        updatedAt,
      ];
}
