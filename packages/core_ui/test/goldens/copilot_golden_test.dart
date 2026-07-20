import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../helpers/golden_helpers.dart';

void main() {
  ldsGoldenPair(
    fileName: 'chat_bubble',
    constraints: const BoxConstraints(maxWidth: 360, maxHeight: 420),
    scenarios: {
      'conversation': const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ChatBubble(
            role: ChatBubbleRole.user,
            content: 'How much did I spend on dining this month?',
          ),
          SizedBox(height: LdsSpacing.sm),
          ChatBubble(
            role: ChatBubbleRole.assistant,
            content: r"You've spent $ 328.494 on dining this month, "
                'across 9 transactions.',
            evidenceLabel: '9 sources',
          ),
        ],
      ),
      'streaming': const ChatBubble(
        role: ChatBubbleRole.assistant,
        content: "You've spent",
        isStreaming: true,
      ),
    },
  );

  ldsGoldenPair(
    fileName: 'prompt_suggestion_chips',
    scenarios: {
      'row': const Wrap(
        spacing: LdsSpacing.xs,
        runSpacing: LdsSpacing.xs,
        children: [
          PromptSuggestionChip(label: 'How much on dining?', onTap: _noop),
          PromptSuggestionChip(label: 'Any subscriptions?', onTap: _noop),
          PromptSuggestionChip(label: 'Forecast next month', onTap: _noop),
        ],
      ),
    },
  );

  ldsGoldenPair(
    fileName: 'insight_card',
    constraints: const BoxConstraints(maxWidth: 340),
    scenarios: {
      'with confidence': const InsightCard(
        title: 'Price increase detected',
        body: r'Netflix went from $ 26.900 to $ 33.900, a 26% increase.',
        confidenceLabel: 'Based on 18 charges',
      ),
      'without confidence': const InsightCard(
        title: 'Heads up',
        body: 'This is a general note with no specific evidence attached.',
      ),
    },
  );
}

void _noop() {}
