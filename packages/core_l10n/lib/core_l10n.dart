/// LUMEN AI localization package (EN + ES).
///
/// No hardcoded copy is allowed anywhere in the app — every user-facing
/// string resolves through [AppLocalizations]. Add strings to
/// `lib/arb/app_en.arb` + `app_es.arb` and run `flutter gen-l10n`.
library;

import 'package:core_l10n/src/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';

export 'src/generated/app_localizations.dart';

/// Convenience accessor: `context.l10n.homeNetWorth`.
extension AppLocalizationsContext on BuildContext {
  /// The localized strings for the enclosing locale.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
