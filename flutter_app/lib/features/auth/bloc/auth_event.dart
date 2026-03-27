import 'package:equatable/equatable.dart';

/// Authentication Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class RequestOtpEvent extends AuthEvent {
  const RequestOtpEvent(this.phone);

  final String phone;

  @override
  List<Object?> get props => [phone];
}

class VerifyOtpEvent extends AuthEvent {
  const VerifyOtpEvent({
    required this.phone,
    required this.otp,
    required this.deviceId,
    this.deviceName,
  });

  final String phone;
  final String otp;
  final String deviceId;
  final String? deviceName;

  @override
  List<Object?> get props => [phone, otp, deviceId, deviceName];
}

class RefreshTokenEvent extends AuthEvent {
  const RefreshTokenEvent();
}

class SetPinEvent extends AuthEvent {
  const SetPinEvent(this.pin);

  final String pin;

  @override
  List<Object?> get props => [pin];
}

class VerifyPinEvent extends AuthEvent {
  const VerifyPinEvent(this.pin);

  final String pin;

  @override
  List<Object?> get props => [pin];
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}
