import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/local_storage_service.dart';

// Events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class LoadSavedTheme extends ThemeEvent {
  const LoadSavedTheme();
}

class ChangeTheme extends ThemeEvent {
  const ChangeTheme(this.themeMode);

  final ThemeMode themeMode;

  @override
  List<Object?> get props => [themeMode];
}

// State
class ThemeState extends Equatable {
  const ThemeState({required this.themeMode});

  final ThemeMode themeMode;

  @override
  List<Object?> get props => [themeMode];

  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(themeMode: themeMode ?? this.themeMode);
  }
}

// BLoC
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc({required LocalStorageService localStorageService})
      : _localStorageService = localStorageService,
        super(const ThemeState(themeMode: ThemeMode.system)) {
    on<LoadSavedTheme>(_onLoadSavedTheme);
    on<ChangeTheme>(_onChangeTheme);
  }

  final LocalStorageService _localStorageService;

  Future<void> _onLoadSavedTheme(
    LoadSavedTheme event,
    Emitter<ThemeState> emit,
  ) async {
    final themeModeString = _localStorageService.getThemeMode() ?? 'system';
    emit(state.copyWith(themeMode: _mapStringToThemeMode(themeModeString)));
  }

  Future<void> _onChangeTheme(
    ChangeTheme event,
    Emitter<ThemeState> emit,
  ) async {
    final themeModeString = _mapThemeModeToString(event.themeMode);
    await _localStorageService.saveThemeMode(themeModeString);
    emit(state.copyWith(themeMode: event.themeMode));
  }

  ThemeMode _mapStringToThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _mapThemeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }
}
