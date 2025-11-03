import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/emotion_definition.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/emotion_icon.dart';
import 'manage_strategies_view.dart';

class ManageEmotionsView extends StatelessWidget {
  const ManageEmotionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final tokens = AppTheme.tokens(context);
        final textTheme = Theme.of(context).textTheme;
        final emotions = appState.emotions;

        final body = emotions.isEmpty
            ? _EmptyState(textTheme: textTheme)
            : _EmotionGridView(
                emotions: emotions,
                onEdit: (emotion) => _showEditEmotionSheet(context, emotion),
                onDelete: (emotion) => _confirmRemoveEmotion(context, emotion),
                onTap: (emotion) => _showManageStrategies(context, emotion.id),
              );

        return Scaffold(
          backgroundColor: tokens.backgroundPrimary,
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Back to home',
              onPressed: () => context.read<AppState>().showView(AppView.calmHome),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: const Text('Feeling Library'),
            actions: [
              IconButton(
                tooltip: 'Arrange feelings',
                onPressed: () => _showReorderSheet(context),
                icon: const Icon(Icons.swap_vert_rounded),
              ),
              TextButton.icon(
                onPressed: () => _showAddEmotionSheet(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add feeling'),
              ),
            ],
          ),
          body: body,
        );
      },
    );
  }

  void _showAddEmotionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => _EmotionFormSheet(onSubmit: (definition) {
        Navigator.of(context).pop();
        context.read<AppState>().addEmotion(definition);
      }),
    );
  }

  void _showEditEmotionSheet(BuildContext context, EmotionDefinition definition) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => _EmotionFormSheet(
        existing: definition,
        onSubmit: (updated) {
          Navigator.of(context).pop();
          context.read<AppState>().updateEmotion(definition.id, updated.copyWith(id: definition.id));
        },
      ),
    );
  }

  void _confirmRemoveEmotion(BuildContext context, EmotionDefinition definition) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        final tokens = AppTheme.tokens(context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Remove ${definition.name}?',
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: tokens.textPrimary),
              ),
              const SizedBox(height: 10),
              Text(
                'This will take away the steps for this feeling, but you can add it again whenever you want.',
                style: textTheme.bodyMedium?.copyWith(color: tokens.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Keep it'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.read<AppState>().removeEmotion(definition.id);
                    },
                    style: FilledButton.styleFrom(backgroundColor: tokens.accentPrimary),
                    child: const Text('Let it go'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showManageStrategies(BuildContext context, String emotionId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ManageStrategiesView(emotionId: emotionId),
      ),
    );
  }

  void _showReorderSheet(BuildContext context) {
    final appState = context.read<AppState>();
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        final tokens = AppTheme.tokens(context);
        final textTheme = Theme.of(context).textTheme;
        var emotions = List<EmotionDefinition>.from(appState.emotions);
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Arrange these feeling cards',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: tokens.backgroundSecondary,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: tokens.borderSecondary.withValues(alpha: 0.24)),
                    ),
                    child: SizedBox(
                      height: 320,
                      child: ReorderableListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        itemCount: emotions.length,
                        onReorder: (oldIndex, newIndex) {
                          if (newIndex > oldIndex) newIndex -= 1;
                          appState.reorderEmotions(oldIndex, newIndex);
                          setState(() => emotions = List<EmotionDefinition>.from(appState.emotions));
                        },
                        itemBuilder: (context, index) {
                          final emotion = emotions[index];
                          return ListTile(
                            key: ValueKey(emotion.id),
                            leading: const Icon(Icons.drag_handle_rounded),
                            title: Text(emotion.name),
                            subtitle: emotion.synonyms.isEmpty
                                ? null
                                : Text(
                                    emotion.synonyms.join(', '),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(backgroundColor: tokens.accentPrimary),
                    child: const Text('That feels right'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sentiment_satisfied_alt_rounded, color: tokens.accentPrimary, size: 48),
            const SizedBox(height: 16),
            Text(
              'No feelings saved yet',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: tokens.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Add the feelings you notice often so their calming steps stay close by.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: tokens.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmotionGridView extends StatelessWidget {
  const _EmotionGridView({
    required this.emotions,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final List<EmotionDefinition> emotions;
  final ValueChanged<EmotionDefinition> onTap;
  final ValueChanged<EmotionDefinition> onEdit;
  final ValueChanged<EmotionDefinition> onDelete;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTheme.tokens(context);
    final textTheme = Theme.of(context).textTheme;
    const paletteKeys = ['amber', 'purple', 'teal', 'rose', 'blue', 'slate'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnWidth = 260.0;
        final maxCrossAxisCount = (constraints.maxWidth / columnWidth).floor().clamp(1, 4);
        final crossAxisCount = maxCrossAxisCount < 1 ? 1 : maxCrossAxisCount;

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 18,
            crossAxisSpacing: 18,
            childAspectRatio: 0.85,
          ),
          itemCount: emotions.length,
          itemBuilder: (context, index) {
            final emotion = emotions[index];
            final paletteKey = paletteKeys[index % paletteKeys.length];
            return _EmotionTile(
              emotion: emotion,
              paletteKey: paletteKey,
              tokens: tokens,
              textTheme: textTheme,
              onTap: () => onTap(emotion),
              onEdit: () => onEdit(emotion),
              onDelete: () => onDelete(emotion),
            );
          },
        );
      },
    );
  }
}

class _EmotionTile extends StatelessWidget {
  const _EmotionTile({
    required this.emotion,
    required this.paletteKey,
    required this.tokens,
    required this.textTheme,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final EmotionDefinition emotion;
  final String paletteKey;
  final FeelBetterTheme tokens;
  final TextTheme textTheme;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final synonyms = emotion.synonyms.isEmpty ? 'No synonyms yet' : emotion.synonyms.join(', ');

    final baseColor = tokens.backgroundSecondary;
    final borderColor = tokens.borderSecondary.withValues(alpha: 0.32);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
    child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: borderColor, width: 1.6),
            boxShadow: [
              BoxShadow(
                color: tokens.shadowColor.withValues(alpha: tokens.isDark ? 0.28 : 0.14),
                blurRadius: 22,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  EmotionIcon(icon: Icons.auto_awesome_rounded, paletteKey: paletteKey, size: 42),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit emotion')),
                      PopupMenuItem(value: 'delete', child: Text('Remove emotion')),
                    ],
                    icon: Icon(Icons.more_horiz, color: tokens.textSecondary.withValues(alpha: 0.8)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                emotion.name,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                synonyms,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(color: tokens.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmotionFormSheet extends StatefulWidget {
  const _EmotionFormSheet({required this.onSubmit, this.existing});

  final void Function(EmotionDefinition) onSubmit;
  final EmotionDefinition? existing;

  @override
  State<_EmotionFormSheet> createState() => _EmotionFormSheetState();
}

class _EmotionFormSheetState extends State<_EmotionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _synonymsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _synonymsController = TextEditingController(text: widget.existing?.synonyms.join(', ') ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _synonymsController.dispose();
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
              isEditing ? 'Edit feeling' : 'Add a new feeling',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Feeling name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please provide a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _synonymsController,
              decoration: const InputDecoration(
                labelText: 'Other words (comma separated)',
                hintText: 'calm, steady, warm',
              ),
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
                    final synonyms = _synonymsController.text
                        .split(',')
                        .map((word) => word.trim())
                        .where((word) => word.isNotEmpty)
                        .toList();
                    final definition = EmotionDefinition(
                      id: widget.existing?.id ?? _generateId(_nameController.text),
                      name: _nameController.text.trim(),
                      synonyms: synonyms,
                    );
                    widget.onSubmit(definition);
                  },
                  style: FilledButton.styleFrom(backgroundColor: tokens.accentPrimary),
                  child: Text(isEditing ? 'Save feeling' : 'Add feeling'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _generateId(String name) {
    final base = name.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    final randomSuffix = Random().nextInt(900) + 100;
    return '$base-$randomSuffix';
  }
}
