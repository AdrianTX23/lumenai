import 'package:lumen_app/bootstrap.dart';
import 'package:lumen_app/di/app_flavor.dart';

/// Development entrypoint: seeded database, mock copilot, verbose logging.
void main() => bootstrap(AppFlavor.dev);
