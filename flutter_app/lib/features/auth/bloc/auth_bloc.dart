import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../core/utils/result.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../shared/models/auth_response_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<RequestOtpEvent>(_onRequestOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<RefreshTokenEvent>(_onRefreshToken);
    on<SetPinEvent>(_onSetPin);
    on<VerifyPinEvent>(_onVerifyPin);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LogoutEvent>(_onLogout);
  }

  final AuthRepository _authRepository;

  Future<void> _onRequestOtp(
    RequestOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    // Don't emit loading if we're already in OtpRequested state for the same phone
    if (state is OtpRequested && (state as OtpRequested).phone == event.phone) {
      return; // Already requested OTP for this phone
    }

    emit(const AuthLoading());
    try {
      final result = await _authRepository.requestOtp(event.phone);
      switch (result) {
        case Success():
          emit(OtpRequested(event.phone));
        case FailureResult(:final failure):
          emit(AuthError(failure.message ?? 'Failed to send OTP'));
      }
    } catch (e) {
      emit(AuthError('Failed to send OTP: ${e.toString()}'));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await _authRepository.verifyOtp(
        phone: event.phone,
        otp: event.otp,
        deviceId: event.deviceId,
        deviceName: event.deviceName,
      );
      switch (result) {
        case Success(:final data):
          emit(AuthAuthenticated(authResponse: data));
        case FailureResult(:final failure):
          emit(AuthError(failure.message ?? 'Failed to verify OTP'));
      }
    } catch (e) {
      emit(AuthError('Failed to verify OTP: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshToken(
    RefreshTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _authRepository.refreshToken();
    switch (result) {
      case Success():
        emit(const AuthUnauthenticated());
      case FailureResult(:final failure):
        emit(AuthError(failure.message ?? 'Failed to refresh token'));
        emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSetPin(
    SetPinEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _authRepository.setPin(event.pin);
    switch (result) {
      case Success():
        emit(const PinSet());
      case FailureResult(:final failure):
        emit(AuthError(failure.message ?? 'Failed to set PIN'));
    }
  }

  Future<void> _onVerifyPin(
    VerifyPinEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _authRepository.verifyPin(event.pin);
    switch (result) {
      case Success(:final data):
        emit(PinVerified(data));
      case FailureResult(:final failure):
        emit(AuthError(failure.message ?? 'Failed to verify PIN'));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    // Don't emit loading if already in initial state (to avoid double loading)
    if (state is! AuthInitial) {
      emit(const AuthLoading());
    }

    try {
      final isAuthenticated = await _authRepository.isAuthenticated();
      final hasCachedSession = await _authRepository.hasCachedSession();
      if (isAuthenticated) {
        final user = await _authRepository.getCurrentUser();
        // Create a minimal auth response for authenticated state
        if (user != null) {
          emit(
            AuthAuthenticated(
              authResponse: AuthResponseModel(
                accessToken: '',
                refreshToken: '',
                tokenType: 'bearer',
                user: user,
              ),
              user: user,
            ),
          );
        } else {
          emit(const AuthUnauthenticated());
        }
        return;
      }

      if (hasCachedSession) {
        final connectivity = await Connectivity().checkConnectivity();
        final isOnline = connectivity != ConnectivityResult.none;
        if (isOnline) {
          final refreshed = await _authRepository.refreshToken();
          if (refreshed.isFailure) {
            emit(const AuthUnauthenticated());
            return;
          }
        }

        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(
            authResponse: AuthResponseModel(
              accessToken: '',
              refreshToken: '',
              tokenType: 'bearer',
              user: user,
            ),
            user: user,
          ));
        } else {
          emit(const AuthUnauthenticated());
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      // If there's an error checking auth status, assume unauthenticated
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }
}
