import 'dart:async';

import 'package:core_l10n/core_l10n.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen_app/di/di.dart';
import 'package:lumen_app/router/app_gate_controller.dart';

/// Blocks the app behind a biometric prompt whenever
/// [AppGateController] reports [AppGateNeedsUnlock] — first launch with
/// app-lock on, or resuming from background past the re-lock threshold.
class LockScreen extends ConsumerStatefulWidget {
  /// Creates the lock screen.
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  bool _authenticating = false;
  bool _lastAttemptFailed = false;

  @override
  void initState() {
    super.initState();
    // Prompt immediately on arrival — the manual button below is the
    // fallback if the user dismisses this or it fails.
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_unlock()));
  }

  Future<void> _unlock() async {
    if (_authenticating) return;
    setState(() {
      _authenticating = true;
      _lastAttemptFailed = false;
    });

    final l10n = context.l10n;
    final result = await ref.read(authenticateWithAppLockProvider)(
      reason: l10n.lockReason,
    );
    if (!mounted) return;

    setState(() => _authenticating = false);
    if (result.isOk) {
      ref.read(appGateControllerProvider.notifier).unlock();
    } else {
      setState(() => _lastAttemptFailed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lds = context.lds;

    return LdsScaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(LdsSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_rounded, size: 56, color: lds.colors.accent),
              const SizedBox(height: LdsSpacing.lg),
              Text(
                l10n.lockTitle,
                style: lds.typography.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: LdsSpacing.xs),
              Text(
                l10n.lockSubtitle,
                style: lds.typography.bodyMuted,
                textAlign: TextAlign.center,
              ),
              if (_lastAttemptFailed) ...[
                const SizedBox(height: LdsSpacing.md),
                Text(
                  l10n.lockFailed,
                  style: lds.typography.caption.copyWith(
                    color: lds.colors.negative,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: LdsSpacing.xl),
              LdsButton(
                label: l10n.lockUnlockButton,
                icon: Icons.fingerprint_rounded,
                loading: _authenticating,
                onPressed: _unlock,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
