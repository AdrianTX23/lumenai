import 'package:core_domain/src/repositories/onboarding_repository.dart';

/// Whether the first-run onboarding flow has already been completed.
final class IsOnboardingCompleted {
  /// Creates the use case.
  const IsOnboardingCompleted(this._onboarding);

  final OnboardingRepository _onboarding;

  /// Checks completion.
  Future<bool> call() => _onboarding.isCompleted();
}
