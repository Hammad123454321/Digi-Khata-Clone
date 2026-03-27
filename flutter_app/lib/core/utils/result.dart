import 'package:equatable/equatable.dart';
import '../errors/failures.dart';

/// Result class for handling success/failure states
sealed class Result<T> extends Equatable {
  const Result();

  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = FailureResult<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  T? get dataOrNull => isSuccess ? (this as Success<T>).data : null;
  Failure? get failureOrNull =>
      isFailure ? (this as FailureResult<T>).failure : null;

  Result<R> map<R>(R Function(T) mapper) {
    return switch (this) {
      Success<T>(:final data) => Result.success(mapper(data)),
      FailureResult<T>(:final failure) => Result.failure(failure),
    };
  }

  Result<R> flatMap<R>(Result<R> Function(T) mapper) {
    return switch (this) {
      Success<T>(:final data) => mapper(data),
      FailureResult<T>(:final failure) => Result.failure(failure),
    };
  }

  @override
  List<Object?> get props => [];
}

class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;

  @override
  List<Object?> get props => [data];
}

class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
