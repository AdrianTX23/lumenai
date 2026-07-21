import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_app/app.dart';

import 'helpers/test_harness.dart';

void main() {
  testWidgets('boots into home showing seeded wallet data', (tester) async {
    final container = await seededTestContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const LumenApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Net worth section and seeded accounts render above the fold.
    expect(find.text('Net worth'), findsOneWidget);
    expect(find.text('Bancolombia'), findsOneWidget);
    expect(find.text('Nequi'), findsOneWidget);

    // Home is a single ListView taller than the viewport — the about
    // banner pushes recent activity below the fold, so the sliver only
    // mounts it once scrolled into view.
    await tester.scrollUntilVisible(
      find.text('Recent activity'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Recent activity'), findsOneWidget);
  });

  testWidgets('activity tab searches the seeded feed', (tester) async {
    final container = await seededTestContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const LumenApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Activity'));
    await tester.pumpAndSettle();

    // Unfiltered feed shows many merchants; search narrows to Netflix.
    await tester.enterText(
      find.byType(TextField).first,
      'netflix',
    );
    await tester.pumpAndSettle();

    expect(find.text('Netflix'), findsWidgets);
    expect(find.text('Carulla'), findsNothing);
  });

  testWidgets('tapping a transaction opens the detail sheet', (tester) async {
    final container = await seededTestContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const LumenApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Activity'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'netflix');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Netflix').first);
    await tester.pumpAndSettle();

    expect(find.text('Change category'), findsOneWidget);
  });
}
