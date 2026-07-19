import 'package:core_telemetry/src/logger.dart';

/// Development [Logger] that writes structured lines to an output sink.
///
/// The sink is injectable so tests can capture output and the composition
/// root can route it (stdout in dev, silenced in release).
class ConsoleLogger extends Logger {
  /// Creates a console logger writing through [sink] and timestamping
  /// entries with [clock].
  ConsoleLogger({
    void Function(String line)? sink,
    DateTime Function()? clock,
  })  : _sink = sink ?? print,
        _clock = clock ?? DateTime.now;

  final void Function(String line) _sink;
  final DateTime Function() _clock;

  @override
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final timestamp = _clock().toIso8601String();
    final label = level.name.toUpperCase().padRight(7);
    final buffer = StringBuffer('$timestamp $label $message');
    if (error != null) {
      buffer.write(' | error: $error');
    }
    _sink(buffer.toString());
    if (stackTrace != null) {
      _sink(stackTrace.toString());
    }
  }
}
