import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/local_storage_service.dart';

// Events
abstract class LocaleEvent extends Equatable {
  const LocaleEvent();

  @override
  List<Object?> get props => [];
}

class LoadSavedLocale extends LocaleEvent {
  const LoadSavedLocale();
}

class ChangeLocale extends LocaleEvent {
  const ChangeLocale(this.locale);

  final Locale locale;

  @override
  List<Object?> get props => [locale];
}

// State
class LocaleState extends Equatable {
  const LocaleState({required this.locale});

  final Locale locale;

  @override
  List<Object?> get props => [locale];

  LocaleState copyWith({Locale? locale}) {
    return LocaleState(locale: locale ?? this.locale);
  }
}

// BLoC
class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  LocaleBloc({required LocalStorageService localStorageService})
      : _localStorageService = localStorageService,
        super(const LocaleState(locale: Locale('en'))) {
    on<LoadSavedLocale>(_onLoadSavedLocale);
    on<ChangeLocale>(_onChangeLocale);
  }

  final LocalStorageService _localStorageService;

  Future<void> _onLoadSavedLocale(
    LoadSavedLocale event,
    Emitter<LocaleState> emit,
  ) async {
    final languageCode = _localStorageService.getLanguagePreference() ?? 'en';
    emit(state.copyWith(locale: _mapCodeToLocale(languageCode)));
  }

  Future<void> _onChangeLocale(
    ChangeLocale event,
    Emitter<LocaleState> emit,
  ) async {
    await _localStorageService
        .saveLanguagePreference(event.locale.languageCode);
    emit(state.copyWith(locale: event.locale));
  }

  Locale _mapCodeToLocale(String code) {
    switch (code) {
      case 'ur':
        return const Locale('ur', '');
      case 'ar':
        return const Locale('ar', '');
      case 'en':
      default:
        return const Locale('en', '');
    }
  }
}
