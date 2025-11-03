import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../models/strategy_models.dart';

const Map<String, List<String>> _emotionSynonyms = {
  'joy': ['happy', 'bright', 'uplifted'],
  'trust': ['supported', 'safe with others', 'grounded'],
  'fear': ['anxious', 'worried', 'on edge'],
  'surprise': ['shocked', 'taken aback', 'caught off guard'],
  'sadness': ['blue', 'down', 'low energy'],
  'disgust': ['grossed out', 'turned off', 'repulsed'],
  'anger': ['mad', 'frustrated', 'fired up'],
  'anticipation': ['excited', 'eager', 'ready'],
  'overwhelmed': ['stressed', 'flooded', 'too much at once'],
};

const Map<String, String> _plainEmotionSummary = {
  'joy': 'Joy grows when we notice small wins, move our bodies, and share good moments with others.',
  'trust': 'Trust feels steadier when we share warm moments, keep small promises, and speak our needs.',
  'fear': 'Feeling scared eases when we slow our breath, name what is happening, and plan one tiny step.',
  'surprise': 'Surprise settles faster when we pause, make sense of what changed, and reach out if needed.',
  'sadness': 'Sadness softens through gentle movement, kind words toward yourself, and steady support.',
  'disgust': 'Feeling disgusted eases when we reset our senses, set clear limits, and refocus on what feels clean.',
  'anger': 'Anger can cool with deep breaths, body movement, clear words, and honest repair.',
  'anticipation': 'Anticipation stays grounded when we make simple plans, rest our body, and name hopes out loud.',
  'overwhelmed': 'Being overwhelmed lightens when we calm the body, clear the next task, and ask for help.',
};

