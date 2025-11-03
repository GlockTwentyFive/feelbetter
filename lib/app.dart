import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'providers/app_state.dart';
import 'theme/app_theme.dart';
import 'views/breathe_view.dart';
import 'views/calm_home_view.dart';
import 'views/journal_view.dart';
import 'views/emotion_strategies_view.dart';
import 'views/manage_emotions_view.dart';
import 'views/emotion_trends_view.dart';
import 'widgets/philosophy_dialog.dart';

class FeelBetterAppView extends StatelessWidget {
  const FeelBetterAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final theme = AppTheme.themeFor(appState.themeId);
        final darkTheme = AppTheme.darkThemeFor(appState.themeId);

        return MaterialApp(
          title: 'Feel Better',
          debugShowCheckedModeBanner: false,
          themeMode: theme.brightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light,
          theme: theme,
          darkTheme: darkTheme,
          home: const _HomeRouter(),
          builder: (context, child) {
            final media = MediaQuery.of(context);
            final width = media.size.width;
            final baseScale = media.textScaler.scale(1);
            double targetScale = baseScale;
            if (width < 340) {
              targetScale = (baseScale * 0.85).clamp(0.75, 1.0);
            } else if (width < 400) {
              targetScale = (baseScale * 0.9).clamp(0.8, 1.05);
            } else if (width < 480) {
              targetScale = (baseScale * 0.95).clamp(0.85, 1.1);
            } else {
              targetScale = targetScale.clamp(0.9, 1.15);
            }

            final iconScale = width < 340
                ? 0.8
                : width < 400
                    ? 0.88
                    : width < 480
                        ? 0.94
                        : 1.0;
            final iconTheme = IconTheme.of(context);
            final iconSize = (iconTheme.size ?? 24.0) * iconScale;

            return MediaQuery(
              data: media.copyWith(textScaler: TextScaler.linear(targetScale)),
              child: IconTheme(
                data: iconTheme.copyWith(size: iconSize),
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        );
      },
    );
  }
}

enum _CompactAction { journal, manageEmotions, emotionTrends, donate, streak }

void _showStreakToast(BuildContext context, int streak) {
  if (streak <= 0) return;
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text('You have a $streak-day streak going. Keep it up!'),
      ),
    );
}

const _upiLink = 'https://www.upi.me/pay?pa=vishalsimar@upi&tn=Making%20the%20world%20a%20better%20place.';

Future<void> _launchUpiLink(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final uri = Uri.parse(_upiLink);
    if (!await canLaunchUrl(uri)) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(content: Text('Unable to open the UPI link right now.')));
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (error) {
    messenger
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(content: Text('Unable to open the UPI link right now.')));
  }
}

void _copyUpiLink(BuildContext context) {
  final messenger = ScaffoldMessenger.of(context);
  Clipboard.setData(const ClipboardData(text: _upiLink)).then((_) {
    messenger
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(content: Text('UPI link copied')));
  });
}

class _DonateDialog extends StatelessWidget {
  const _DonateDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = AppTheme.tokens(context);

