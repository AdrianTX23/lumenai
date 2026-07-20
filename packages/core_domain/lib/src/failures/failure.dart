/// The sealed hierarchy of domain-level failures.
///
/// Adapters (core_data) catch technology-specific exceptions at the
/// infrastructure boundary and translate them into one of these types.
/// No raw exception may cross into the domain or presentation layers.
sealed class Failure {
  const Failure(this.message);

  /// Developer-facing description. Never shown to users directly —
  /// presentation maps failure types to localized copy.
  final String message;

  /// Stable log label. Hardcoded (not `runtimeType`) so release-mode
  /// obfuscation cannot mangle log output.
  String get label;

  @override
  String toString() => '$label($message)';
}

/// Local persistence failed (read, write, migration, corruption).
final class StorageFailure extends Failure {
  /// Creates a [StorageFailure] with a developer-facing [message].
  const StorageFailure(super.message);

  @override
  String get label => 'StorageFailure';
}

/// A network operation failed (connectivity, timeout, non-2xx response).
final class NetworkFailure extends Failure {
  /// Creates a [NetworkFailure] with a developer-facing [message].
  const NetworkFailure(super.message);

  @override
  String get label => 'NetworkFailure';
}

/// The AI copilot pipeline failed (proxy error, stream interruption,
/// malformed model output).
final class AiFailure extends Failure {
  /// Creates an [AiFailure] with a developer-facing [message].
  const AiFailure(super.message);

  @override
  String get label => 'AiFailure';
}

/// Biometric authentication is unavailable, not enrolled, was cancelled,
/// or did not match.
final class AuthFailure extends Failure {
  /// Creates an [AuthFailure] with a developer-facing [message].
  const AuthFailure(super.message);

  @override
  String get label => 'AuthFailure';
}

/// A business rule rejected the operation (e.g. budget limit must be
/// positive). Carries enough context for presentation to explain why.
final class ValidationFailure extends Failure {
  /// Creates a [ValidationFailure] with a developer-facing [message].
  const ValidationFailure(super.message);

  @override
  String get label => 'ValidationFailure';
}

/// Anything unexpected. Reaching this type in logs means a missing
/// translation at an adapter boundary — treat as a bug.
final class UnexpectedFailure extends Failure {
  /// Creates an [UnexpectedFailure] with a developer-facing [message].
  const UnexpectedFailure(super.message);

  @override
  String get label => 'UnexpectedFailure';
}
