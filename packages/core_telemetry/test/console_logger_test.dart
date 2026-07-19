import 'package:core_telemetry/core_telemetry.dart';
import 'package:test/test.dart';

void main() {
  group('ConsoleLogger', () {
    late List<String> lines;
    late ConsoleLogger logger;

    setUp(() {
      lines = [];
      logger = ConsoleLogger(
        sink: lines.add,
        clock: () => DateTime.utc(2026, 7, 18, 12),
      );
    });

    test('writes timestamp, level and message', () {
      logger.log(LogLevel.info, 'seeded demo data');

      expect(lines, hasLength(1));
      expect(lines.first, '2026-07-18T12:00:00.000Z INFO    seeded demo data');
    });

    test('appends error object when provided', () {
      logger.log(LogLevel.error, 'query failed', error: 'disk full');

      expect(lines.single, contains('ERROR'));
      expect(lines.single, endsWith('| error: disk full'));
    });

    test('convenience methods delegate with the right level', () {
      logger
        ..debug('d')
        ..info('i')
        ..warning('w', error: 'e1')
        ..error('x', error: 'e2');

      expect(lines, hasLength(4));
      expect(lines[0], contains('DEBUG'));
      expect(lines[1], contains('INFO'));
      expect(lines[2], allOf(contains('WARNING'), contains('e1')));
      expect(lines[3], allOf(contains('ERROR'), contains('e2')));
    });

    test('emits stack trace on its own line', () {
      logger.log(
        LogLevel.error,
        'boom',
        error: 'x',
        stackTrace: StackTrace.fromString('#0 main (main.dart:1)'),
      );

      expect(lines, hasLength(2));
      expect(lines.last, '#0 main (main.dart:1)');
    });
  });
}
