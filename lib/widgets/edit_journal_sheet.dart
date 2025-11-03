import 'package:flutter/material.dart';

import '../models/journal_entry.dart';

class EditJournalSheet extends StatefulWidget {
  const EditJournalSheet({
    super.key,
    required this.entry,
    required this.isNew,
    required this.onSave,
    required this.onCancel,
    this.onDelete,
  });

  final JournalEntry entry;
  final bool isNew;
  final ValueChanged<JournalEntry> onSave;
  final VoidCallback onCancel;
  final ValueChanged<String>? onDelete;

  @override
  State<EditJournalSheet> createState() => _EditJournalSheetState();
}

class _EditJournalSheetState extends State<EditJournalSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry.title);
    _contentController = TextEditingController(text: widget.entry.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.surface,
        title: Text(widget.isNew ? 'New entry' : 'Edit entry'),
        actions: [
          if (!widget.isNew && widget.onDelete != null)
            IconButton(
              tooltip: 'Delete entry',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => _confirmDelete(context),
            ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => _handleSave(context),
            child: const Text('Save'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: UnderlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Write your thoughts here…',
                  border: InputBorder.none,
                ),
                expands: true,
                maxLines: null,
                minLines: null,
                keyboardType: TextInputType.multiline,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () => _handleSave(context),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleSave(BuildContext context) {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final updated = JournalEntry(
      id: widget.entry.id,
      title: title.isEmpty ? 'Untitled entry' : title,
      content: content,
      timestamp: widget.isNew ? DateTime.now() : widget.entry.timestamp,
    );
    widget.onSave(updated);
  }

  void _confirmDelete(BuildContext context) {
    final onDelete = widget.onDelete;
    if (onDelete == null) return;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onDelete(widget.entry.id);
            },
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
