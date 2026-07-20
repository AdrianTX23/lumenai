import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_app/app.dart';

import '../helpers/test_harness.dart';

void main() {
  testWidgets(
    'Insights shows breakdown, cashflow and the planted Netflix increase',
    (tester) async {
      final container = await seededTestContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const LumenApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Insights'));
      await tester.pumpAndSettle();

      expect(find.text('Spending by category'), findsOneWidget);

      // The screen is a single ListView taller than the viewport; the
      // sliver only mounts elements near the visible area, so later
      // sections must be scrolled into view before `find` can see them.
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('Income vs. spend'),
        300,
        scrollable: scrollable,
      );
      expect(find.text('Income vs. spend'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Recurring charges'),
        300,
        scrollable: scrollable,
      );
      expect(find.text('Recurring charges'), findsOneWidget);
      expect(find.text('Next month'), findsOneWidget);

      // The planted price increase surfaces as a recurring charge with a
      // trend badge (Netflix 26.900 → 33.900, ~26%).
      await tester.scrollUntilVisible(
        find.text('Netflix'),
        300,
        scrollable: scrollable,
      );
      expect(find.text('Netflix'), findsOneWidget);
      expect(find.textContaining('▲'), findsWidgets);
    },
  );

  testWidgets('Budgets: empty state, create flow, and pace bar appear',
      (tester) async {
    final container = await seededTestContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const LumenApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Insights'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Budgets'));
    await tester.pumpAndSettle();

    expect(find.text('No budgets yet'), findsOneWidget);

    await tester.tap(find.text('Add budget'));
    await tester.pumpAndSettle();

    expect(find.text('New budget'), findsOneWidget);

    await tester.tap(find.text('Groceries'));
    await tester.enterText(find.byType(TextField), '800000');
    await tester.tap(find.text('Save budget'));
    await tester.pumpAndSettle();

    expect(find.text('Budget saved'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.textContaining('/'), findsWidgets);
  });
}
