import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PhilosophyDialog extends StatelessWidget {
  const PhilosophyDialog({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);
    final textTheme = Theme.of(context).textTheme;

    return Dialog(      
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: tokens.backgroundSecondary,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: tokens.borderSecondary.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: tokens.shadowColor.withValues(alpha: tokens.isDark ? 0.3 : 0.18),
              blurRadius: 38,
              offset: const Offset(0, 22),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(26, 24, 22, 18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'Our Philosophy',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: tokens.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () {
                            Navigator.of(context).pop();
                            onClose();
                          },
                          icon: const Icon(Icons.close_rounded),
                          style: IconButton.styleFrom(
                            foregroundColor: tokens.textSecondary,
                            backgroundColor: tokens.backgroundHover,
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(26, 0, 26, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'This app was created with a single, simple mission: to provide a helpful, safe, and accessible tool for navigating the complexities of our emotional lives.',
                            style: textTheme.bodyLarge?.copyWith(
                              color: tokens.textSecondary,
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _BulletPoint(
                            label: 'Completely Free, Forever.',
                            description:
                                'There are no hidden costs, subscriptions, or premium features. This toolkit is a gift, with no strings attached.',
                            tokens: tokens,
                            textTheme: textTheme,
                          ),
                          _BulletPoint(
                            label: '100% Private & Offline.',
                            description:
                                'Your emotional history and journal entries are your own. All data is stored only on your device. It is never sent to a server, collected, or sold.',
                            tokens: tokens,
                            textTheme: textTheme,
                          ),
                          _BulletPoint(
                            label: 'No Ads, No Tracking.',
                            description:
                                'This space is for reflection, not for commerce. You will never be tracked, and you will never see an advertisement.',
                            tokens: tokens,
                            textTheme: textTheme,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'We hope you find it to be a valuable companion on your journey.',
                            style: textTheme.bodyLarge?.copyWith(
                              color: tokens.textSecondary,
                              height: 1.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: tokens.backgroundSecondary.withValues(alpha: 0.8),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                      border: Border(top: BorderSide(color: tokens.borderSecondary.withValues(alpha: 0.3))),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onClose();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: tokens.accentPrimary,
                          foregroundColor: tokens.textOnAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  const _BulletPoint({
    required this.label,
    required this.description,
    required this.tokens,
    required this.textTheme,
  });

  final String label;
  final String description;
  final FeelBetterTheme tokens;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: tokens.accentPrimary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: tokens.accentPrimary.withValues(alpha: 0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            width: 20,
            height: 20,
            child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: textTheme.bodyMedium?.copyWith(
                    color: tokens.textSecondary,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