class EmotionStrategiesView extends StatelessWidget {
  const EmotionStrategiesView({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final tokens = AppTheme.tokens(context);
    final emotionId = appState.currentEmotionId;

    if (emotionId == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.psychology_alt_outlined, size: 48, color: tokens.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Pick a feeling to see easy steps.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: tokens.textSecondary),
            ),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: () => appState.showView(AppView.calmHome),
              child: const Text('Back to home'),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<EmotionStrategySet>(
      key: ValueKey(emotionId),
      future: _loadStrategies(context, emotionId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: tokens.accentPrimary),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          final detail = snapshot.error?.toString();
          return _ErrorState(
            message: 'We could not load these steps just now.',
            detail: detail,
            onRetry: () => context.read<AppState>().showEmotionStrategies(emotionId),
          );
        }

        final data = snapshot.data!;
        return SafeArea(
          child: ColoredBox(
            color: tokens.backgroundPrimary,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontal = constraints.maxWidth < 720 ? 20.0 : 48.0;
                final maxWidth = constraints.maxWidth.clamp(480.0, 960.0);

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(horizontal, 40, horizontal, 60),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: _StrategiesBody(data: data, onBack: () => appState.showView(AppView.calmHome)),
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

  Future<EmotionStrategySet> _loadStrategies(BuildContext context, String emotionId) async {
    final bundle = DefaultAssetBundle.of(context);
    try {
      final path = 'content/strategies/$emotionId.json';
      final raw = await bundle.loadString(path);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return EmotionStrategySet.fromJson(json);
    } on FlutterError catch (error) {
      try {
        final fallbackRaw = await rootBundle.loadString('content/strategies/$emotionId.json');
        final json = jsonDecode(fallbackRaw) as Map<String, dynamic>;
        return EmotionStrategySet.fromJson(json);
      } on FlutterError {
        throw Exception('Strategy file missing for "$emotionId" (${error.message}).');
      }
    } on FormatException catch (error) {
      throw Exception('Strategy file for "$emotionId" has invalid JSON: ${error.message}');
    }
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, this.detail, required this.onRetry});

  final String message;
  final String? detail;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.backgroundSecondary,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: tokens.borderSecondary.withValues(alpha: 0.45)),
            boxShadow: [
              BoxShadow(
                color: tokens.shadowColor.withValues(alpha: tokens.isDark ? 0.35 : 0.18),
                blurRadius: 32,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_rounded, size: 44, color: tokens.accentSecondary),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: tokens.textPrimary,
                  ),
                ),
                if (detail != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    detail!,
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: tokens.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StrategiesBody extends StatelessWidget {
  const _StrategiesBody({required this.data, required this.onBack});

  final EmotionStrategySet data;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);
    final textTheme = Theme.of(context).textTheme;
    final synonyms = _emotionSynonyms[data.emotionId] ?? const [];
    final summary = _plainEmotionSummary[data.emotionId] ?? data.scientificSummary;
    final emotionPalette = tokens.emotion(data.emotionId);

    final sectionWidgets = <Widget>[];
    void addSection({
      required String label,
      required String description,
      required List<StrategyItem> items,
    }) {
      if (items.isEmpty) return;
      if (sectionWidgets.isNotEmpty) {
        sectionWidgets.add(const SizedBox(height: 32));
      }
      sectionWidgets.add(
        _StrategySection(
          label: label,
          description: description,
          items: items,
          accent: emotionPalette,
          headlineColor: tokens.textPrimary,
        ),
      );
    }

    addSection(
      label: 'Start in 2 minutes',
      description: 'Reset your body quickly.',
      items: data.immediate,
    );
    addSection(
      label: 'For the next few hours',
      description: 'Stay steady through the day.',
      items: data.shortTerm,
    );
    addSection(
      label: 'Keep the change going',
      description: 'Habits that stick this week.',
      items: data.longTerm,
    );
    addSection(
      label: _friendSupportLabel(data.displayName),
      description: _friendSupportDescription(data.displayName),
      items: data.supportingFriend,
    );
    addSection(
      label: _selfRepairLabel(data.displayName),
      description: _selfRepairDescription(data.displayName),
      items: data.repairingWhenResponsible,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Back to home',
              style: IconButton.styleFrom(
                backgroundColor: tokens.backgroundSecondary,
                foregroundColor: tokens.textSecondary,
                shape: const CircleBorder(),
              ),
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.displayName,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: emotionPalette.text,
                    ),
                  ),
                  if (synonyms.isNotEmpty)
                    Text(
                      synonyms.join(' · '),
                      style: textTheme.bodySmall?.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    summary,
                    style: textTheme.bodyMedium?.copyWith(
                      color: tokens.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (sectionWidgets.isNotEmpty) const SizedBox(height: 28),
        ...sectionWidgets,
      ],
    );
  }
}

String _friendSupportLabel(String emotionName) => 'Support a friend feeling $emotionName';

String _friendSupportDescription(String emotionName) =>
    'How to show up when someone you love feels $emotionName.';

String _selfRepairLabel(String emotionName) => 'When I sparked their $emotionName';

String _selfRepairDescription(String emotionName) =>
    'Steps to repair when my actions stirred $emotionName in someone else.';

class _StrategySection extends StatelessWidget {
  const _StrategySection({
    required this.label,
    required this.description,
    required this.items,
    required this.accent,
    required this.headlineColor,
  });

