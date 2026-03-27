import 'package:equatable/equatable.dart';

/// Staff Events
abstract class StaffEvent extends Equatable {
  const StaffEvent();

  @override
  List<Object?> get props => [];
}

class CreateStaffEvent extends StaffEvent {
  const CreateStaffEvent({
    required this.name,
    this.phone,
    this.email,
    this.role,
    this.address,
  });

  final String name;
  final String? phone;
  final String? email;
  final String? role;
  final String? address;

  @override
  List<Object?> get props => [name, phone, email, role, address];
}

class LoadStaffEvent extends StaffEvent {
  const LoadStaffEvent({
    this.isActive,
    this.search,
    this.refresh = false,
  });

  final bool? isActive;
  final String? search;
  final bool refresh;

  @override
  List<Object?> get props => [isActive, search, refresh];
}

class RecordSalaryEvent extends StaffEvent {
  const RecordSalaryEvent({
    required this.staffId,
    required this.amount,
    required this.date,
    required this.paymentMode,
    this.remarks,
  });

  final String staffId;
  final String amount;
  final DateTime date;
  final String paymentMode;
  final String? remarks;

  @override
  List<Object?> get props => [staffId, amount, date, paymentMode, remarks];
}
