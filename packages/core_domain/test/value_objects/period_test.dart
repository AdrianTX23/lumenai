import 'package:core_domain/core_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Period.monthly', () {
    test('default anchor is the calendar month', () {
      final period = Period.monthly(containing: DateTime(2026, 7, 19));

      expect(period.start, DateTime(2026, 7));
      expect(period.end, DateTime(2026, 8));
    });

    test('date before the anchor belongs to the previous window', () {
      final period = Period.monthly(
        containing: DateTime(2026, 7, 10),
        anchorDay: 25,
      );

      expect(period.start, DateTime(2026, 6, 25));
      expect(period.end, DateTime(2026, 7, 25));
    });

    test('date on the anchor starts a new window', () {
      final period = Period.monthly(
        containing: DateTime(2026, 7, 25),
        anchorDay: 25,
      );

      expect(period.start, DateTime(2026, 7, 25));
      expect(period.end, DateTime(2026, 8, 25));
    });

    test('anchor 31 clamps to short months (Feb)', () {
      final period = Period.monthly(
        containing: DateTime(2026, 2, 15),
        anchorDay: 31,
      );

      expect(period.start, DateTime(2026, 1, 31));
      expect(period.end, DateTime(2026, 2, 28));
    });

    test('anchor 31 clamps to leap-year Feb 29', () {
      final period = Period.monthly(
        containing: DateTime(2028, 2, 15),
        anchorDay: 31,
      );

      expect(period.end, DateTime(2028, 2, 29));
    });

    test('year boundary wraps', () {
      final period = Period.monthly(
        containing: DateTime(2026, 1, 5),
        anchorDay: 25,
      );

      expect(period.start, DateTime(2025, 12, 25));
      expect(period.end, DateTime(2026, 1, 25));
    });

    test('invalid anchor throws', () {
      expect(
        () => Period.monthly(containing: DateTime(2026), anchorDay: 0),
        throwsArgumentError,
      );
      expect(
        () => Period.monthly(containing: DateTime(2026), anchorDay: 32),
        throwsArgumentError,
      );
    });
  });

  group('Period navigation', () {
    test('previous/next tile the timeline without gaps', () {
      final period = Period.monthly(
        containing: DateTime(2026, 7, 19),
        anchorDay: 25,
      );

      expect(period.previous.end, period.start);
      expect(period.next.start, period.end);
    });

    test('anchor 31 survives traversal through February', () {
      // Mar window (Feb 28 → Mar 31) for anchor 31.
      final march = Period.monthly(
        containing: DateTime(2026, 3, 15),
        anchorDay: 31,
      );
      expect(march.start, DateTime(2026, 2, 28));
      expect(march.end, DateTime(2026, 3, 31));

      // Going back re-derives the clamped Feb window…
      final february = march.previous;
      expect(february.start, DateTime(2026, 1, 31));
      expect(february.end, DateTime(2026, 2, 28));

      // …and coming forward restores the full 31 anchor, not 28.
      final backToMarch = february.next;
      expect(backToMarch, march);
      expect(backToMarch.next.end, DateTime(2026, 4, 30));
    });

    test('contains is inclusive of start, exclusive of end', () {
      final period = Period.monthly(
        containing: DateTime(2026, 7, 19),
        anchorDay: 25,
      );

      expect(period.contains(period.start), isTrue);
      expect(
        period.contains(period.end.subtract(const Duration(minutes: 1))),
        isTrue,
      );
      expect(period.contains(period.end), isFalse);
    });
  });
}
