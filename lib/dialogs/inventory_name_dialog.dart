import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InventoryNameDialog extends StatefulWidget {
  final void Function() onCancel;
  final void Function(String) onSubmit;

  const InventoryNameDialog({
    super.key,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  State<InventoryNameDialog> createState() => _InventoryNameDialogState();
}

class _InventoryNameDialogState extends State<InventoryNameDialog> {
  final _controller = TextEditingController();

  void _submit([String? text]) {
    final name = text ?? _controller.text;
    
    if (name.isNotEmpty) {
      widget.onSubmit(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Inventory Name'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Inventory name',
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9_]')),
        ],
        onSubmitted: _submit,
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Submit'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