    final isCompact = MediaQuery.of(context).size.width < 520;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: EdgeInsets.symmetric(horizontal: isCompact ? 16 : 24, vertical: isCompact ? 20 : 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: EdgeInsets.fromLTRB(isCompact ? 22 : 28, isCompact ? 24 : 28, isCompact ? 22 : 28, isCompact ? 20 : 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Support Feel Better',
                        style: (isCompact ? theme.textTheme.titleLarge : theme.textTheme.headlineSmall)?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: tokens.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Your generosity helps us keep the strategies evidence-based, beautifully designed, and accessible to everyone who needs a soft place to land.',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5, color: tokens.textSecondary),
                ),
                const SizedBox(height: 24),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: tokens.backgroundTertiary,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: tokens.borderSecondary.withValues(alpha: 0.45)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Ways to help',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: tokens.accentPrimary,
                          ),
                        ),
                        SizedBox(height: isCompact ? 8 : 12),
                        _DonateRow(icon: Icons.coffee_rounded, label: 'Buy the team a calming tea'),
                        _DonateRow(icon: Icons.spa_rounded, label: 'Sponsor new coping strategies'),
                        _DonateRow(icon: Icons.favorite_rounded, label: 'Pay it forward for someone in need'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SelectableText.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'UPI ID: ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: tokens.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: 'vishalsimar@upi',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: tokens.accentPrimary,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                SelectableText(
                  _upiLink,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(color: tokens.textSecondary),
                ),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: () => _launchUpiLink(context),
                      icon: const Icon(Icons.link_rounded),
                      label: const Text('Open UPI link'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _copyUpiLink(context),
                      icon: const Icon(Icons.copy_rounded),
                      label: const Text('Copy link'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Every gift fuels the roadmap ahead: hosting the app on our own servers, polished web and desktop versions, gentle AI companions, and trusted real-time support with psychologists and psychiatrists. Your help keeps these future tools within reach for anyone who needs a steady hand.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: tokens.textSecondary, height: 1.55),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DonateRow extends StatelessWidget {
  const _DonateRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = AppTheme.tokens(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: tokens.accentSecondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(icon, color: tokens.accentSecondary, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: tokens.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeRouter extends StatelessWidget {
  const _HomeRouter();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (!appState.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          if (appState.showPhilosophyModal) {
            appState.closePhilosophyModal();
            showDialog<void>(
              context: context,
              builder: (_) => PhilosophyDialog(
                onClose: () => appState.closePhilosophyModal(),
              ),
            );
          }
        });

        final theme = Theme.of(context);
        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: _FeelBetterAppBar(appState: appState),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _currentView(appState),
          ),
          floatingActionButton: switch (appState.view) {
            AppView.breathe => null,
            AppView.manageEmotions => null,
            AppView.emotionTrends => FloatingActionButton.extended(
                onPressed: () => appState.clearEmotionHistory(),
                icon: const Icon(Icons.delete_sweep_outlined),
                label: const Text('Clear history'),
              ),
            _ => FloatingActionButton.extended(
                onPressed: () => appState.showView(AppView.breathe),
                icon: const Icon(Icons.self_improvement),
                label: const Text('Breathe'),
              ),
          },
          floatingActionButtonLocation: appState.view == AppView.journal
              ? FloatingActionButtonLocation.startFloat
              : FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  Widget _currentView(AppState appState) {
    switch (appState.view) {
      case AppView.calmHome:
        return const CalmHomeView();
      case AppView.breathe:
        return const BreatheView();
      case AppView.journal:
        return const JournalView();
      case AppView.emotionStrategies:
        return const EmotionStrategiesView();
      case AppView.manageEmotions:
        return const ManageEmotionsView();
      case AppView.emotionTrends:
        return const EmotionTrendsView();
    }
  }
}

class _FeelBetterAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _FeelBetterAppBar({required this.appState});

  final AppState appState;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 520;
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 1,
      titleSpacing: 12,
      title: Row(
        children: [
          IconButton(
            tooltip: 'About this app',
            onPressed: () => appState.openPhilosophyModal(),
            icon: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.secondary),
          ),
          const SizedBox(width: 8),
          ThemeSwitcher(themeId: appState.themeId, onThemeChanged: appState.setTheme),
          if (!isCompact) ...[
            const SizedBox(width: 12),
            const Spacer(),
            _StreakBadge(streak: appState.streak),
          ],
        ],
      ),
      actions: isCompact
          ? [
              PopupMenuButton<_CompactAction>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (value) {
                  switch (value) {
                    case _CompactAction.journal:
                      appState.showView(AppView.journal);
                      break;
                    case _CompactAction.manageEmotions:
                      appState.showView(AppView.manageEmotions);
                      break;
                    case _CompactAction.emotionTrends:
                      appState.showView(AppView.emotionTrends);
                      break;
                    case _CompactAction.donate:
                      showDialog<void>(
                        context: context,
                        builder: (_) => const _DonateDialog(),
                      );
                      break;
                    case _CompactAction.streak:
                      _showStreakToast(context, appState.streak);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _CompactAction.journal,
                    child: const Text('Journal'),
                  ),
                  PopupMenuItem(
                    value: _CompactAction.manageEmotions,
                    child: const Text('Explore feelings'),
                  ),
                  PopupMenuItem(
                    value: _CompactAction.emotionTrends,
                    child: const Text('View patterns'),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: _CompactAction.donate,
                    child: const Text('Donate'),
                  ),
                  PopupMenuItem(
                    value: _CompactAction.streak,
                    enabled: appState.streak > 0,
                    child: Text('Streak: ${appState.streak}'),
                  ),
                ],
              ),
            ]
          : [
              IconButton(
                tooltip: 'Journal',
                onPressed: () => appState.showView(AppView.journal),
                icon: Icon(Icons.menu_book_outlined, color: Theme.of(context).colorScheme.primary),
              ),
              IconButton(
                tooltip: 'Explore feelings',
                onPressed: () => appState.showView(AppView.manageEmotions),
                icon: Icon(Icons.grid_view_rounded, color: Theme.of(context).colorScheme.tertiary),
              ),
              IconButton(
                tooltip: 'View patterns',
                onPressed: () => appState.showView(AppView.emotionTrends),
                icon: Icon(Icons.timeline_rounded, color: Theme.of(context).colorScheme.secondary),
              ),
              const SizedBox(width: 4),
              FilledButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const _DonateDialog(),
                ),
                icon: const Icon(Icons.favorite_rounded, size: 18),
                label: const Text('Donate'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
            ],
    );
  }
}

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key, required this.themeId, required this.onThemeChanged});

  final String themeId;
  final ValueChanged<String> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final themes = AppTheme.themeOptions;
    return PopupMenuButton<String>(
      tooltip: 'Choose theme',
      initialValue: themeId,
      onSelected: onThemeChanged,
      itemBuilder: (context) => themes
          .map(
            (theme) => PopupMenuItem<String>(
              value: theme.id,
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: theme.previewColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Text(theme.name),
                ],
              ),
            ),
          )
          .toList(),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: themes.firstWhere((t) => t.id == themeId).previewColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.expand_more),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = streak > 0 ? Colors.orange.shade400 : Colors.grey.shade400;
    final Color textColor = streak > 0 ? iconColor : Colors.grey.shade500;
    return Row(
      children: [
        Icon(Icons.local_fire_department, color: iconColor),
        const SizedBox(width: 4),
        Text(
          '$streak',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: textColor, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
