import 'package:lumen_app/bootstrap.dart';
import 'package:lumen_app/di/app_flavor.dart';

/// Production entrypoint: encrypted storage, real AI proxy, quiet logging.
void main() => bootstrap(AppFlavor.prod);
