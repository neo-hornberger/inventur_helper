import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddBarcodeDialog extends StatefulWidget {
  final void Function() onCancel;
  final void Function(String) onAdd;
  final void Function() onDone;

  const AddBarcodeDialog({
    super.key,
    required this.onCancel,
    required this.onAdd,
    required this.onDone,
  });

  @override
  State<AddBarcodeDialog> createState() => _AddBarcodeDialogState();
}

class _AddBarcodeDialogState extends State<AddBarcodeDialog> {
  final _controller = TextEditingController();

  void _add([String? text]) {
    final barcode = text ?? _controller.text;

    if (barcode.isNotEmpty) {
      widget.onAdd(barcode);
    }

    _controller.clear();
  }

  void _done([String? text]) {
    _add(text);
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Barcode'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Barcode',
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
        ],
        onSubmitted: _add,
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _add,
          child: const Text('Add'),
        ),
        ElevatedButton(
          onPressed: _done,
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
