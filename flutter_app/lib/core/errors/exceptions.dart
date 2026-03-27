/// Base Exception class
abstract class AppException implements Exception {
  const AppException([this.message]);

  final String? message;

  @override
  String toString() => message ?? runtimeType.toString();
}

/// Network exceptions
class NetworkException extends AppException {
  const NetworkException([super.message]);
}

class ServerException extends AppException {
  const ServerException([super.message, this.statusCode]);

  final int? statusCode;
}

class TimeoutException extends AppException {
  const TimeoutException([super.message]);
}

/// Authentication exceptions
class AuthenticationException extends AppException {
  const AuthenticationException([super.message]);
}

class AuthorizationException extends AppException {
  const AuthorizationException([super.message]);
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException([super.message, this.errors]);

  final Map<String, List<String>>? errors;
}

/// Storage exceptions
class StorageException extends AppException {
  const StorageException([super.message]);
}

/// Sync exceptions
class SyncException extends AppException {
  const SyncException([super.message]);
}
