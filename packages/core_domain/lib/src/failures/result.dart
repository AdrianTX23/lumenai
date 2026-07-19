import 'package:core_domain/src/failures/failure.dart';

/// The outcome of a domain operation: either [Ok] with a value or [Err]
/// with a [Failure]. Commands in use cases return `Result` instead of
/// throwing — exceptions never cross the domain boundary.
sealed class Result<T> {
  const Result();

  /// Wraps a successful [value].
  const factory Result.ok(T value) = Ok<T>;

  /// Wraps a [failure].
  const factory Result.err(Failure failure) = Err<T>;

  /// Whether this is an [Ok].
  bool get isOk => this is Ok<T>;

  /// Whether this is an [Err].
  bool get isErr => this is Err<T>;

  /// Collapses both cases into a single value.
  R fold<R>({
    required R Function(T value) onOk,
    required R Function(Failure failure) onErr,
  }) =>
      switch (this) {
        Ok<T>(:final value) => onOk(value),
        Err<T>(:final failure) => onErr(failure),
      };

  /// Transforms the success value, passing failures through unchanged.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
        Ok<T>(:final value) => Result.ok(transform(value)),
        Err<T>(:final failure) => Result.err(failure),
      };

  /// Returns the success value, or [orElse] computed from the failure.
  T getOrElse(T Function(Failure failure) orElse) => switch (this) {
        Ok<T>(:final value) => value,
        Err<T>(:final failure) => orElse(failure),
      };
}

/// Successful [Result] carrying [value].
final class Ok<T> extends Result<T> {
  /// Creates a successful result wrapping [value].
  const Ok(this.value);

  /// The success value.
  final T value;
}

/// Failed [Result] carrying [failure].
final class Err<T> extends Result<T> {
  /// Creates a failed result wrapping [failure].
  const Err(this.failure);

  /// The domain failure describing what went wrong.
  final Failure failure;
}
