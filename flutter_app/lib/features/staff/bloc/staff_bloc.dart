import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/result.dart';
import '../../../data/repositories/staff_repository.dart';
import 'staff_event.dart';
import 'staff_state.dart';

/// Staff BLoC
class StaffBloc extends Bloc<StaffEvent, StaffState> {
  StaffBloc({
    required StaffRepository staffRepository,
  })  : _staffRepository = staffRepository,
        super(const StaffInitial()) {
    on<CreateStaffEvent>(_onCreateStaff);
    on<LoadStaffEvent>(_onLoadStaff);
    on<RecordSalaryEvent>(_onRecordSalary);
  }

  final StaffRepository _staffRepository;

  Future<void> _onCreateStaff(
    CreateStaffEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(const StaffLoading());
    final result = await _staffRepository.createStaff(
      name: event.name,
      phone: event.phone,
      email: event.email,
      role: event.role,
      address: event.address,
    );

    switch (result) {
      case Success(:final data):
        emit(StaffCreated(data));
      case FailureResult(:final failure):
        emit(StaffError(failure.message ?? 'Failed to create staff'));
    }
  }

  Future<void> _onLoadStaff(
    LoadStaffEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(const StaffLoading());
    final result = await _staffRepository.getStaff(
      isActive: event.isActive,
      search: event.search,
    );

    switch (result) {
      case Success(:final data):
        emit(StaffLoaded(staff: data));
      case FailureResult(:final failure):
        emit(StaffError(failure.message ?? 'Failed to load staff'));
    }
  }

  Future<void> _onRecordSalary(
    RecordSalaryEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(const StaffLoading());
    final result = await _staffRepository.recordSalary(
      staffId: event.staffId,
      amount: event.amount,
      date: event.date,
      paymentMode: event.paymentMode,
      remarks: event.remarks,
    );

    switch (result) {
      case Success():
        emit(const SalaryRecorded());
      case FailureResult(:final failure):
        emit(StaffError(failure.message ?? 'Failed to record salary'));
    }
  }
}
