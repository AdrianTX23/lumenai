import 'package:lumen_app/bootstrap.dart';
import 'package:lumen_app/di/app_flavor.dart';

/// Web entrypoint (portfolio demo): seeded database, mock copilot — same
/// experience as [AppFlavor.dev], so a visitor lands on a populated app
/// instead of an empty ledger. Data lives entirely in that visitor's own
/// browser storage (IndexedDB via `open_database_web.dart`); nothing is
/// synced or backed up centrally, by design (docs/01-product-vision.md —
/// no backend in scope for v1).
void main() => bootstrap(AppFlavor.dev);
