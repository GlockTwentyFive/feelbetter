import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ConfirmationSheet extends StatelessWidget {
  const ConfirmationSheet({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.confirmColor,
    required this.onConfirm,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final Color? confirmColor;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);
    final textTheme = Theme.of(context).textTheme;

    final padding = MediaQuery.of(context).viewInsets + const EdgeInsets.symmetric(horizontal: 20, vertical: 16);

    return SafeArea(
      child: Padding(
        padding: padding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.backgroundSecondary,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: tokens.borderSecondary.withValues(alpha: 0.45)),
                boxShadow: [
                  BoxShadow(
                    color: tokens.shadowColor.withValues(alpha: tokens.isDark ? 0.35 : 0.14),
                    blurRadius: 28,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(26, 26, 26, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: tokens.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    message,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: tokens.textSecondary,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              tooltip: 'Close',
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close_rounded),
                              style: IconButton.styleFrom(
                                foregroundColor: tokens.textSecondary,
                                backgroundColor: tokens.backgroundHover,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Divider(color: tokens.borderSecondary.withValues(alpha: 0.45)),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                foregroundColor: tokens.textPrimary,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 12),
                            FilledButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                onConfirm();
                              },
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                backgroundColor: confirmColor ?? tokens.accentPrimary,
                                foregroundColor: tokens.textOnAccent,
                                textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              ),
                              child: Text(confirmLabel),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
