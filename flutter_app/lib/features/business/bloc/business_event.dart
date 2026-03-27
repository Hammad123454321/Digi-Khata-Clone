import 'package:equatable/equatable.dart';

/// Business Events
abstract class BusinessEvent extends Equatable {
  const BusinessEvent();

  @override
  List<Object?> get props => [];
}

class LoadBusinesses extends BusinessEvent {
  const LoadBusinesses();
}

class CreateBusiness extends BusinessEvent {
  const CreateBusiness({
    required this.name,
    required this.phone,
    this.ownerName,
    this.email,
    this.address,
    this.area,
    this.city,
    this.businessCategory,
    required this.businessType,
    this.customBusinessType,
    this.languagePreference,
    this.maxDevices = 3,
  });

  final String name;
  final String phone;
  final String? ownerName;
  final String? email;
  final String? address;
  final String? area;
  final String? city;
  final String? businessCategory;
  final String businessType;
  final String? customBusinessType;
  final String? languagePreference;
  final int maxDevices;

  @override
  List<Object?> get props => [
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
        languagePreference,
        maxDevices,
      ];
}

class SetDefaultBusiness extends BusinessEvent {
  const SetDefaultBusiness(this.businessId);

  final String businessId;

  @override
  List<Object?> get props => [businessId];
}

class SwitchBusiness extends BusinessEvent {
  const SwitchBusiness(this.businessId);

  final String businessId;

  @override
  List<Object?> get props => [businessId];
}

class SetCurrentBusiness extends BusinessEvent {
  const SetCurrentBusiness(this.businessId);

  final String businessId;

  @override
  List<Object?> get props => [businessId];
}
