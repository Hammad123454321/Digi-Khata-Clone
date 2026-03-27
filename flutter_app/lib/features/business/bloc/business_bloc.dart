import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/result.dart';
import '../../../data/repositories/business_repository.dart';
import '../../../shared/models/business_model.dart';
import 'business_event.dart';
import 'business_state.dart';

/// Business BLoC
class BusinessBloc extends Bloc<BusinessEvent, BusinessState> {
  BusinessBloc({
    required BusinessRepository businessRepository,
  })  : _businessRepository = businessRepository,
        super(const BusinessInitial()) {
    on<LoadBusinesses>(_onLoadBusinesses);
    on<CreateBusiness>(_onCreateBusiness);
    on<SwitchBusiness>(_onSwitchBusiness);
    on<SetCurrentBusiness>(_onSetCurrentBusiness);
    on<SetDefaultBusiness>(_onSetDefaultBusiness);
  }

  final BusinessRepository _businessRepository;

  Future<void> _onLoadBusinesses(
    LoadBusinesses event,
    Emitter<BusinessState> emit,
  ) async {
    // Preserve current business ID from state before emitting loading
    String? preservedCurrentId;
    if (state is BusinessLoaded) {
      preservedCurrentId = (state as BusinessLoaded).currentBusinessId;
    }

    emit(const BusinessLoading());

    final result = await _businessRepository.getBusinesses();
    switch (result) {
      case Success(:final data):
        final businesses = data;
        String? currentId = await _businessRepository.getCurrentBusinessId();

        // If no current business ID from storage, use preserved from state or first business
        if (currentId == null) {
          if (preservedCurrentId != null &&
              businesses.any((b) => b.id == preservedCurrentId)) {
            currentId = preservedCurrentId;
          } else if (businesses.isNotEmpty) {
            currentId = businesses.first.id;
          }
          if (currentId != null) {
            await _businessRepository.setCurrentBusinessId(currentId);
          }
        }

        if (currentId != null) {
          final selected = businesses.firstWhere(
            (b) => b.id == currentId,
            orElse: () => businesses.first,
          );
          await _businessRepository.cacheSelectedBusiness(
            id: selected.id,
            name: selected.name,
          );
        }

        emit(BusinessLoaded(
          businesses: businesses,
          currentBusinessId: currentId,
        ));
      case FailureResult(:final failure):
        emit(BusinessError(failure.message ?? 'Failed to load businesses'));
    }
  }

  Future<void> _onCreateBusiness(
    CreateBusiness event,
    Emitter<BusinessState> emit,
  ) async {
    emit(const BusinessLoading());

    final result = await _businessRepository.createBusiness(
      name: event.name,
      phone: event.phone,
      ownerName: event.ownerName,
      email: event.email,
      address: event.address,
      area: event.area,
      city: event.city,
      businessCategory: event.businessCategory,
      businessType: event.businessType,
      customBusinessType: event.customBusinessType,
      languagePreference: event.languagePreference,
      maxDevices: event.maxDevices,
    );

    switch (result) {
      case Success(:final data):
        // Persist new current business ID
        await _businessRepository.setCurrentBusinessId(data.id);
        await _businessRepository.cacheSelectedBusiness(
          id: data.id,
          name: data.name,
        );
        // Reload full list to keep state in sync
        final loadResult = await _businessRepository.getBusinesses();
        if (loadResult is Success<List<BusinessModel>>) {
          final businesses = loadResult.data;
          emit(BusinessLoaded(
            businesses: businesses,
            currentBusinessId: data.id,
          ));
        } else if (loadResult is FailureResult<List<BusinessModel>>) {
          final failure = loadResult.failure;
          emit(BusinessError(
            failure.message ?? 'Business created but failed to refresh list',
          ));
        }
      case FailureResult(:final failure):
        emit(BusinessError(failure.message ?? 'Failed to create business'));
    }
  }

  Future<void> _onSwitchBusiness(
    SwitchBusiness event,
    Emitter<BusinessState> emit,
  ) async {
    await _businessRepository.setCurrentBusinessId(event.businessId);

    if (state is BusinessLoaded) {
      final current = state as BusinessLoaded;
      final selected = current.businesses.firstWhere(
        (b) => b.id == event.businessId,
        orElse: () => current.businesses.first,
      );
      await _businessRepository.cacheSelectedBusiness(
        id: selected.id,
        name: selected.name,
      );
      emit(current.copyWith(currentBusinessId: event.businessId));
    } else {
      // If we don't have businesses loaded yet, just emit loading and reload
      add(const LoadBusinesses());
    }
  }

  Future<void> _onSetCurrentBusiness(
    SetCurrentBusiness event,
    Emitter<BusinessState> emit,
  ) async {
    await _businessRepository.setCurrentBusinessId(event.businessId);
    // Update state if we have businesses loaded, otherwise state will be updated when businesses load
    if (state is BusinessLoaded) {
      final current = state as BusinessLoaded;
      final selected = current.businesses.firstWhere(
        (b) => b.id == event.businessId,
        orElse: () => current.businesses.first,
      );
      await _businessRepository.cacheSelectedBusiness(
        id: selected.id,
        name: selected.name,
      );
      emit(current.copyWith(currentBusinessId: event.businessId));
    } else if (state is BusinessInitial || state is BusinessLoading) {
      // If we're loading or initial, the currentBusinessId will be set when LoadBusinesses completes
      // Just save it to storage (already done above) and wait for LoadBusinesses
    }
  }

  Future<void> _onSetDefaultBusiness(
    SetDefaultBusiness event,
    Emitter<BusinessState> emit,
  ) async {
    final result =
        await _businessRepository.setDefaultBusiness(event.businessId);
    switch (result) {
      case Success():
        // Reload businesses to get updated default
        add(const LoadBusinesses());
      case FailureResult(:final failure):
        if (state is BusinessLoaded) {
          emit(BusinessError(
              failure.message ?? 'Failed to set default business'));
        }
    }
  }
}
