import 'package:core_l10n/core_l10n.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// Portfolio-facing intro + install links.
///
/// The web demo is what recruiters land on; this screen tells them what
/// LUMEN is and how to run it natively (Android APK) or on iPhone (the
/// same web build). Links live here as constants — the APK resolves to
/// the newest GitHub release asset so tagging a new version never breaks
/// the button.
class AboutScreen extends StatelessWidget {
  /// Creates the about screen.
  const AboutScreen({super.key});

  // Relative to index.html — resolves correctly under the hash-based
  // router regardless of which route is on screen, both in local dev
  // (`flutter run -d chrome`) and on GitHub Pages under /lumenai/.
  static const _androidApkUrl = 'downloads/lumen-ai.apk';
  static const _webAppUrl = 'https://adriantx23.github.io/lumenai/';
  static const _sourceUrl = 'https://github.com/AdrianTX23/lumenai';

  Future<void> _open(BuildContext context, String url) async {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      LdsSnack.show(context, context.l10n.aboutOpenLinkFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lds = context.lds;

    return LdsScaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          LdsSpacing.md,
          LdsSpacing.md,
          LdsSpacing.md,
          LdsSpacing.jumbo,
        ),
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: lds.colors.textPrimary,
                ),
                onPressed: () => context.pop(),
              ),
              Expanded(
                child: Text(l10n.aboutTitle, style: lds.typography.title),
              ),
            ],
          ),
          const SizedBox(height: LdsSpacing.lg),
          _Hero(tagline: l10n.aboutTagline),
          const SizedBox(height: LdsSpacing.xl),
          Text(l10n.aboutIntro, style: lds.typography.bodyMuted),
          const SizedBox(height: LdsSpacing.xl),
          _Feature(
            icon: Icons.account_balance_wallet_rounded,
            title: l10n.aboutFeatureWalletTitle,
            body: l10n.aboutFeatureWalletBody,
          ),
          const SizedBox(height: LdsSpacing.sm),
          _Feature(
            icon: Icons.insights_rounded,
            title: l10n.aboutFeatureInsightsTitle,
            body: l10n.aboutFeatureInsightsBody,
          ),
          const SizedBox(height: LdsSpacing.sm),
          _Feature(
            icon: Icons.auto_awesome_rounded,
            title: l10n.aboutFeatureCopilotTitle,
            body: l10n.aboutFeatureCopilotBody,
          ),
          const SizedBox(height: LdsSpacing.xl),
          _TryCard(
            onAndroid: () => _open(context, _androidApkUrl),
            onIphone: () => _open(context, _webAppUrl),
          ),
          const SizedBox(height: LdsSpacing.lg),
          Center(
            child: LdsButton(
              label: l10n.aboutViewSource,
              variant: LdsButtonVariant.ghost,
              icon: Icons.code_rounded,
              onPressed: () => _open(context, _sourceUrl),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.tagline});

  final String tagline;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LdsRadius.lg),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: lds.colors.accentGradient,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/icon/app_icon.png',
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: LdsSpacing.md),
        Text('LUMEN AI', style: lds.typography.display),
        const SizedBox(height: LdsSpacing.xxs),
        Text(
          tagline,
          textAlign: TextAlign.center,
          style: lds.typography.body.copyWith(color: lds.colors.accent),
        ),
      ],
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: lds.colors.surfaceElevated,
            borderRadius: BorderRadius.circular(LdsRadius.md),
          ),
          child: Icon(icon, size: 20, color: lds.colors.accent),
        ),
        const SizedBox(width: LdsSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: lds.typography.label),
              const SizedBox(height: 2),
              Text(body, style: lds.typography.caption),
            ],
          ),
        ),
      ],
    );
  }
}

class _TryCard extends StatelessWidget {
  const _TryCard({required this.onAndroid, required this.onIphone});

  final VoidCallback onAndroid;
  final VoidCallback onIphone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lds = context.lds;
    return LdsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.aboutTryTitle, style: lds.typography.heading),
          const SizedBox(height: LdsSpacing.xxs),
          Text(l10n.aboutTrySubtitle, style: lds.typography.caption),
          const SizedBox(height: LdsSpacing.md),
          LdsButton(
            label: l10n.aboutDownloadAndroid,
            icon: Icons.android_rounded,
            size: LdsButtonSize.large,
            expand: true,
            onPressed: onAndroid,
          ),
          const SizedBox(height: LdsSpacing.xs),
          LdsButton(
            label: l10n.aboutTryIphone,
            variant: LdsButtonVariant.secondary,
            icon: Icons.phone_iphone_rounded,
            size: LdsButtonSize.large,
            expand: true,
            onPressed: onIphone,
          ),
          const SizedBox(height: LdsSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 14,
                color: lds.colors.textMuted,
              ),
              const SizedBox(width: LdsSpacing.xs),
              Expanded(
                child: Text(
                  l10n.aboutPrivacyNote,
                  style: lds.typography.caption,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
