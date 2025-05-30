import 'package:flutter/material.dart';

class ClearItemlistDialog extends StatelessWidget {
  final void Function() onCancel;
  final void Function() onClear;

  const ClearItemlistDialog({
    super.key,
    required this.onCancel,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Remove all items'),
      content: const Text('Do you want to remove all scanned items?'),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          onPressed: onClear,
          icon: const Icon(Icons.delete),
          label: const Text('Remove'),
        ),
      ],
    );
  }
}
