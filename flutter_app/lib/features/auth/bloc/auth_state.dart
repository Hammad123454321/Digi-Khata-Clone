import 'package:equatable/equatable.dart';
import '../../../shared/models/auth_response_model.dart';
import '../../../shared/models/user_model.dart';

/// Authentication States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class OtpRequested extends AuthState {
  const OtpRequested(this.phone);

  final String phone;

  @override
  List<Object?> get props => [phone];
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({
    required this.authResponse,
    this.user,
  });

  final AuthResponseModel authResponse;
  final UserModel? user;

  @override
  List<Object?> get props => [authResponse, user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class PinSet extends AuthState {
  const PinSet();
}

class PinVerified extends AuthState {
  const PinVerified(this.isValid);

  final bool isValid;

  @override
  List<Object?> get props => [isValid];
}

class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
