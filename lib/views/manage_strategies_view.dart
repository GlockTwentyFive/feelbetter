import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/emotion_definition.dart';
import '../models/strategy_models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/emotion_icon.dart';

class ManageStrategiesView extends StatefulWidget {
  const ManageStrategiesView({super.key, required this.emotionId});

  final String emotionId;

  @override
  State<ManageStrategiesView> createState() => _ManageStrategiesViewState();
}

enum _StrategyAction { edit, delete }

enum _StrategyGroup {
  personal('My care plan', Icons.self_improvement_rounded),
  relationship('Support network', Icons.diversity_3_rounded);

  const _StrategyGroup(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _RelationshipStrategyList extends StatelessWidget {
  const _RelationshipStrategyList({super.key, required this.meta, required this.items});

  final _CategoryMeta meta;
  final List<StrategyItem> items;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);
    final textTheme = Theme.of(context).textTheme;

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            meta.emptyHint,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(color: tokens.textSecondary),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
      children: [
        Text(
          meta.intro,
          style: textTheme.bodyMedium?.copyWith(color: tokens.textSecondary, height: 1.45),
        ),
        const SizedBox(height: 18),
        for (var i = 0; i < items.length; i++) ...[
          _RelationshipStrategyCard(item: items[i], meta: meta),
          if (i != items.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _PersonalStrategyColumn extends StatelessWidget {
  const _PersonalStrategyColumn({
    super.key,
    required this.emotionId,
    required this.tokens,
    required this.categories,
    required this.strategySet,
    required this.isCompact,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.openForm,
  });

  final String emotionId;
  final FeelBetterTheme tokens;
  final List<_CategoryMeta> categories;
  final EmotionStrategySet strategySet;
  final bool isCompact;
  final StrategyCategory selectedCategory;
  final ValueChanged<StrategyCategory> onCategoryChanged;
  final void Function(StrategyCategory category, StrategyItem? item) openForm;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final currentMeta = categories.firstWhere((meta) => meta.category == selectedCategory);
    final items = currentMeta.itemsFor(strategySet);
    final palette = tokens.emotion(currentMeta.paletteKey);

    return ListView(
      padding: EdgeInsets.fromLTRB(16, isCompact ? 16 : 24, 16, isCompact ? 112 : 128),
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.backgroundSecondary.withValues(alpha: tokens.isDark ? 0.85 : 0.95),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: tokens.borderSecondary.withValues(alpha: 0.24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Focus area',
                  style: textTheme.labelMedium?.copyWith(
                    color: tokens.textSecondary,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final meta in categories)
                      FilterChip(
                        selected: meta.category == selectedCategory,
                        onSelected: (_) => onCategoryChanged(meta.category!),
                        avatar: Icon(meta.icon, size: 18, color: tokens.textSecondary.withValues(alpha: 0.8)),
                        selectedColor: tokens.emotion(meta.paletteKey).background.withValues(alpha: tokens.isDark ? 0.65 : 0.45),
                        backgroundColor: tokens.backgroundPrimary.withValues(alpha: tokens.isDark ? 0.28 : 0.5),
                        checkmarkColor: tokens.textPrimary,
                        label: Text(meta.label),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          currentMeta.intro,
          style: textTheme.bodyMedium?.copyWith(color: tokens.textSecondary, height: 1.45),
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          Column(
            children: [
              Icon(Icons.lightbulb_outline_rounded, size: 44, color: palette.solid),
              const SizedBox(height: 12),
              Text(
                currentMeta.emptyHint,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: tokens.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () => openForm(currentMeta.category!, null),
                icon: const Icon(Icons.add_task_rounded),
                label: const Text('Create a first checkpoint'),
              ),
            ],
          )
        else
          ReorderableListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: items.length,
            onReorder: (oldIndex, newIndex) {
              context.read<AppState>().reorderStrategyItems(emotionId, currentMeta.category!, oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final item = items[index];
              return _StrategyRow(
                key: ValueKey(item.id),
                item: item,
                category: currentMeta.category!,
                emotionId: emotionId,
                onEdit: () => openForm(currentMeta.category!, item),
                index: index,
                isCompact: isCompact,
              );
            },
          ),
      ],
    );
  }
}

class _RelationshipStrategyCard extends StatelessWidget {
  const _RelationshipStrategyCard({required this.item, required this.meta});

  final StrategyItem item;
  final _CategoryMeta meta;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);
    final textTheme = Theme.of(context).textTheme;
    final palette = tokens.emotion(meta.paletteKey);
    final instructions = item.instructions;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        decoration: BoxDecoration(
          color: tokens.backgroundSecondary,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: tokens.borderSecondary.withValues(alpha: 0.28)),
          boxShadow: [
            BoxShadow(
              color: tokens.shadowColor.withValues(alpha: tokens.isDark ? 0.28 : 0.16),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                EmotionIcon(icon: meta.icon, paletteKey: meta.paletteKey, size: 34),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: tokens.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            if (instructions.isNotEmpty) ...[
              const SizedBox(height: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < instructions.length; i++)
                    Padding(
                      padding: EdgeInsets.only(bottom: i == instructions.length - 1 ? 0 : 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('•', style: textTheme.bodyMedium?.copyWith(color: palette.text)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              instructions[i],
                              style: textTheme.bodyMedium?.copyWith(color: tokens.textSecondary, height: 1.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 12),
              Text(
                'No checkpoints included. Use the web experience to add them.',
                style: textTheme.bodySmall?.copyWith(color: tokens.textSecondary, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ManageStrategiesViewState extends State<ManageStrategiesView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late List<_CategoryMeta> _categories;
  late List<_CategoryMeta> _relationshipCategories;
  late List<_CategoryMeta> _personalCategories;
  late _StrategyGroup _currentGroup;
  late StrategyCategory _selectedPersonalCategory;

  @override
  void initState() {
    super.initState();
    _categories = const [
      _CategoryMeta.editable(
        category: StrategyCategory.immediate,
        label: 'Immediate',
        intro: 'Start with one simple checkpoint you can do right now.',
        emptyHint: 'No immediate strategies yet. Tap “Add strategy” to create one.',
        icon: Icons.bolt_rounded,
        paletteKey: 'rose',
      ),
      _CategoryMeta.editable(
        category: StrategyCategory.shortTerm,
        label: 'Short term',
        intro: 'Add steps you can take in the next few hours.',
        emptyHint: 'No short-term strategies yet. Tap “Add strategy” to create one.',
        icon: Icons.access_time_filled_rounded,
        paletteKey: 'teal',
      ),
      _CategoryMeta.editable(
        category: StrategyCategory.longTerm,
        label: 'Long term',
        intro: 'Capture routines that keep the change going.',
        emptyHint: 'No long-term strategies yet. Tap “Add strategy” to create one.',
        icon: Icons.eco_rounded,
        paletteKey: 'slate',
      ),
      _CategoryMeta.readOnly(
        relationship: _RelationshipCategory.supportingFriend,
        label: 'Relationship support',
        intro: 'Bring someone alongside you with co-regulation ideas.',
        emptyHint: 'No relationship support strategies available yet.',
        icon: Icons.diversity_3_rounded,
        paletteKey: 'violet',
      ),
      _CategoryMeta.readOnly(
        relationship: _RelationshipCategory.repairingWhenResponsible,
        label: 'Repair & reconnect',
        intro: 'Steps to make things right when you contributed to the feeling.',
        emptyHint: 'No repair strategies available yet.',
        icon: Icons.healing_rounded,
        paletteKey: 'amber',
      ),
    ];
    _personalCategories = _categories.where((meta) => meta.isEditable).toList(growable: false);
    _relationshipCategories = _categories.where((meta) => !meta.isEditable).toList(growable: false);
    _tabController = TabController(length: _relationshipCategories.length, vsync: this);
    _currentGroup = _StrategyGroup.personal;
    _selectedPersonalCategory = _personalCategories.first.category!;
    _tabController.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);
    final textTheme = Theme.of(context).textTheme;

    return Consumer<AppState>(
      builder: (context, appState, child) {
        final emotion = appState.emotionById(widget.emotionId) ??
            EmotionDefinition(id: widget.emotionId, name: widget.emotionId);
        final strategySet = appState.strategySetFor(widget.emotionId);
        final width = MediaQuery.of(context).size.width;
        final isCompact = width < 640;
        final tabIsScrollable = isCompact;
        final selectedMeta = _personalCategories.firstWhere((meta) => meta.category == _selectedPersonalCategory);
        final bottomHeight = _currentGroup == _StrategyGroup.personal
            ? (isCompact ? 82.0 : 94.0)
            : (isCompact ? 132.0 : 148.0);

        return Scaffold(
          backgroundColor: tokens.backgroundPrimary,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Manage strategies',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isCompact ? 2 : 4),
                Text(
                  emotion.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelLarge?.copyWith(color: tokens.textSecondary),
                ),
              ],
            ),
            toolbarHeight: isCompact ? 72 : null,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(bottomHeight),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final group in _StrategyGroup.values)
                          ChoiceChip(
                            label: Text(group.label),
                            avatar: Icon(group.icon, size: 18),
                            selected: _currentGroup == group,
                            selectedColor: Theme.of(context).colorScheme.secondaryContainer,
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
                            labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: _currentGroup == group ? FontWeight.w600 : FontWeight.w500,
                                ),
                            onSelected: (selected) {
                              if (!selected) return;
                              setState(() {
                                _currentGroup = group;
                              });
                            },
                          ),
                      ],
                    ),
                    if (_currentGroup == _StrategyGroup.relationship)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: tabIsScrollable,
                          tabAlignment: tabIsScrollable ? TabAlignment.start : TabAlignment.fill,
                          labelPadding: tabIsScrollable ? const EdgeInsets.symmetric(horizontal: 12) : null,
                          tabs: _relationshipCategories
                              .map(
                                (meta) => Tab(
                                  height: isCompact ? 56 : null,
                                  iconMargin: EdgeInsets.only(bottom: isCompact ? 2 : 6),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      EmotionIcon(icon: meta.icon, paletteKey: meta.paletteKey, size: isCompact ? 18 : 20),
                                      const SizedBox(height: 4),
                                      Flexible(
                                        child: Text(
                                          meta.label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: _currentGroup == _StrategyGroup.personal
              ? FloatingActionButton.extended(
                  onPressed: () => _openStrategyForm(context, strategySet, _selectedPersonalCategory, null),
                  icon: const Icon(Icons.add_task_rounded),
                  label: Text('Add ${selectedMeta.label.toLowerCase()} step'),
                )
              : null,
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutQuad,
            switchOutCurve: Curves.easeInQuad,
            child: _currentGroup == _StrategyGroup.personal
                ? _PersonalStrategyColumn(
                    key: const ValueKey('personal-strategies'),
                    emotionId: widget.emotionId,
                    tokens: tokens,
                    categories: _personalCategories,
                    strategySet: strategySet,
                    isCompact: isCompact,
                    selectedCategory: _selectedPersonalCategory,
                    onCategoryChanged: (category) {
                      setState(() {
                        _selectedPersonalCategory = category;
                      });
                    },
                    openForm: (category, item) => _openStrategyForm(context, strategySet, category, item),
                  )
                : TabBarView(
                    key: const ValueKey('relationship-strategies'),
                    controller: _tabController,
                    children: _relationshipCategories
                        .map(
                          (meta) {
                            final items = meta.itemsFor(strategySet);
                            return _RelationshipStrategyList(
                              key: PageStorageKey('${widget.emotionId}-${meta.storageKey}'),
                              meta: meta,
                              items: items,
                            );
                          },
                        )
                        .toList(),
                  ),
          ),
        );
      },
    );
  }

  void _openStrategyForm(
    BuildContext context,
    EmotionStrategySet set,
    StrategyCategory category,
    StrategyItem? existing,
  ) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return _StrategyFormSheet(
          emotionId: widget.emotionId,
          category: category,
          existing: existing,
        );
      },
    );
  }
}

class _StrategyRow extends StatefulWidget {
  const _StrategyRow({
    super.key,
    required this.item,
    required this.category,
    required this.emotionId,
    required this.onEdit,
    required this.index,
    required this.isCompact,
  });

  final StrategyItem item;
  final StrategyCategory category;
  final String emotionId;
  final VoidCallback onEdit;
  final int index;
  final bool isCompact;

  @override
  State<_StrategyRow> createState() => _StrategyRowState();
}

class _StrategyRowState extends State<_StrategyRow> {
  late List<bool> _checks;
  bool _celebrated = false;

  @override
  void initState() {
    super.initState();
    _checks = List<bool>.filled(widget.item.instructions.length, false);
  }

  @override
  void didUpdateWidget(covariant _StrategyRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.instructions != widget.item.instructions) {
      _checks = List<bool>.filled(widget.item.instructions.length, false);
      _celebrated = false;
    }
  }

  bool get _allComplete => _checks.isNotEmpty && _checks.every((value) => value);

  void _toggle(int index) {
    if (index < 0 || index >= _checks.length) return;
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

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);
    final textTheme = Theme.of(context).textTheme;
    final instructions = widget.item.instructions;

    return Padding(
      key: widget.key,
      padding: EdgeInsets.only(bottom: widget.isCompact ? 12 : 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: widget.onEdit,
          child: Ink(
            padding: EdgeInsets.symmetric(
              horizontal: widget.isCompact ? 16 : 20,
              vertical: widget.isCompact ? 16 : 18,
            ),
            decoration: BoxDecoration(
              color: tokens.backgroundSecondary,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: tokens.borderSecondary.withValues(alpha: 0.32)),
              boxShadow: [
                BoxShadow(
                  color: tokens.shadowColor.withValues(alpha: tokens.isDark ? 0.28 : 0.16),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
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
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.item.title,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: tokens.textPrimary,
                                    fontSize: widget.isCompact ? 15 : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              AnimatedScale(
                                duration: const Duration(milliseconds: 420),
                                curve: Curves.easeOutBack,
                                scale: _celebrated ? 1 : 0.0,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 320),
                                  opacity: _celebrated ? 1 : 0,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: tokens.accentPrimary.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(Icons.auto_awesome_rounded, color: tokens.accentPrimary, size: 20),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (instructions.isEmpty)
                            Text(
                              'No checkpoints yet. Tap edit to add some.',
                              style: textTheme.bodySmall?.copyWith(color: tokens.textSecondary, height: 1.45),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: widget.isCompact ? 8 : 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupMenuButton<_StrategyAction>(
                          tooltip: 'Strategy options',
                          padding: EdgeInsets.zero,
                          position: PopupMenuPosition.under,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          icon: Icon(
                            Icons.more_vert_rounded,
                            size: widget.isCompact ? 20 : 22,
                            color: tokens.textSecondary.withValues(alpha: 0.8),
                          ),
                          onSelected: (action) {
                            switch (action) {
                              case _StrategyAction.edit:
                                widget.onEdit();
                                break;
                              case _StrategyAction.delete:
                                _confirmRemove(context);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: _StrategyAction.edit,
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18, color: tokens.textSecondary),
                                  const SizedBox(width: 10),
                                  const Text('Edit strategy'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: _StrategyAction.delete,
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 18, color: tokens.textSecondary),
                                  const SizedBox(width: 10),
                                  const Text('Remove strategy'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        ReorderableDragStartListener(
                          index: widget.index,
                          child: Icon(
                            Icons.drag_handle_rounded,
                            color: tokens.textSecondary.withValues(alpha: 0.7),
                            size: widget.isCompact ? 20 : 22,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (instructions.isNotEmpty) ...[
                  SizedBox(height: widget.isCompact ? 10 : 14),
                  Column(
                    children: [
                      for (var i = 0; i < instructions.length; i++)
                        Padding(
                          padding: EdgeInsets.only(bottom: i == instructions.length - 1 ? 0 : (widget.isCompact ? 8 : 10)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _toggle(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOut,
                              decoration: BoxDecoration(
                                color: _checks[i]
                                    ? tokens.backgroundSecondary.withValues(alpha: tokens.isDark ? 0.38 : 0.18)
                                    : tokens.backgroundPrimary.withValues(alpha: tokens.isDark ? 0.25 : 0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: tokens.borderSecondary.withValues(alpha: _checks[i] ? 0.6 : 0.3),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: widget.isCompact ? 12 : 14,
                                vertical: widget.isCompact ? 10 : 12,
                              ),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 220),
                                    curve: Curves.easeOut,
                                    width: widget.isCompact ? 20 : 22,
                                    height: widget.isCompact ? 20 : 22,
                                    decoration: BoxDecoration(
                                      color: _checks[i]
                                          ? tokens.accentPrimary.withValues(alpha: tokens.isDark ? 0.9 : 0.8)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: tokens.accentPrimary.withValues(alpha: 0.6), width: 2),
                                    ),
                                    child: _checks[i]
                                        ? Icon(Icons.check_rounded, size: widget.isCompact ? 14 : 16, color: Colors.white)
                                        : null,
                                  ),
                                  SizedBox(width: widget.isCompact ? 10 : 12),
                                  Expanded(
                                    child: Text(
                                      instructions[i],
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: _checks[i] ? tokens.textPrimary : tokens.textSecondary,
                                        fontWeight: _checks[i] ? FontWeight.w600 : FontWeight.w500,
                                        height: 1.45,
                                        fontSize: widget.isCompact ? 13 : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmRemove(BuildContext context) {
    final appState = context.read<AppState>();
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove strategy?'),
          content: const Text('This step will be lost. You can add a new one whenever you like.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                appState.removeStrategyItem(widget.emotionId, widget.category, widget.item.id);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}

class _StrategyFormSheet extends StatefulWidget {
  const _StrategyFormSheet({
    required this.emotionId,
    required this.category,
    this.existing,
  });

  final String emotionId;
  final StrategyCategory category;
  final StrategyItem? existing;

  @override
  State<_StrategyFormSheet> createState() => _StrategyFormSheetState();
}

class _StrategyFormSheetState extends State<_StrategyFormSheet> {
  late TextEditingController _titleController;
  late TextEditingController _instructionsController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existing?.title ?? '');
    _instructionsController = TextEditingController(
      text: widget.existing?.instructions.join('\n') ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);
    final textTheme = Theme.of(context).textTheme;
    final isEditing = widget.existing != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 28,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Edit strategy' : 'Add a new strategy',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Strategy title'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please give this strategy a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Checkpoints (one per line)',
                hintText: 'Slow your breath\nNotice one body sensation',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    final instructions = _instructionsController.text
                        .split('\n')
                        .map((line) => line.trim())
                        .where((line) => line.isNotEmpty)
                        .toList();
                    final appState = context.read<AppState>();
                    if (isEditing) {
                      final updated = widget.existing!.copyWith(
                        title: _titleController.text.trim(),
                        instructions: instructions,
                      );
                      appState.updateStrategyItem(widget.emotionId, widget.category, updated);
                    } else {
                      final newItem = StrategyItem(
                        id: _generateId(),
                        title: _titleController.text.trim(),
                        instructions: instructions,
                      );
                      appState.addStrategyItem(widget.emotionId, widget.category, newItem);
                    }
                    Navigator.of(context).pop();
                  },
                  style: FilledButton.styleFrom(backgroundColor: tokens.accentPrimary),
                  child: Text(isEditing ? 'Save strategy' : 'Add strategy'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _generateId() {
    final random = Random().nextInt(900000) + 100000;
    return 'strategy-$random';
  }
}

class _CategoryMeta {
  const _CategoryMeta._({
    required this.category,
    required this.relationship,
    required this.label,
    required this.intro,
    required this.emptyHint,
    required this.icon,
    required this.paletteKey,
    required this.isEditable,
  });

  const _CategoryMeta.editable({
    required StrategyCategory category,
    required String label,
    required String intro,
    required String emptyHint,
    required IconData icon,
    required String paletteKey,
  }) : this._(
          category: category,
          relationship: null,
          label: label,
          intro: intro,
          emptyHint: emptyHint,
          icon: icon,
          paletteKey: paletteKey,
          isEditable: true,
        );

  const _CategoryMeta.readOnly({
    required _RelationshipCategory relationship,
    required String label,
    required String intro,
    required String emptyHint,
    required IconData icon,
    required String paletteKey,
  }) : this._(
          category: null,
          relationship: relationship,
          label: label,
          intro: intro,
          emptyHint: emptyHint,
          icon: icon,
          paletteKey: paletteKey,
          isEditable: false,
        );

  final StrategyCategory? category;
  final _RelationshipCategory? relationship;
  final String label;
  final String intro;
  final String emptyHint;
  final IconData icon;
  final String paletteKey;
  final bool isEditable;

  String get storageKey => category != null ? category!.name : 'rel-${relationship!.name}';

  List<StrategyItem> itemsFor(EmotionStrategySet set) {
    if (category != null) {
      return set.listFor(category!);
    }
    switch (relationship!) {
      case _RelationshipCategory.supportingFriend:
        return set.supportingFriend;
      case _RelationshipCategory.repairingWhenResponsible:
        return set.repairingWhenResponsible;
    }
  }
}

enum _RelationshipCategory { supportingFriend, repairingWhenResponsible }
