import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/emotion_definition.dart';
import '../models/emotion_history_entry.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class EmotionTrendsView extends StatelessWidget {
  const EmotionTrendsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final tokens = AppTheme.tokens(context);
        final textTheme = Theme.of(context).textTheme;
        final usageCounts = appState.emotionUsageCounts(window: const Duration(days: 7));
        final history = appState.recentEmotionHistory(limit: 50);
        final emotions = {for (final emotion in appState.emotions) emotion.id: emotion};

        return Scaffold(
          backgroundColor: tokens.backgroundPrimary,
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Back to home',
              onPressed: () => context.read<AppState>().showView(AppView.calmHome),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: const Text('Emotion Patterns'),
            actions: [
              if (history.isNotEmpty)
                IconButton(
                  tooltip: 'Clear history',
                  onPressed: () => _confirmClearHistory(context),
                  icon: const Icon(Icons.delete_sweep_outlined),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummarySection(usageCounts: usageCounts, emotions: emotions, textTheme: textTheme),
                const SizedBox(height: 28),
                _HistorySection(history: history, emotions: emotions, textTheme: textTheme),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmClearHistory(BuildContext context) {
    final appState = context.read<AppState>();
    showDialog<void>(
      context: context,
      builder: (context) {
        final tokens = AppTheme.tokens(context);
        return AlertDialog(
          title: const Text('Clear emotion history?'),
          content: const Text('This removes your recent check-ins. Future sessions will start fresh.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                appState.clearEmotionHistory();
              },
              style: FilledButton.styleFrom(backgroundColor: tokens.accentPrimary),
              child: const Text('Clear history'),
            ),
          ],
        );
      },
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({
    required this.usageCounts,
    required this.emotions,
    required this.textTheme,
  });

  final Map<String, int> usageCounts;
  final Map<String, EmotionDefinition> emotions;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);
    final entries = usageCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (sum, item) => sum + item.value);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.backgroundSecondary,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: tokens.borderSecondary.withValues(alpha: 0.32)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Most visited feelings this week',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: tokens.textPrimary),
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              Text(
                'Explore a few feelings to see trends show up here.',
                style: textTheme.bodyMedium?.copyWith(color: tokens.textSecondary, height: 1.45),
              )
            else
              Column(
                children: [
                  for (final entry in entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _UsageRow(
                        label: emotions[entry.key]?.name ?? entry.key,
                        value: entry.value,
                        total: total,
                        tokens: tokens,
                        textTheme: textTheme,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _UsageRow extends StatelessWidget {
  const _UsageRow({
    required this.label,
    required this.value,
    required this.total,
    required this.tokens,
    required this.textTheme,
  });

  final String label;
  final int value;
  final int total;
  final FeelBetterTheme tokens;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : value / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: tokens.textPrimary),
              ),
            ),
            Text('$value×', style: textTheme.labelLarge?.copyWith(color: tokens.textSecondary)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 10,
            backgroundColor: tokens.borderSecondary.withValues(alpha: 0.28),
            valueColor: AlwaysStoppedAnimation<Color>(tokens.accentPrimary),
          ),
        ),
      ],
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({
    required this.history,
    required this.emotions,
    required this.textTheme,
  });

  final List<EmotionHistoryEntry> history;
  final Map<String, EmotionDefinition> emotions;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.backgroundSecondary,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: tokens.borderSecondary.withValues(alpha: 0.32)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent check-ins',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: tokens.textPrimary),
            ),
            const SizedBox(height: 12),
            if (history.isEmpty)
              Text(
                'Each time you open a feeling, it appears here so you can notice patterns.',
                style: textTheme.bodyMedium?.copyWith(color: tokens.textSecondary, height: 1.45),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final entry = history[index];
                  final emotion = emotions[entry.emotionId];
                  return _HistoryRow(
                    label: emotion?.name ?? entry.emotionId,
                    subtitle: _formatRelative(entry.timestamp),
                    tokens: tokens,
                    textTheme: textTheme,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _formatRelative(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference < const Duration(hours: 1)) {
      final minutes = difference.inMinutes;
      return minutes <= 1 ? 'Just now' : '$minutes minutes ago';
    }
    if (difference < const Duration(hours: 24) && now.day == timestamp.day) {
      final hours = difference.inHours;
      return hours == 1 ? '1 hour ago' : '$hours hours ago';
    }
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    if (timestamp.year == yesterday.year && timestamp.month == yesterday.month && timestamp.day == yesterday.day) {
      return 'Yesterday at ${_formatTime(timestamp)}';
    }
    return '${_monthLabel(timestamp.month)} ${timestamp.day} at ${_formatTime(timestamp)}';
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$formattedHour:$minute $suffix';
  }

  String _monthLabel(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[(month - 1).clamp(0, months.length - 1)];
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.label,
    required this.subtitle,
    required this.tokens,
    required this.textTheme,
  });

  final String label;
  final String subtitle;
  final FeelBetterTheme tokens;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.backgroundPrimary.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: tokens.borderSecondary.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Icon(Icons.bubble_chart_rounded, color: tokens.accentPrimary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: tokens.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(color: tokens.textSecondary, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
