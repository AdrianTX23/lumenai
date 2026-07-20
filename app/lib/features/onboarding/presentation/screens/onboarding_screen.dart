import 'dart:async';

import 'package:core_l10n/core_l10n.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:lumen_app/router/app_gate_controller.dart';

/// First-run value-proposition carousel plus a biometric-lock opt-in,
/// per docs/01-product-vision.md's onboarding scope. Demo data itself
/// is already seeding in the background from `bootstrap.dart` the
/// moment the app starts, so this flow only needs to cover the
/// value-prop and security steps.
class OnboardingScreen extends ConsumerStatefulWidget {
  /// Creates the onboarding screen.
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  static const _pageCount = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    unawaited(
      _pageController.animateToPage(
        index,
        duration: LdsMotion.standard,
        curve: Curves.easeOut,
      ),
    );
  }

  Future<void> _finish() async {
    final l10n = context.l10n;
    final ok = await ref
        .read(onboardingControllerProvider.notifier)
        .finish(biometricReason: l10n.onboardingBiometricReason);
    if (!mounted) return;
    if (ok) {
      ref.read(appGateControllerProvider.notifier).finishOnboarding();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.lockFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lds = context.lds;
    final state = ref.watch(onboardingControllerProvider);
    final isLastPage = state.pageIndex == _pageCount - 1;

    return LdsScaffold(
      body: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(LdsSpacing.md),
              child: Opacity(
                opacity: isLastPage ? 0 : 1,
                child: LdsButton(
                  label: l10n.onboardingSkip,
                  variant: LdsButtonVariant.ghost,
                  size: LdsButtonSize.small,
                  onPressed:
                      isLastPage ? null : () => _goToPage(_pageCount - 1),
                ),
              ),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => ref
                  .read(onboardingControllerProvider.notifier)
                  .goToPage(index),
              children: [
                _ValuePropPage(
                  icon: Icons.account_balance_wallet_rounded,
                  title: l10n.onboardingPage1Title,
                  body: l10n.onboardingPage1Body,
                ),
                _ValuePropPage(
                  icon: Icons.insights_rounded,
                  title: l10n.onboardingPage2Title,
                  body: l10n.onboardingPage2Body,
                ),
                _ValuePropPage(
                  icon: Icons.auto_awesome_rounded,
                  title: l10n.onboardingPage3Title,
                  body: l10n.onboardingPage3Body,
                ),
                _SecurityPage(state: state),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(LdsSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _pageCount; i++)
                  AnimatedContainer(
                    duration: LdsMotion.fast,
                    margin: const EdgeInsets.symmetric(
                      horizontal: LdsSpacing.xxs,
                    ),
                    width: i == state.pageIndex ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == state.pageIndex
                          ? lds.colors.accent
                          : lds.colors.borderSubtle,
                      borderRadius: BorderRadius.circular(LdsRadius.full),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              LdsSpacing.md,
              0,
              LdsSpacing.md,
              LdsSpacing.lg,
            ),
            child: LdsButton(
              label:
                  isLastPage ? l10n.onboardingGetStarted : l10n.onboardingNext,
              expand: true,
              size: LdsButtonSize.large,
              loading: state.isSaving,
              onPressed:
                  isLastPage ? _finish : () => _goToPage(state.pageIndex + 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValuePropPage extends StatelessWidget {
  const _ValuePropPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LdsSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: lds.colors.accent),
            const SizedBox(height: LdsSpacing.lg),
            Text(
              title,
              style: lds.typography.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: LdsSpacing.xs),
            Text(
              body,
              style: lds.typography.bodyMuted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityPage extends ConsumerWidget {
  const _SecurityPage({required this.state});

  final OnboardingUiState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lds = context.lds;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LdsSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fingerprint_rounded,
              size: 56,
              color: lds.colors.accent,
            ),
            const SizedBox(height: LdsSpacing.lg),
            Text(
              l10n.onboardingSecurityTitle,
              style: lds.typography.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: LdsSpacing.xs),
            Text(
              l10n.onboardingSecurityBody,
              style: lds.typography.bodyMuted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: LdsSpacing.xl),
            if (!state.biometricAvailable)
              Text(
                l10n.onboardingBiometricUnavailable,
                style: lds.typography.caption,
                textAlign: TextAlign.center,
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: LdsSpacing.md,
                  vertical: LdsSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: lds.colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(LdsRadius.lg),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.onboardingEnableBiometrics,
                        style: lds.typography.body,
                      ),
                    ),
                    Semantics(
                      label: l10n.onboardingEnableBiometrics,
                      toggled: state.lockEnabled,
                      child: Switch(
                        value: state.lockEnabled,
                        activeColor: lds.colors.accent,
                        onChanged: (enabled) => ref
                            .read(onboardingControllerProvider.notifier)
                            .setLockEnabled(enabled: enabled),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
