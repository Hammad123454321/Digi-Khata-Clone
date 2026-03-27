import 'package:equatable/equatable.dart';
import '../../../shared/models/staff_model.dart';

/// Staff States
abstract class StaffState extends Equatable {
  const StaffState();

  @override
  List<Object?> get props => [];
}

class StaffInitial extends StaffState {
  const StaffInitial();
}

class StaffLoading extends StaffState {
  const StaffLoading();
}

class StaffLoaded extends StaffState {
  const StaffLoaded({
    required this.staff,
    this.hasMore = false,
  });

  final List<StaffModel> staff;
  final bool hasMore;

  @override
  List<Object?> get props => [staff, hasMore];
}

class StaffCreated extends StaffState {
  const StaffCreated(this.staffMember);

  final StaffModel staffMember;

  @override
  List<Object?> get props => [staffMember];
}

class SalaryRecorded extends StaffState {
  const SalaryRecorded();
}

class StaffError extends StaffState {
  const StaffError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
