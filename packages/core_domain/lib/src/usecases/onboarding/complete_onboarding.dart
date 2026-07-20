import 'package:core_domain/src/repositories/onboarding_repository.dart';

/// Marks the first-run onboarding flow as completed.
final class CompleteOnboarding {
  /// Creates the use case.
  const CompleteOnboarding(this._onboarding);

  final OnboardingRepository _onboarding;

  /// Records completion.
  Future<void> call() => _onboarding.markCompleted();
}
