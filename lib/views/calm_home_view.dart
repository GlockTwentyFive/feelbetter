import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'manage_emotions_view.dart';

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
                final viewPadding = MediaQuery.of(context).padding;
                final maxWidth = constraints.maxWidth;
                final isCompact = maxWidth < 720;
                final isTablet = maxWidth >= 720 && maxWidth < 1100;
                final isWide = maxWidth >= 1100;
                final isSuperCompact = maxWidth < 380;
                final horizontal = isCompact
                    ? (isSuperCompact ? 16.0 : 20.0)
                    : isTablet
                        ? 48.0
                        : 104.0;
                final vertical = isCompact
                    ? (isSuperCompact ? 28.0 : 36.0)
                    : isTablet
                        ? 68.0
                        : 92.0;
                final contentMaxWidth = isWide ? 1200.0 : 880.0;
                final bottomInset = (isCompact ? 96.0 : 132.0) + viewPadding.bottom;

                final hero = _QuickStartHero(
                  onExploreEmotions: () => appState.showView(AppView.manageEmotions),
                  isCompact: isCompact,
                  isSuperCompact: isSuperCompact,
                  isWide: isWide,
                );

                final exploreButton = _HomeSidePanel(
                  onExploreEmotions: () => appState.showView(AppView.manageEmotions),
                  isCompact: isCompact,
                  isSuperCompact: isSuperCompact,
                );

                return Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(horizontal, vertical, horizontal, bottomInset),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentMaxWidth),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        child: Column(
                          key: ValueKey(isWide ? 'wide-home-layout' : 'stacked-home-layout'),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            hero,
                            SizedBox(height: isWide ? 56 : (isCompact ? (isSuperCompact ? 28 : 32) : 44)),
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
    required this.isSuperCompact,
    required this.isWide,
  });

  final VoidCallback onExploreEmotions;
  final bool isCompact;
  final bool isSuperCompact;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);
    final textTheme = Theme.of(context).textTheme;

    final quickActions = _buildQuickActions(tokens);

    final maxHeroWidth = isWide ? 880.0 : (isCompact ? double.infinity : 720.0);
    final heroPadding = EdgeInsets.symmetric(
      horizontal: isWide ? 40 : (isCompact ? (isSuperCompact ? 16 : 20) : 32),
      vertical: isCompact ? (isSuperCompact ? 18 : 24) : 34,
    );
    final headlineStyle = (isWide
            ? textTheme.headlineMedium
            : isCompact
                ? (isSuperCompact ? textTheme.titleMedium : textTheme.titleLarge)
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
            borderRadius: BorderRadius.circular(isCompact ? (isSuperCompact ? 24 : 30) : 40),
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
                  "Let's take a gentle moment together",
                  textAlign: TextAlign.center,
                  style: headlineStyle,
                ),
                SizedBox(height: isSuperCompact ? 20 : 28),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < quickActions.length; i++) ...[
                      _HeroActionCard(
                        tokens: tokens,
                        title: quickActions[i].title,
                        isSuperCompact: isSuperCompact,
                        icon: quickActions[i].icon,
                        gradient: quickActions[i].gradient,
                        onPressed: () => showQuickAction(quickActions[i]),
                      ),
                      if (i != quickActions.length - 1) SizedBox(height: isCompact ? (isSuperCompact ? 12 : 16) : 22),
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
        title: 'I need steadying',
        icon: Icons.self_improvement_rounded,
        gradient: [tokens.accentPrimary, tokens.accentSecondary],
        intro: 'A soft grounding sequence for the moments when everything feels fuzzy and you want a calmer baseline first.',
        steps: const [
          _QuickActionStep(
            title: 'Soften your breath',
            detail: 'Breathe in for 4, pause for 1, and exhale for 6. Let your shoulders melt on every out-breath for 6 gentle rounds.',
          ),
          _QuickActionStep(
            title: 'Settle your senses',
            detail: 'Press your palms together for 5 seconds, release, then quietly name one thing you can see, hear, and touch.',
          ),
          _QuickActionStep(
            title: 'Offer yourself one gentle action',
            detail: 'Sip water, stand and stretch, or step outside for fresh air for half a minute—whichever feels kindest.',
          ),
        ],
      ),
      _QuickActionData(
        title: 'Choose my next caring step',
        icon: Icons.explore_rounded,
        gradient: [tokens.accentTertiary, tokens.accentPrimary],
        intro: 'Follow these prompts to notice what needs care right now and choose a tiny next step that feels supportive.',
        steps: const [
          _QuickActionStep(
            title: "Notice what's loud",
            detail: 'Ask “What feels loudest—my body, my thoughts, or the situation?” Jot down whatever surfaces first.',
          ),
          _QuickActionStep(
            title: 'Match a kind support',
            detail: 'Body loud? Try a breath or movement. Thoughts loud? Scribble them out. Situation loud? Note one thing you can gently influence.',
          ),
          _QuickActionStep(
            title: 'Begin with one micro-step',
            detail: 'Set a 2-minute timer, start that one action, and check back in afterward to notice any shift.',
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
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const ManageEmotionsView(),
                  ),
                );
                onExploreEmotions();
              },
              icon: const Icon(Icons.grid_view_rounded),
              label: const Text('See emotion support library'),
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
    required this.isSuperCompact,
    required this.icon,
    required this.gradient,
    required this.onPressed,
  });

  final FeelBetterTheme tokens;
  final String title;
  final bool isSuperCompact;
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
    final arrowColor = tokens.textSecondary.withValues(alpha: tokens.isDark ? 0.7 : 0.5);
    final horizontalPadding = isSuperCompact ? 18.0 : 24.0;
    final verticalPadding = isSuperCompact ? 18.0 : 22.0;
    final iconPadding = isSuperCompact ? 12.0 : 14.0;
    final iconSize = isSuperCompact ? 24.0 : 28.0;
    final radius = BorderRadius.circular(isSuperCompact ? 26 : 32);

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: tokens.shadowColor.withValues(alpha: tokens.isDark ? 0.22 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 16),
              ),
            ],
            border: Border.all(color: borderColor),
          ),
          padding: EdgeInsets.fromLTRB(horizontalPadding, verticalPadding, horizontalPadding, verticalPadding + 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.all(iconPadding),
                  child: Icon(icon, color: iconColor, size: iconSize),
                ),
              ),
              SizedBox(width: isSuperCompact ? 14 : 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: (isSuperCompact ? textTheme.titleMedium : textTheme.titleLarge)?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: isSuperCompact ? 16 : 18, color: arrowColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeSidePanel extends StatelessWidget {
  const _HomeSidePanel({required this.onExploreEmotions, required this.isCompact, required this.isSuperCompact});

  final VoidCallback onExploreEmotions;
  final bool isCompact;
  final bool isSuperCompact;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);
    final buttonPadding = EdgeInsets.symmetric(
      horizontal: isCompact ? (isSuperCompact ? 20 : 24) : 28,
      vertical: isCompact ? (isSuperCompact ? 14 : 16) : 18,
    );

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
              label: const Text('Open emotion support library'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: tokens.textOnAccent,
                shadowColor: Colors.transparent,
                padding: buttonPadding,
                textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