  final String label;
  final String description;
  final List<StrategyItem> items;
  final EmotionColors accent;
  final Color headlineColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: headlineColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: textTheme.bodyMedium?.copyWith(color: accent.text.withValues(alpha: 0.72)),
        ),
        const SizedBox(height: 18),
        Column(
          children: items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _StrategyCard(item: item, accent: accent),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _StrategyCard extends StatefulWidget {
  const _StrategyCard({required this.item, required this.accent});

  final StrategyItem item;
  final EmotionColors accent;

  @override
  State<_StrategyCard> createState() => _StrategyCardState();
}

class _StrategyCardState extends State<_StrategyCard> {
  late final FeelBetterTheme _tokens;
  late final List<bool> _checks;
  bool _celebrated = false;

  @override
  void initState() {
    super.initState();
    _checks = List<bool>.filled(widget.item.instructions.length, false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tokens = AppTheme.tokens(context);
  }

  bool get _allComplete => _checks.isNotEmpty && _checks.every((value) => value);

  void _toggle(int index) {
    setState(() {
      _checks[index] = !_checks[index];
      if (_allComplete) {
        _celebrated = true;
        Future<void>.delayed(const Duration(milliseconds: 1800), () {
          if (!mounted) return;
          setState(() => _celebrated = false);
        });
      } else {
        _celebrated = false;
      }
    });
  }

  void _reset() {
    setState(() {
      for (var i = 0; i < _checks.length; i++) {
        _checks[i] = false;
      }
      _celebrated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = widget.accent;

    final gradient = LinearGradient(
      colors: [
        _tokens.isDark ? accent.background.withValues(alpha: 0.46) : _tokens.backgroundSecondary.withValues(alpha: 0.95),
        _tokens.backgroundTertiary,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: _tokens.isDark ? gradient : null,
        color: _tokens.isDark ? null : _tokens.backgroundSecondary.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _tokens.borderSecondary.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
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
                        widget.item.title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _tokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (widget.item.modality != null)
                            _MetaPill(label: widget.item.modality!.toUpperCase(), accent: accent),
                          if (widget.item.durationLabel != null)
                            _MetaPill(label: widget.item.durationLabel!, accent: accent),
                          if (widget.item.cadence != null)
                            _MetaPill(label: widget.item.cadence!, accent: accent),
                        ],
                      ),
                    ],
                  ),
                ),
                AnimatedScale(
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutBack,
                  scale: _celebrated ? 1.0 : 0.0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 320),
                    opacity: _celebrated ? 1 : 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: accent.solid.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(Icons.auto_awesome_rounded, color: accent.solid, size: 26),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Column(
              children: [
                for (var i = 0; i < widget.item.instructions.length; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: i == widget.item.instructions.length - 1 ? 0 : 10),
                    child: _ChecklistTile(
                      label: widget.item.instructions[i],
                      isChecked: _checks[i],
                      onChanged: () => _toggle(i),
                      tokens: _tokens,
                      accent: accent,
                      neutral: true,
                    ),
                  ),
              ],
            ),
            if (widget.item.evidence != null) ...[
              const SizedBox(height: 12),
              Text(
                widget.item.evidence!.summary,
                style: textTheme.bodySmall?.copyWith(
                  color: accent.text.withValues(alpha: 0.68),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _checks.any((checked) => checked) ? _reset : null,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reset'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label, required this.accent});

  final String label;
  final EmotionColors accent;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.background.withValues(alpha: tokens.isDark ? 0.45 : 0.75),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.border.withValues(alpha: 0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: accent.text,
          ),
        ),
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({
    required this.label,
    required this.isChecked,
    required this.onChanged,
    required this.tokens,
    required this.accent,
    this.neutral = false,
  });

  final String label;
  final bool isChecked;
  final VoidCallback onChanged;
  final FeelBetterTheme tokens;
  final EmotionColors accent;
  final bool neutral;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final baseColor = neutral
        ? tokens.backgroundPrimary.withValues(alpha: tokens.isDark ? 0.28 : 0.08)
        : accent.background.withValues(alpha: tokens.isDark ? 0.42 : 0.75);
    final borderColor = neutral
        ? tokens.borderSecondary.withValues(alpha: isChecked ? 0.6 : 0.32)
        : accent.border.withValues(alpha: isChecked ? 0.6 : 0.45);
    final checkColor = neutral ? tokens.accentPrimary : accent.solid;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onChanged,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isChecked ? checkColor.withValues(alpha: tokens.isDark ? 0.32 : 0.22) : baseColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isChecked ? checkColor : Colors.transparent,
                border: Border.all(color: checkColor, width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isChecked
                  ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: isChecked ? tokens.textPrimary : accent.text,
                  fontWeight: isChecked ? FontWeight.w600 : FontWeight.w500,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

