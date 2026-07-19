import 'package:core_domain/core_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('ok exposes value and state flags', () {
      const result = Result.ok(42);

      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
      expect((result as Ok<int>).value, 42);
    });

    test('err exposes failure and state flags', () {
      const result = Result<int>.err(StorageFailure('disk full'));

      expect(result.isOk, isFalse);
      expect(result.isErr, isTrue);
      expect((result as Err<int>).failure, isA<StorageFailure>());
    });

    test('fold collapses both branches', () {
      const ok = Result.ok(2);
      const err = Result<int>.err(NetworkFailure('offline'));

      expect(ok.fold(onOk: (v) => v * 10, onErr: (_) => -1), 20);
      expect(err.fold(onOk: (v) => v * 10, onErr: (_) => -1), -1);
    });

    test('map transforms only the success branch', () {
      const ok = Result.ok(3);
      const err = Result<int>.err(AiFailure('stream interrupted'));

      expect(ok.map((v) => 'v$v').getOrElse((_) => 'fallback'), 'v3');
      expect(err.map((v) => 'v$v').getOrElse((_) => 'fallback'), 'fallback');
      expect(
        err.map((v) => 'v$v'),
        isA<Err<String>>().having(
          (e) => e.failure,
          'failure',
          isA<AiFailure>(),
        ),
      );
    });

    test('getOrElse receives the failure', () {
      const err = Result<String>.err(ValidationFailure('limit must be > 0'));

      expect(err.getOrElse((f) => f.message), 'limit must be > 0');
    });

    test('exhaustive switch over the sealed type compiles and matches', () {
      const results = <Result<int>>[
        Result.ok(1),
        Result.err(UnexpectedFailure('boom')),
      ];

      final labels = results
          .map(
            (r) => switch (r) {
              Ok<int>() => 'ok',
              Err<int>() => 'err',
            },
          )
          .toList();

      expect(labels, ['ok', 'err']);
    });
  });

  group('Failure', () {
    test('toString includes type and message for log readability', () {
      const failure = StorageFailure('migration v2 failed');

      expect(failure.toString(), 'StorageFailure(migration v2 failed)');
    });
  });
}
