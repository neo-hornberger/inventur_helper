import 'package:flutter/material.dart';

class RemoveDialog<T> extends StatelessWidget {
  final T value;
  final Widget title;
  final Widget content;
  final void Function() onCancel;
  final void Function() onRemove;

  const RemoveDialog({
    super.key,
    required this.value,
    required this.title,
    required this.content,
    required this.onCancel,
    required this.onRemove,
  });

  RemoveDialog.item({
    Key? key,
    required String item,
    required void Function() onCancel,
    required void Function() onRemove,
  }) : this(
          key: key,
          value: item as T,
          title: const Text('Remove item'),
          content: Text('Do you want to remove "$item"?'),
          onCancel: onCancel,
          onRemove: onRemove,
        );

  RemoveDialog.inventory({
    Key? key,
    required String inventory,
    required void Function() onCancel,
    required void Function() onRemove,
  }) : this(
          key: key,
          value: inventory as T,
          title: const Text('Remove inventory'),
          content: Text('Do you want to remove "$inventory"?'),
          onCancel: onCancel,
          onRemove: onRemove,
        );

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return AlertDialog(
      title: title,
      content: content,
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
          onPressed: onRemove,
          icon: const Icon(Icons.delete),
          label: const Text('Remove'),
        ),
      ],
    );
  }
}
