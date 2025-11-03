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
        final screenWidth = MediaQuery.of(context).size.width;
        final isCompactAppBar = screenWidth < 420;

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
            toolbarHeight: isCompactAppBar ? 64 : null,
            actions: isCompactAppBar
                ? null
                : [
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
            bottom: isCompactAppBar
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(76),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: LayoutBuilder(
                        builder: (context, bottomConstraints) {
                          final stackVertically = bottomConstraints.maxWidth < 360;

                          Widget arrangeButton({required EdgeInsetsGeometry padding}) {
                            return OutlinedButton.icon(
                              onPressed: () => _showReorderSheet(context),
                              icon: const Icon(Icons.swap_vert_rounded, size: 18),
                              label: const Text('Arrange feelings'),
                              style: OutlinedButton.styleFrom(
                                padding: padding,
                                foregroundColor: tokens.textPrimary,
                                side: BorderSide(color: tokens.borderSecondary.withValues(alpha: 0.4)),
                              ),
                            );
                          }

                          Widget addButton({required EdgeInsetsGeometry padding}) {
                            return FilledButton.icon(
                              onPressed: () => _showAddEmotionSheet(context),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add feeling'),
                              style: FilledButton.styleFrom(
                                padding: padding,
                                backgroundColor: tokens.accentPrimary,
                              ),
                            );
                          }

                          if (stackVertically) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                arrangeButton(padding: const EdgeInsets.symmetric(vertical: 14)),
                                const SizedBox(height: 12),
                                addButton(padding: const EdgeInsets.symmetric(vertical: 14)),
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(child: arrangeButton(padding: const EdgeInsets.symmetric(vertical: 14))),
                              const SizedBox(width: 12),
                              Expanded(child: addButton(padding: const EdgeInsets.symmetric(vertical: 14))),
                            ],
                          );
                        },
                      ),
                    ),
                  )
                : null,
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
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 360;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isCompact ? 20 : 32),
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
        const horizontalPadding = 40.0; // GridView horizontal padding (20 + 20)
        const spacing = 18.0;
        const minTileWidth = 170.0;

        final availableWidth = max(0.0, constraints.maxWidth - horizontalPadding);
        var crossAxisCount = (availableWidth / minTileWidth).floor().clamp(1, 4);
        if (crossAxisCount == 1 && constraints.maxWidth >= 320) {
          crossAxisCount = 2;
        }

        final totalSpacing = spacing * (crossAxisCount - 1);
        final itemWidth = crossAxisCount > 0 ? (availableWidth - totalSpacing) / crossAxisCount : availableWidth;
        final isCompact = itemWidth < 220;
        final isUltraCompact = itemWidth < 160;
        final isSuperCompact = itemWidth < 150;
        final childAspectRatio = isUltraCompact
            ? 1.28
            : isCompact
                ? 1.12
                : 0.95;

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
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
              isCompact: isUltraCompact || isCompact,
              isSuperCompact: isSuperCompact,
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
    required this.isCompact,
    required this.isSuperCompact,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final EmotionDefinition emotion;
  final String paletteKey;
  final FeelBetterTheme tokens;
  final TextTheme textTheme;
  final bool isCompact;
  final bool isSuperCompact;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final synonyms = emotion.synonyms.isEmpty ? 'No synonyms yet' : emotion.synonyms.join(', ');

    final baseColor = tokens.backgroundSecondary;
    final borderColor = tokens.borderSecondary.withValues(alpha: 0.32);
    final borderRadius = BorderRadius.circular(isSuperCompact ? 18 : (isCompact ? 22 : 28));
    final tilePadding = EdgeInsets.fromLTRB(
      isSuperCompact ? 14 : 18,
      isSuperCompact ? 14 : (isCompact ? 18 : 22),
      isSuperCompact ? 14 : 18,
      isSuperCompact ? 16 : (isCompact ? 20 : 24),
    );
    final iconSize = isSuperCompact ? 30.0 : (isCompact ? 36.0 : 42.0);
    final spacingAfterHeader = isSuperCompact ? 8.0 : (isCompact ? 12.0 : 16.0);
    final spacingAfterTitle = isSuperCompact ? 4.0 : (isCompact ? 6.0 : 8.0);

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Ink(
          padding: tilePadding,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: borderRadius,
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
                  EmotionIcon(icon: Icons.auto_awesome_rounded, paletteKey: paletteKey, size: iconSize),
                  PopupMenuButton<String>(
                    tooltip: 'Tile options',
                    position: PopupMenuPosition.under,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: isSuperCompact ? 18 : 22,
                    icon: Icon(
                      Icons.more_horiz,
                      color: tokens.textSecondary.withValues(alpha: 0.8),
                      size: isSuperCompact ? 20 : 22,
                    ),
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
                    itemBuilder: (context) {
                      PopupMenuItem<String> buildItem({required String value, required IconData icon, required String label}) {
                        return PopupMenuItem<String>(
                          value: value,
                          child: Row(
                            children: [
                              Icon(icon, size: 18, color: tokens.textSecondary),
                              const SizedBox(width: 10),
                              Text(label),
                            ],
                          ),
                        );
                      }

                      return [
                        buildItem(value: 'edit', icon: Icons.edit_outlined, label: 'Edit emotion'),
                        buildItem(value: 'delete', icon: Icons.delete_outline, label: 'Remove emotion'),
                      ];
                    },
                  ),
                ],
              ),
              SizedBox(height: spacingAfterHeader),
              Text(
                emotion.name,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: tokens.textPrimary,
                  fontSize: isSuperCompact ? 15 : (isCompact ? 16 : null),
                ),
              ),
              SizedBox(height: spacingAfterTitle),
              Text(
                synonyms,
                maxLines: isSuperCompact ? 4 : 3,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: tokens.textSecondary,
                  height: 1.4,
                  fontSize: isSuperCompact ? 11 : (isCompact ? 12 : null),
                ),
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
