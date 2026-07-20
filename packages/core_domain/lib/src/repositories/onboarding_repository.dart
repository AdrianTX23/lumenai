/// Port: whether the user has completed the first-run onboarding flow.
abstract interface class OnboardingRepository {
  /// Whether onboarding has already been completed on this install.
  Future<bool> isCompleted();

  /// Marks onboarding as completed.
  Future<void> markCompleted();
}
