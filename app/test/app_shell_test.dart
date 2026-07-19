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

    // Net worth section, seeded accounts and recent activity render.
    expect(find.text('Net worth'), findsOneWidget);
    expect(find.text('Lumen Current'), findsOneWidget);
    expect(find.text('Rainy Day'), findsOneWidget);
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
    expect(find.text('Mercadona'), findsNothing);
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
