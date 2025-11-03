import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class CalmHomeView extends StatelessWidget {
  const CalmHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final tokens = AppTheme.tokens(context);
        return ColoredBox(
          color: tokens.backgroundPrimary,
          child: SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth;
                final isCompact = maxWidth < 720;
                final isTablet = maxWidth >= 720 && maxWidth < 1100;
                final isWide = maxWidth >= 1100;
                final horizontal = isCompact
                    ? 20.0
                    : isTablet
                        ? 48.0
                        : 104.0;
                final vertical = isCompact
                    ? 40.0
                    : isTablet
                        ? 72.0
                        : 92.0;
                final contentMaxWidth = isWide ? 1200.0 : 880.0;
                final bottomInset = isCompact ? 140.0 : 96.0;

                final hero = _QuickStartHero(
                  onExploreEmotions: () => appState.showView(AppView.manageEmotions),
                  isCompact: isCompact,
                  isWide: isWide,
                );

                final exploreButton = _HomeSidePanel(
                  onExploreEmotions: () => appState.showView(AppView.manageEmotions),
                );

                return Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(horizontal, vertical, horizontal, (vertical - 12) + bottomInset),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentMaxWidth),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        child: Column(
                          key: ValueKey(isWide ? 'wide-home-layout' : 'stacked-home-layout'),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            hero,
                            SizedBox(height: isWide ? 56 : 40),
                            Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: isWide ? 420 : double.infinity,
                                child: exploreButton,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _QuickStartHero extends StatelessWidget {
  const _QuickStartHero({
    required this.onExploreEmotions,
    required this.isCompact,
    required this.isWide,
  });

  final VoidCallback onExploreEmotions;
  final bool isCompact;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);
    final textTheme = Theme.of(context).textTheme;

    final quickActions = _buildQuickActions(tokens);

    final maxHeroWidth = isWide ? 880.0 : (isCompact ? double.infinity : 720.0);
    final heroPadding = EdgeInsets.symmetric(
      horizontal: isWide ? 40 : (isCompact ? 20 : 32),
      vertical: isCompact ? 20 : 34,
    );
    final headlineStyle = (isWide
            ? textTheme.headlineMedium
            : isCompact
                ? textTheme.titleLarge
                : textTheme.headlineSmall)
        ?.copyWith(
      fontWeight: FontWeight.w700,
      color: tokens.textPrimary,
      letterSpacing: isWide ? 0.2 : 0,
    );

    void showQuickAction(_QuickActionData action) {
      showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        builder: (sheetContext) => _QuickActionSheet(
          action: action,
          onExploreEmotions: onExploreEmotions,
        ),
      );
    }

    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxHeroWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tokens.backgroundSecondary,
                tokens.backgroundPrimary.withValues(alpha: tokens.isDark ? 0.48 : 0.82),
                tokens.backgroundSecondary.withValues(alpha: tokens.isDark ? 0.72 : 0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(isCompact ? 30 : 40),
            border: Border.all(color: tokens.borderSecondary.withValues(alpha: 0.28)),
            boxShadow: [
              BoxShadow(
                color: tokens.shadowColor.withValues(alpha: tokens.isDark ? 0.22 : 0.08),
                blurRadius: isWide ? 34 : 26,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Padding(
            padding: heroPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'What do you need right now?',
                  textAlign: TextAlign.center,
                  style: headlineStyle,
                ),
                const SizedBox(height: 28),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < quickActions.length; i++) ...[
                      _HeroActionCard(
                        tokens: tokens,
                        title: quickActions[i].title,
                        icon: quickActions[i].icon,
                        gradient: quickActions[i].gradient,
                        onPressed: () => showQuickAction(quickActions[i]),
                      ),
                      if (i != quickActions.length - 1) SizedBox(height: isCompact ? 16 : 22),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_QuickActionData> _buildQuickActions(FeelBetterTheme tokens) {
    return [
      _QuickActionData(
        title: 'Steady me',
        icon: Icons.self_improvement_rounded,
        gradient: [tokens.accentPrimary, tokens.accentSecondary],
        intro: 'Use this quick grounding sequence when everything feels fuzzy and you need a calmer baseline first.',
        steps: const [
          _QuickActionStep(
            title: 'Anchor your breath',
            detail: 'Inhale for 4, hold for 1, exhale for 6. Drop your shoulders on every exhale for 6 cycles.',
          ),
          _QuickActionStep(
            title: 'Reset your senses',
            detail: 'Press your palms together for 5 seconds, release, then name one thing you can see, hear, and touch.',
          ),
          _QuickActionStep(
            title: 'Choose one gentle action',
            detail: 'Sip water, stand and stretch, or step outside for fresh air for 30 seconds.',
          ),
        ],
      ),
      _QuickActionData(
        title: 'Pick my next move',
        icon: Icons.explore_rounded,
        gradient: [tokens.accentTertiary, tokens.accentPrimary],
        intro: 'Walk through these prompts to spot what needs care right now and choose a small move.',
        steps: const [
          _QuickActionStep(
            title: 'Notice your signal',
            detail: 'Ask “What is loudest—my body, my thoughts, or the situation?” Write down the first answer.',
          ),
          _QuickActionStep(
            title: 'Match a support',
            detail: 'Body loud? Try breath or movement. Thoughts loud? Jot them down. Situation loud? List one thing you can influence.',
          ),
          _QuickActionStep(
            title: 'Start the next micro-step',
            detail: 'Set a 2-minute timer and begin that one action. Check in again afterward to see what shifted.',
          ),
        ],
      ),
    ];
  }
}

class _QuickActionSheet extends StatelessWidget {
  const _QuickActionSheet({required this.action, required this.onExploreEmotions});

  final _QuickActionData action;
  final VoidCallback onExploreEmotions;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 28,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    action.title,
                    style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: tokens.textPrimary),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              action.intro,
              style: textTheme.bodyMedium?.copyWith(color: tokens.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                for (var i = 0; i < action.steps.length; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: i == action.steps.length - 1 ? 0 : 16),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: tokens.backgroundSecondary,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: tokens.borderSecondary.withValues(alpha: 0.28)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: tokens.accentPrimary.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  '${i + 1}',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: tokens.accentPrimary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    action.steps[i].title,
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: tokens.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    action.steps[i].detail,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: tokens.textSecondary,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onExploreEmotions();
              },
              icon: const Icon(Icons.grid_view_rounded),
              label: const Text('Browse all emotions'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.intro,
    required this.steps,
  });

  final String title;
  final IconData icon;
  final List<Color> gradient;
  final String intro;
  final List<_QuickActionStep> steps;
}

class _QuickActionStep {
  const _QuickActionStep({required this.title, required this.detail});

  final String title;
  final String detail;
}

class _HeroActionCard extends StatelessWidget {
  const _HeroActionCard({
    required this.tokens,
    required this.title,
    required this.icon,
    required this.gradient,
    required this.onPressed,
  });

  final FeelBetterTheme tokens;
  final String title;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final surface = tokens.backgroundSecondary.withValues(alpha: tokens.isDark ? 0.92 : 0.98);
    final borderColor = tokens.borderSecondary.withValues(alpha: 0.28);
    final titleColor = tokens.textPrimary;
    final iconColor = tokens.accentPrimary;
    final iconBackground = tokens.accentPrimary.withValues(alpha: 0.15);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(32),
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: tokens.shadowColor.withValues(alpha: tokens.isDark ? 0.22 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 16),
              ),
            ],
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 26),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeSidePanel extends StatelessWidget {
  const _HomeSidePanel({required this.onExploreEmotions});

  final VoidCallback onExploreEmotions;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  tokens.accentPrimary.withValues(alpha: 0.38),
                  tokens.accentSecondary.withValues(alpha: 0.32),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: tokens.shadowColor.withValues(alpha: tokens.isDark ? 0.18 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: FilledButton.icon(
              onPressed: onExploreEmotions,
              icon: const Icon(Icons.grid_view_rounded),
              label: const Text('Explore every emotion'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: tokens.textOnAccent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
