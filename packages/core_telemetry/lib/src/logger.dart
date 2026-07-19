/// Severity levels, ordered from most verbose to most severe.
enum LogLevel {
  /// Fine-grained diagnostic detail, stripped from release builds.
  debug,

  /// Notable application events (navigation, seeding, sync milestones).
  info,

  /// Something unexpected but recovered from.
  warning,

  /// A failure that affected the user or lost work.
  error,
}

/// Logging port. Consumers depend on this interface only; adapters
/// (console in dev, vendor SDKs later) are bound in the composition root.
abstract class Logger {
  /// Const base constructor for subclasses.
  const Logger();

  /// Records [message] at [level], optionally attaching the [error] object
  /// and its [stackTrace] for error-level entries.
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  });

  /// Fine-grained diagnostic entry.
  void debug(String message) => log(LogLevel.debug, message);

  /// Notable application event.
  void info(String message) => log(LogLevel.info, message);

  /// Unexpected but recovered situation.
  void warning(String message, {Object? error}) =>
      log(LogLevel.warning, message, error: error);

  /// Failure that affected the user or lost work.
  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      log(LogLevel.error, message, error: error, stackTrace: stackTrace);
}
