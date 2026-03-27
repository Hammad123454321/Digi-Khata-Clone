import 'package:equatable/equatable.dart';

/// Base Failure class
abstract class Failure extends Equatable {
  const Failure([this.message]);

  final String? message;

  @override
  List<Object?> get props => [message];
}

/// Network related failures
class NetworkFailure extends Failure {
  const NetworkFailure([super.message]);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message]);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message]);
}

/// Authentication failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure([super.message]);
}

class AuthorizationFailure extends Failure {
  const AuthorizationFailure([super.message]);
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure([super.message, this.errors]);

  final Map<String, List<String>>? errors;

  @override
  List<Object?> get props => [message, errors];
}

/// Business logic failures
class BusinessLogicFailure extends Failure {
  const BusinessLogicFailure([super.message]);
}

/// Storage failures
class StorageFailure extends Failure {
  const StorageFailure([super.message]);
}

/// Sync failures
class SyncFailure extends Failure {
  const SyncFailure([super.message]);
}

class ConflictFailure extends Failure {
  const ConflictFailure([super.message, this.conflicts]);

  final List<dynamic>? conflicts;

  @override
  List<Object?> get props => [message, conflicts];
}

/// Unknown/Generic failures
class UnknownFailure extends Failure {
  const UnknownFailure([super.message]);
}
