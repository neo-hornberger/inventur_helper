import 'package:flutter/material.dart';
import 'package:inventur_helper/item_generator.dart';

import '../models/item.dart';

class CheckItemDialog extends StatelessWidget {
  final Set<String> items;
  final void Function() onCancel;
  final void Function() onAdd;

  const CheckItemDialog({
    super.key,
    required this.items,
    required this.onCancel,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Add item'),
      content: _content(context),
      actions: [
        ElevatedButton.icon(
          onPressed: onCancel,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          icon: const Icon(Icons.close),
          label: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: onAdd,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ),
      ],
    );
  }

  Widget _content(BuildContext context) {
    if (items.length == 1) {
      final Item item = lookupItem(items.first);
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Do you want to add "${item.barcode}"?'),
          const SizedBox(height: 8),
          Text(
            item.name ?? 'N/A',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Do you want to add ${items.length} items?'),
        const SizedBox(height: 8),
        SingleChildScrollView(
          child: Column(
            children: [
              for (final item in items) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.circle,
                      size: 8,
                    ),
                    const SizedBox(width: 8),
                    Text(item),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
