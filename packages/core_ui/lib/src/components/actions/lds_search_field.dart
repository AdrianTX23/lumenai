import 'package:core_ui/src/theme/lds_theme.dart';
import 'package:core_ui/src/tokens/lds_spacing.dart';
import 'package:flutter/material.dart';

/// Design-system search input: filled surface, rounded, leading glyph,
/// clear button while text is present.
class LdsSearchField extends StatelessWidget {
  /// Creates a search field.
  const LdsSearchField({
    required this.hint,
    required this.onChanged,
    this.controller,
    super.key,
  });

  /// Localized placeholder.
  final String hint;

  /// Fires on every edit (debouncing is the caller's concern).
  final ValueChanged<String> onChanged;

  /// Optional external controller (needed for the clear button to react).
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: lds.typography.body,
      cursorColor: lds.colors.accent,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: lds.typography.bodyMuted,
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 20,
          color: lds.colors.textMuted,
        ),
        suffixIcon: controller == null
            ? null
            : ListenableBuilder(
                listenable: controller!,
                builder: (context, _) => controller!.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: lds.colors.textMuted,
                        ),
                        onPressed: () {
                          controller!.clear();
                          onChanged('');
                        },
                      ),
              ),
        filled: true,
        fillColor: lds.colors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: LdsSpacing.md,
          vertical: LdsSpacing.sm,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LdsRadius.md),
          borderSide: BorderSide(color: lds.colors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LdsRadius.md),
          borderSide: BorderSide(color: lds.colors.accent),
        ),
      ),
    );
  }
}
