import 'dart:async';

import 'package:core_domain/core_domain.dart';
import 'package:core_l10n/core_l10n.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen_app/common/add_account_sheet.dart';
import 'package:lumen_app/common/theme_mode_controller.dart';
import 'package:lumen_app/di/di.dart';

/// Appearance, security and data controls, per
/// docs/01-product-vision.md's settings scope.
class SettingsScreen extends ConsumerStatefulWidget {
  /// Creates the settings screen.
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool? _biometricAvailable;
  bool _lockEnabled = false;
  bool _resetting = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadSecurityState());
  }

  Future<void> _loadSecurityState() async {
    final available = await ref.read(isBiometricAvailableProvider)();
    final enabled = await ref.read(isAppLockEnabledProvider)();
    if (!mounted) return;
    setState(() {
      _biometricAvailable = available;
      _lockEnabled = enabled;
    });
  }

  Future<void> _setLockEnabled(bool enabled) async {
    final l10n = context.l10n;
    final result = await ref.read(setAppLockEnabledProvider)(
      enabled: enabled,
      reason: l10n.onboardingBiometricReason,
    );
    if (!mounted) return;
    result.fold(
      onOk: (_) => setState(() => _lockEnabled = enabled),
      onErr: (_) {},
    );
  }

  Future<void> _confirmReset() async {
    final l10n = context.l10n;
    final confirmed = await showLdsSheet<bool>(
      context: context,
      builder: (context) => _ResetConfirmationSheet(l10n: l10n),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _resetting = true);
    final result = await ref.read(resetDataProvider)();
    if (!mounted) return;
    setState(() => _resetting = false);
    result.fold(
      onOk: (_) => LdsSnack.show(context, l10n.settingsResetSuccess),
      onErr: (_) => LdsSnack.show(context, l10n.settingsResetFailed),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lds = context.lds;
    final themeMode = ref.watch(themeModeControllerProvider);

    return LdsScaffold(
      body: ListView(
        padding: const EdgeInsets.all(LdsSpacing.md),
        children: [
          Text(l10n.settingsTitle, style: lds.typography.title),
          const SizedBox(height: LdsSpacing.lg),
          _SectionLabel(l10n.settingsAccounts),
          const SizedBox(height: LdsSpacing.xs),
          LdsButton(
            label: l10n.homeAddAccount,
            variant: LdsButtonVariant.secondary,
            icon: Icons.add_rounded,
            expand: true,
            onPressed: () => showAddAccountSheet(context),
          ),
          const SizedBox(height: LdsSpacing.xl),
          _SectionLabel(l10n.settingsAppearance),
          const SizedBox(height: LdsSpacing.xs),
          _AppearanceSelector(
            selected: themeMode,
            onSelected: (mode) => ref
                .read(themeModeControllerProvider.notifier)
                .setThemeMode(mode),
          ),
          Padding(
            padding: const EdgeInsets.only(top: LdsSpacing.xs),
            child: Text(
              l10n.settingsAppearanceCaption,
              style: lds.typography.caption,
            ),
          ),
          const SizedBox(height: LdsSpacing.xl),
          _SectionLabel(l10n.settingsSecurity),
          const SizedBox(height: LdsSpacing.xs),
          if (_biometricAvailable == false)
            Text(
              l10n.settingsBiometricUnavailable,
              style: lds.typography.caption,
            )
          else
            _SettingsRow(
              label: l10n.settingsBiometricLock,
              trailing: Semantics(
                label: l10n.settingsBiometricLock,
                toggled: _lockEnabled,
                child: Switch(
                  value: _lockEnabled,
                  activeColor: lds.colors.accent,
                  onChanged: _biometricAvailable == null
                      ? null
                      : (enabled) => unawaited(_setLockEnabled(enabled)),
                ),
              ),
            ),
          const SizedBox(height: LdsSpacing.xl),
          _SectionLabel(l10n.settingsData),
          const SizedBox(height: LdsSpacing.xs),
          LdsButton(
            label: l10n.settingsResetData,
            variant: LdsButtonVariant.destructive,
            loading: _resetting,
            expand: true,
            onPressed: _confirmReset,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.lds.typography.label.copyWith(
        color: context.lds.colors.textMuted,
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.label, required this.trailing});

  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LdsSpacing.md,
        vertical: LdsSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: lds.colors.surfaceElevated,
        borderRadius: BorderRadius.circular(LdsRadius.lg),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: lds.typography.body)),
          trailing,
        ],
      ),
    );
  }
}

class _AppearanceSelector extends StatelessWidget {
  const _AppearanceSelector({required this.selected, required this.onSelected});

  final AppThemeMode selected;
  final ValueChanged<AppThemeMode> onSelected;

  String _label(AppLocalizations l10n, AppThemeMode mode) => switch (mode) {
        AppThemeMode.system => l10n.settingsThemeSystem,
        AppThemeMode.light => l10n.settingsThemeLight,
        AppThemeMode.dark => l10n.settingsThemeDark,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lds = context.lds;
    return Row(
      children: [
        for (final mode in AppThemeMode.values)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: LdsSpacing.xs),
              child: Semantics(
                button: true,
                selected: mode == selected,
                label: _label(l10n, mode),
                child: GestureDetector(
                  onTap: () {
                    unawaited(LdsHaptics.tap());
                    onSelected(mode);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: LdsSpacing.sm,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: mode == selected
                          ? lds.colors.accent
                          : lds.colors.surfaceElevated,
                      borderRadius: BorderRadius.circular(LdsRadius.md),
                    ),
                    child: Icon(
                      switch (mode) {
                        AppThemeMode.system => Icons.smartphone_rounded,
                        AppThemeMode.light => Icons.light_mode_rounded,
                        AppThemeMode.dark => Icons.dark_mode_rounded,
                      },
                      size: 20,
                      color: mode == selected
                          ? lds.colors.onAccent
                          : lds.colors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ResetConfirmationSheet extends StatelessWidget {
  const _ResetConfirmationSheet({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        LdsSpacing.xl,
        LdsSpacing.xs,
        LdsSpacing.xl,
        LdsSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.settingsResetConfirmTitle, style: lds.typography.title),
          const SizedBox(height: LdsSpacing.xs),
          Text(l10n.settingsResetConfirmBody, style: lds.typography.bodyMuted),
          const SizedBox(height: LdsSpacing.lg),
          Row(
            children: [
              Expanded(
                child: LdsButton(
                  label: l10n.settingsCancel,
                  variant: LdsButtonVariant.secondary,
                  expand: true,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: LdsSpacing.sm),
              Expanded(
                child: LdsButton(
                  label: l10n.settingsResetConfirmAction,
                  variant: LdsButtonVariant.destructive,
                  expand: true,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
