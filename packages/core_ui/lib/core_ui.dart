/// LUMEN Design System (LDS).
///
/// Token architecture (primitive → semantic → component), theme assembly,
/// component library and chart painters. See `docs/03-design-system.md`.
///
/// No file in this package may import business logic or data access —
/// enforced by package boundaries. Components receive plain display data.
library;

export 'src/charts/budget_pace_bar.dart';
export 'src/charts/cashflow_bars.dart';
export 'src/charts/spend_donut.dart';
export 'src/components/actions/lds_button.dart';
export 'src/components/actions/lds_search_field.dart';
export 'src/components/copilot/chat_bubble.dart';
export 'src/components/copilot/insight_card.dart';
export 'src/components/copilot/prompt_suggestion_chip.dart';
export 'src/components/display/amount_text.dart';
export 'src/components/display/animated_amount.dart';
export 'src/components/display/category_chip.dart';
export 'src/components/display/lds_avatar.dart';
export 'src/components/display/lds_card.dart';
export 'src/components/display/transaction_tile.dart';
export 'src/components/display/trend_badge.dart';
export 'src/components/feedback/lds_sheet.dart';
export 'src/components/feedback/lds_skeleton.dart';
export 'src/components/feedback/lds_snack.dart';
export 'src/components/feedback/lds_status_views.dart';
export 'src/components/navigation/lds_bottom_bar.dart';
export 'src/components/wallet/card_stack.dart';
export 'src/components/wallet/payment_card.dart';
export 'src/foundations/lds_scaffold.dart';
export 'src/theme/lds_theme.dart';
export 'src/tokens/lds_colors.dart';
export 'src/tokens/lds_motion.dart';
export 'src/tokens/lds_spacing.dart';
export 'src/tokens/lds_typography.dart';
export 'src/utils/lds_haptics.dart';
export 'src/utils/lds_money_format.dart';
