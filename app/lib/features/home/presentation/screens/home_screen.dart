import 'package:core_ui/core_ui.dart';
import 'package:flutter/widgets.dart';

/// Placeholder home screen — proves the shell (router, DI, theme) works.
/// Replaced in Phase 3 by the real wallet home (net worth hero, card
/// stack, recent activity).
class HomeScreen extends StatelessWidget {
  /// Creates the placeholder home screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    return LdsScaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'LUMEN AI',
              style: lds.typography.title.copyWith(letterSpacing: 4),
            ),
            const SizedBox(height: LdsSpacing.xs),
            Text('Design system online', style: lds.typography.bodyMuted),
            const SizedBox(height: LdsSpacing.xl),
            const AmountText(
              1224065,
              currencyCode: 'EUR',
              emphasis: AmountEmphasis.hero,
              colored: false,
            ),
          ],
        ),
      ),
    );
  }
}
