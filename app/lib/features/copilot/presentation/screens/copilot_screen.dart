import 'dart:async';

import 'package:core_domain/core_domain.dart';
import 'package:core_l10n/core_l10n.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen_app/features/copilot/presentation/controllers/copilot_controller.dart';
import 'package:lumen_app/features/copilot/presentation/widgets/evidence_sheet.dart';

/// Conversational copilot over the local ledger — every claim it makes
/// is grounded in real transactions, and tapping a citation shows
/// exactly which ones (docs/05-backend-and-ai.md §3).
class CopilotScreen extends ConsumerStatefulWidget {
  /// Creates the Copilot screen.
  const CopilotScreen({super.key});

  @override
  ConsumerState<CopilotScreen> createState() => _CopilotScreenState();
}

class _CopilotScreenState extends ConsumerState<CopilotScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send([String? suggestion]) {
    final text = suggestion ?? _inputController.text;
    if (text.trim().isEmpty) return;
    ref.read(copilotControllerProvider.notifier).send(text);
    _inputController.clear();
    FocusScope.of(context).unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      unawaited(
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: LdsMotion.standard,
          curve: Curves.easeOut,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lds = context.lds;
    final state = ref.watch(copilotControllerProvider);

    return LdsScaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              LdsSpacing.md,
              LdsSpacing.lg,
              LdsSpacing.md,
              LdsSpacing.sm,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(l10n.tabCopilot, style: lds.typography.title),
            ),
          ),
          Expanded(
            child: state.messages.isEmpty
                ? _WelcomeState(onSuggestionTap: _send)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      LdsSpacing.md,
                      0,
                      LdsSpacing.md,
                      LdsSpacing.md,
                    ),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final isLastAssistant = state.isSending &&
                          index == state.messages.length - 1 &&
                          message.role == MessageRole.assistant;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: LdsSpacing.sm),
                        child: ChatBubble(
                          role: message.role == MessageRole.user
                              ? ChatBubbleRole.user
                              : ChatBubbleRole.assistant,
                          content: message.content,
                          isStreaming: isLastAssistant,
                          evidenceLabel: message.evidence.isEmpty
                              ? null
                              : _evidenceLabel(l10n, message.evidence.length),
                          onEvidenceTap: message.evidence.isEmpty
                              ? null
                              : () =>
                                  showEvidenceSheet(context, message.evidence),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              LdsSpacing.md,
              LdsSpacing.xs,
              LdsSpacing.md,
              LdsSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    style: lds.typography.body,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: l10n.copilotInputHint,
                      hintStyle: lds.typography.bodyMuted,
                      filled: true,
                      fillColor: lds.colors.surfaceElevated,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: LdsSpacing.md,
                        vertical: LdsSpacing.sm,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(LdsRadius.full),
                        borderSide: BorderSide(color: lds.colors.borderSubtle),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(LdsRadius.full),
                        borderSide: BorderSide(color: lds.colors.accent),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: LdsSpacing.xs),
                Semantics(
                  button: true,
                  label: l10n.copilotSendLabel,
                  child: IconButton.filled(
                    onPressed: state.isSending ? null : _send,
                    style: IconButton.styleFrom(
                      backgroundColor: lds.colors.accent,
                      foregroundColor: lds.colors.onAccent,
                    ),
                    icon: const Icon(Icons.arrow_upward_rounded),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _evidenceLabel(AppLocalizations l10n, int count) {
    final word =
        count == 1 ? l10n.copilotSourceSingular : l10n.copilotSourcePlural;
    return '$count $word';
  }
}

class _WelcomeState extends StatelessWidget {
  const _WelcomeState({required this.onSuggestionTap});

  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lds = context.lds;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LdsSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 40,
              color: lds.colors.accent,
            ),
            const SizedBox(height: LdsSpacing.md),
            Text(
              l10n.copilotWelcomeTitle,
              style: lds.typography.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: LdsSpacing.xs),
            Text(
              l10n.copilotWelcomeMessage,
              style: lds.typography.bodyMuted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: LdsSpacing.xl),
            Wrap(
              spacing: LdsSpacing.xs,
              runSpacing: LdsSpacing.xs,
              alignment: WrapAlignment.center,
              children: [
                PromptSuggestionChip(
                  label: l10n.copilotSuggestionDining,
                  onTap: () => onSuggestionTap(l10n.copilotSuggestionDining),
                ),
                PromptSuggestionChip(
                  label: l10n.copilotSuggestionSubscriptions,
                  onTap: () =>
                      onSuggestionTap(l10n.copilotSuggestionSubscriptions),
                ),
                PromptSuggestionChip(
                  label: l10n.copilotSuggestionForecast,
                  onTap: () => onSuggestionTap(l10n.copilotSuggestionForecast),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
