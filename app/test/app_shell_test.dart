import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_app/app.dart';
import 'package:lumen_app/di/app_flavor.dart';
import 'package:lumen_app/di/di.dart';

void main() {
  testWidgets('app shell boots into home via the router', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overridesFor(AppFlavor.dev),
        child: const LumenApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('LUMEN AI'), findsOneWidget);
  });

  test('DI overrides expose the flavor', () {
    final container = ProviderContainer(
      overrides: overridesFor(AppFlavor.prod),
    );
    addTearDown(container.dispose);

    expect(container.read(flavorProvider), AppFlavor.prod);
  });
}
