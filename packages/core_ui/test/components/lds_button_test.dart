import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
      theme: buildLdsDarkTheme(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('fires onPressed when tapped', (tester) async {
    var pressed = 0;
    await tester.pumpWidget(
      _host(LdsButton(label: 'Go', onPressed: () => pressed++)),
    );

    await tester.tap(find.text('Go'));
    expect(pressed, 1);
  });

  testWidgets('suppresses taps while loading and shows spinner',
      (tester) async {
    var pressed = 0;
    await tester.pumpWidget(
      _host(
        LdsButton(label: 'Go', onPressed: () => pressed++, loading: true),
      ),
    );
    await tester.pump(LdsMotion.fast);

    expect(find.byKey(const ValueKey('lds-button-spinner')), findsOneWidget);
    await tester.tap(find.byType(LdsButton), warnIfMissed: false);
    expect(pressed, 0);
  });

  testWidgets('null onPressed renders disabled and ignores taps',
      (tester) async {
    await tester.pumpWidget(
      _host(const LdsButton(label: 'Go', onPressed: null)),
    );

    await tester.tap(find.text('Go'), warnIfMissed: false);
    // No exception, no state change; the ink well has no handler.
    final ink = tester.widget<InkWell>(find.byType(InkWell));
    expect(ink.onTap, isNull);
  });
}
