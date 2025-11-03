import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/journal_entry.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/emotion_icon.dart';
import '../widgets/edit_journal_sheet.dart';

class JournalView extends StatefulWidget {
  const JournalView({super.key});

  @override
  State<JournalView> createState() => _JournalViewState();
}

class _JournalViewState extends State<JournalView> {
  JournalEntry? _editingEntry;
  bool _isNewEntry = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final entries = appState.journalEntries;
        final grouped = _groupEntries(entries);

        if (_editingEntry != null) {
          return EditJournalSheet(
            entry: _editingEntry!,
            isNew: _isNewEntry,
            onCancel: () => setState(() => _editingEntry = null),
            onSave: (entry) {
              appState.saveJournalEntry(entry);
              setState(() => _editingEntry = null);
              _isNewEntry = false;
            },
            onDelete: _isNewEntry
                ? null
                : (id) {
                    appState.deleteJournalEntry(id);
                    setState(() => _editingEntry = null);
                  },
          );
        }

        final tokens = AppTheme.tokens(context);

        return LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 720;
            final horizontal = isCompact ? 18.0 : 40.0;
            return Scaffold(
              backgroundColor: tokens.backgroundPrimary,
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () => _openEditor(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('New note'),
                backgroundColor: tokens.accentPrimary,
                foregroundColor: tokens.textOnAccent,
              ),
              body: SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontal,
                        28,
                        horizontal,
                        horizontal + 120,
                      ),
                      sliver: SliverList.list(
                        children: [
                          _JournalHeroHeader(onBack: () => appState.showView(AppView.calmHome)),
                          const SizedBox(height: 28),
                          const _JournalPromptsStrip(),
                          const SizedBox(height: 32),
                          if (grouped.isEmpty)
                            const _EmptyState()
                          else
                            ...grouped.entries.map(
                              (entry) => _JournalSection(
                                label: entry.key,
                                entries: entry.value,
                                onTap: (JournalEntry selected) {
                                  setState(() {
                                    _editingEntry = selected;
                                    _isNewEntry = false;
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openEditor(BuildContext context) {
    final newEntry = JournalEntry(
      id: 'journal-${DateTime.now().millisecondsSinceEpoch}',
      title: '',
      content: '',
      timestamp: DateTime.now(),
    );
    setState(() {
      _editingEntry = newEntry;
      _isNewEntry = true;
    });
  }

  Map<String, List<JournalEntry>> _groupEntries(List<JournalEntry> entries) {
    final sorted = [...entries]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final result = <String, List<JournalEntry>>{};
    for (final entry in sorted) {
      final date = DateTime(entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
      final label = _relativeDateLabel(date);
      result.putIfAbsent(label, () => []).add(entry);
    }
    return result;
  }

  String _relativeDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';
    return '${_weekdayLabel(date.weekday)}, ${_monthLabel(date.month)} ${date.day}, ${date.year}';
  }

  String _weekdayLabel(int weekday) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[(weekday - 1) % weekdays.length];
  }

  String _monthLabel(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[(month - 1) % months.length];
  }
}

class _JournalSection extends StatelessWidget {
  const _JournalSection({required this.label, required this.entries, required this.onTap});

  final String label;
  final List<JournalEntry> entries;
  final ValueChanged<JournalEntry> onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
      decoration: BoxDecoration(
        color: tokens.backgroundSecondary,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: tokens.borderSecondary.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: 18),
          Column(
            children: [
              for (final entry in entries)
                Padding(
                  padding: EdgeInsets.only(bottom: entry == entries.last ? 4 : 14),
                  child: _JournalTile(
                    entry: entry,
                    onTap: () => onTap(entry),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JournalTile extends StatelessWidget {
  const _JournalTile({required this.entry, required this.onTap});

  final JournalEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);
    final timeString = TimeOfDay.fromDateTime(entry.timestamp).format(context);
    final preview = entry.content.isEmpty
        ? 'No additional content.'
        : entry.content.length > 120
            ? '${entry.content.substring(0, 117)}…'
            : entry.content;
    return _JournalCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title.isEmpty ? 'Untitled entry' : entry.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600, color: tokens.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  preview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: tokens.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            timeString,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: tokens.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _JournalCard extends StatefulWidget {
  const _JournalCard({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<_JournalCard> createState() => _JournalCardState();
}

class _JournalCardState extends State<_JournalCard> {
  bool _hovered = false;
  bool _pressed = false;

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);
    final cardRadius = BorderRadius.circular(20);

    return FocusableActionDetector(
      onShowFocusHighlight: _setHovered,
      child: MouseRegion(
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          scale: _pressed
              ? 0.97
              : _hovered
                  ? 1.01
                  : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: cardRadius,
              color: tokens.backgroundSecondary,
              border: Border.all(
                color: _hovered || _pressed
                    ? tokens.accentRing.withValues(alpha: 0.55)
                    : tokens.borderSecondary,
              ),
              boxShadow: [
                BoxShadow(
                  color: tokens.shadowColor.withValues(alpha: _hovered ? 0.18 : 0.08),
                  blurRadius: _hovered ? 20 : 12,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: cardRadius,
                onTap: widget.onTap,
                onTapDown: (_) => _setPressed(true),
                onTapCancel: () => _setPressed(false),
                onTapUp: (_) => _setPressed(false),
                onHover: _setHovered,
                splashColor: tokens.accentRing.withValues(alpha: 0.18),
                highlightColor: tokens.backgroundHover.withValues(alpha: 0.45),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.backgroundSecondary,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: tokens.borderSecondary.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 56),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded, size: 52, color: tokens.accentPrimary.withValues(alpha: 0.9)),
            const SizedBox(height: 18),
            Text(
              'No reflections yet',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Start with one sentence about how your nervous system is arriving.',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: tokens.textSecondary,
                height: 1.48,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JournalHeroHeader extends StatelessWidget {
  const _JournalHeroHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tokens.accentPrimary.withValues(alpha: 0.16),
            tokens.accentRing.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: tokens.accentRing.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 26, 28, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  tooltip: 'Back to home',
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                  style: IconButton.styleFrom(
                    foregroundColor: tokens.textSecondary,
                    backgroundColor: tokens.backgroundPrimary.withValues(alpha: 0.92),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Journal',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: tokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Name what is present. Celebrate a micro-win. Note a tiny sensation. The page will hold it.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: tokens.textSecondary,
                          height: 1.52,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.auto_stories_rounded, color: tokens.accentPrimary.withValues(alpha: 0.9)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tip: 3 slow breaths, one sentence, one word of gratitude.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: tokens.textSecondary,
                    ),
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

class _JournalPromptsStrip extends StatelessWidget {
  const _JournalPromptsStrip();

  @override
  Widget build(BuildContext context) {
    const prompts = [
      _PromptInfo(
        icon: Icons.cloud_queue_rounded,
        paletteKey: 'blue',
        title: 'Weather check-in',
        description: 'Describe the energy in your body using a weather metaphor.',
      ),
      _PromptInfo(
        icon: Icons.psychology_rounded,
        paletteKey: 'slate',
        title: 'One thought to release',
        description: 'Write the sentence you’d like to leave on this page.',
      ),
      _PromptInfo(
        icon: Icons.favorite_border_rounded,
        paletteKey: 'rose',
        title: 'Tiny gratitude',
        description: 'Name a micro-moment of care you noticed today.',
      ),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: prompts
          .map(
            (prompt) => _PromptCard(info: prompt),
          )
          .toList(),
    );
  }
}

class _PromptInfo {
  const _PromptInfo({
    required this.icon,
    required this.paletteKey,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String paletteKey;
  final String title;
  final String description;
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({required this.info});

  final _PromptInfo info;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.backgroundSecondary,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: tokens.borderSecondary.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EmotionIcon(icon: info.icon, paletteKey: info.paletteKey, size: 28),
            const SizedBox(height: 14),
            Text(
              info.title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              info.description,
              style: textTheme.bodyMedium?.copyWith(
                color: tokens.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
