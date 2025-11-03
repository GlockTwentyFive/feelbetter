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
    _tabController = TabController(length: _categories.length, vsync: this);
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

        return Scaffold(
          backgroundColor: tokens.backgroundPrimary,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Manage strategies'),
                Text(
                  emotion.name,
                  style: textTheme.labelLarge?.copyWith(color: tokens.textSecondary),
                ),
              ],
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: _categories
                  .map(
                    (meta) => Tab(
                      text: meta.label,
                      icon: EmotionIcon(icon: meta.icon, paletteKey: meta.paletteKey, size: 20),
                    ),
                  )
                  .toList(),
            ),
          ),
          floatingActionButton: _categories[_tabController.index].isEditable
              ? FloatingActionButton.extended(
                  onPressed: () => _openStrategyForm(context, strategySet, _categories[_tabController.index].category!, null),
                  icon: const Icon(Icons.add_task_rounded),
                  label: const Text('Add strategy'),
                )
              : null,
          body: TabBarView(
            controller: _tabController,
            children: _categories
                .map(
                  (meta) {
                    final items = meta.itemsFor(strategySet);
                    if (meta.isEditable) {
                      return _StrategyList(
                        key: PageStorageKey('${widget.emotionId}-${meta.storageKey}'),
                        emotionId: widget.emotionId,
                        category: meta.category!,
                        items: items,
                        onEdit: (item) => _openStrategyForm(context, strategySet, meta.category!, item),
                        emptyHint: meta.emptyHint,
                      );
                    }
                    return _RelationshipStrategyList(
                      key: PageStorageKey('${widget.emotionId}-${meta.storageKey}'),
                      meta: meta,
                      items: items,
                    );
                  },
                )
                .toList(),
          ),
        );
      },
    );
  }

  StrategyCategory? get currentCategory => _categories[_tabController.index].category;

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

class _StrategyList extends StatelessWidget {
  const _StrategyList({
    super.key,
    required this.emotionId,
    required this.category,
    required this.items,
    required this.onEdit,
    required this.emptyHint,
  });

  final String emotionId;
  final StrategyCategory category;
  final List<StrategyItem> items;
  final ValueChanged<StrategyItem> onEdit;
  final String emptyHint;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            emptyHint,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: tokens.textSecondary),
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      itemCount: items.length,
      onReorder: (oldIndex, newIndex) {
        context.read<AppState>().reorderStrategyItems(emotionId, category, oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final item = items[index];
        return _StrategyRow(
          key: ValueKey(item.id),
          item: item,
          category: category,
          emotionId: emotionId,
          onEdit: () => onEdit(item),
          index: index,
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
  });

  final StrategyItem item;
  final StrategyCategory category;
  final String emotionId;
  final VoidCallback onEdit;
  final int index;

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
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: widget.onEdit,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Edit strategy',
                          onPressed: widget.onEdit,
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: 'Remove strategy',
                          onPressed: () => _confirmRemove(context),
                          icon: const Icon(Icons.delete_outline),
                        ),
                        ReorderableDragStartListener(
                          index: widget.index,
                          child: Icon(
                            Icons.drag_handle_rounded,
                            color: tokens.textSecondary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (instructions.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Column(
                    children: [
                      for (var i = 0; i < instructions.length; i++)
                        Padding(
                          padding: EdgeInsets.only(bottom: i == instructions.length - 1 ? 0 : 10),
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
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 220),
                                    curve: Curves.easeOut,
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: _checks[i]
                                          ? tokens.accentPrimary.withValues(alpha: tokens.isDark ? 0.9 : 0.8)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: tokens.accentPrimary.withValues(alpha: 0.6), width: 2),
                                    ),
                                    child: _checks[i]
                                        ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      instructions[i],
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: _checks[i] ? tokens.textPrimary : tokens.textSecondary,
                                        fontWeight: _checks[i] ? FontWeight.w600 : FontWeight.w500,
                                        height: 1.45,
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
