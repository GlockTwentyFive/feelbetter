import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class BreatheView extends StatefulWidget {
  const BreatheView({super.key});

  @override
  State<BreatheView> createState() => _BreatheViewState();
}

class _BreatheViewState extends State<BreatheView> {
  static const _phases = <_PhaseDefinition>[
    _PhaseDefinition(name: 'inhale', label: 'Breathe in…', duration: Duration(seconds: 4), scale: 1.15),
    _PhaseDefinition(name: 'hold', label: 'Hold softly', duration: Duration(seconds: 4), scale: 1.15),
    _PhaseDefinition(name: 'exhale', label: 'Breathe out…', duration: Duration(seconds: 6), scale: 0.88),
  ];

  int _phaseIndex = -1;
  int _secondsRemaining = 0;
  Timer? _tickTimer;
  Timer? _phaseTimer;
  double _targetScale = 1.0;

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);
    final textTheme = Theme.of(context).textTheme;
    final appState = context.read<AppState>();
    final isRunning = _phaseIndex >= 0;
    final currentPhase = isRunning ? _phases[_phaseIndex] : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1040;
        final isTablet = constraints.maxWidth >= 720 && !isWide;
        final diameter = (constraints.biggest.shortestSide * (isWide ? 0.36 : isTablet ? 0.46 : 0.6)).clamp(200.0, 340.0);
        final outerPadding = MediaQuery.paddingOf(context);

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                tokens.backgroundPrimary,
                tokens.backgroundSecondary.withValues(alpha: tokens.isDark ? 0.94 : 0.9),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isWide ? 72 : (isTablet ? 48 : 20),
                isWide ? 56 : (isTablet ? 44 : 28),
                isWide ? 72 : (isTablet ? 48 : 20),
                outerPadding.bottom + (isWide ? 48 : 32),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWide ? 720 : 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton.filledTonal(
                        onPressed: () {
                          _stop();
                          appState.showView(AppView.calmHome);
                        },
                        icon: const Icon(Icons.arrow_back_rounded),
                        tooltip: 'Back to home',
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Steady breaths',
                      textAlign: TextAlign.center,
                      style: (isWide ? textTheme.headlineMedium : textTheme.headlineSmall)?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: tokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '4 in · 4 pause · 6 out',
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        color: tokens.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _BreathVisual(
                      diameter: diameter,
                      targetScale: _targetScale,
                      currentPhase: currentPhase,
                      isRunning: isRunning,
                      secondsRemaining: _secondsRemaining,
                      textTheme: textTheme,
                      tokens: tokens,
                      onToggle: () => isRunning ? _stop() : _start(),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      isRunning
                          ? 'Pause anytime; the rhythm will wait.'
                          : 'Tap begin when you want to breathe with the circle.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(color: tokens.textSecondary, height: 1.45),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _start() {
    setState(() {
      _phaseIndex = 0;
      _secondsRemaining = _phases[0].duration.inSeconds;
      _targetScale = _phases[0].scale;
    });
    _setupTimers();
  }

  void _stop() {
    _cancelTimers();
    setState(() {
      _phaseIndex = -1;
      _secondsRemaining = 0;
      _targetScale = 1.0;
    });
  }

  void _setupTimers() {
    _cancelTimers();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_secondsRemaining <= 1) return;
      setState(() => _secondsRemaining -= 1);
    });
    _phaseTimer = Timer(_currentPhaseDuration, _advancePhase);
  }

  void _advancePhase() {
    if (!mounted) return;
    setState(() {
      _phaseIndex = (_phaseIndex + 1) % _phases.length;
      _secondsRemaining = _phases[_phaseIndex].duration.inSeconds;
      _targetScale = _phases[_phaseIndex].scale;
    });
    _setupTimers();
  }

  Duration get _currentPhaseDuration =>
      _phaseIndex >= 0 ? _phases[_phaseIndex].duration : const Duration(seconds: 0);

  void _cancelTimers() {
    _tickTimer?.cancel();
    _phaseTimer?.cancel();
    _tickTimer = null;
    _phaseTimer = null;
  }
}

class _PhaseDefinition {
  const _PhaseDefinition({
    required this.name,
    required this.label,
    required this.duration,
    required this.scale,
  });

  final String name;
  final String label;
  final Duration duration;
  final double scale;
}

class _BreathVisual extends StatelessWidget {
  const _BreathVisual({
    required this.diameter,
    required this.targetScale,
    required this.currentPhase,
    required this.isRunning,
    required this.secondsRemaining,
    required this.textTheme,
    required this.tokens,
    required this.onToggle,
  });

  final double diameter;
  final double targetScale;
  final _PhaseDefinition? currentPhase;
  final bool isRunning;
  final int secondsRemaining;
  final TextTheme textTheme;
  final FeelBetterTheme tokens;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final timerText = secondsRemaining > 0 ? secondsRemaining.toString().padLeft(2, '0') : '--';

    return Column(
      children: [
        AnimatedScale(
          scale: targetScale,
          duration: currentPhase?.duration ?? const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
          child: Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  tokens.accentPrimary.withValues(alpha: 0.22),
                  tokens.accentPrimary.withValues(alpha: 0.08),
                ],
              ),
              border: Border.all(color: tokens.accentRing.withValues(alpha: 0.3), width: 4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentPhase?.label ?? 'Ready?',
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: isRunning
                        ? Text(
                            timerText,
                            key: ValueKey(timerText),
                            style: textTheme.displayMedium?.copyWith(
                              color: tokens.accentPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : Text(
                            'Follow the circle’s pace.',
                            key: const ValueKey('hint'),
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: onToggle,
          icon: Icon(isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded),
          label: Text(isRunning ? 'Pause session' : 'Begin session'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            backgroundColor: isRunning ? tokens.backgroundSecondary : tokens.accentPrimary,
            foregroundColor: isRunning ? tokens.textPrimary : tokens.textOnAccent,
          ),
        ),
      ],
    );
  }
}
