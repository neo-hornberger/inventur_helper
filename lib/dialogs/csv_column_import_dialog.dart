import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class CsvColumnImportDialog extends StatefulWidget {
  final List<dynamic> cols;
  final void Function() onCancel;
  final void Function(List<int>) onImport;

  const CsvColumnImportDialog({
    super.key,
    required this.cols,
    required this.onCancel,
    required this.onImport,
  });

  @override
  State<CsvColumnImportDialog> createState() => _CsvColumnImportDialogState();
}

class _CsvColumnImportDialogState extends State<CsvColumnImportDialog> {
  int? _barcodeCol;
  int? _descriptionCol;
  int? _ownerCol;
  int? _statusCol;

  void _onImport() {
    if (_barcodeCol == null || _descriptionCol == null) {
      return;
    }

    widget.onImport([
      _barcodeCol!,
      _descriptionCol!,
      _ownerCol ?? -1,
      _statusCol ?? -1,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelMedium;

    return AlertDialog(
      title: const Text('CSV Import'),
      content: Wrap(
        direction: Axis.vertical,
        children: [
          const Text('Select the columns to import:'),
          const SizedBox(height: 24),
          _buildInput('Barcode', labelStyle, _barcodeCol, (col) => _barcodeCol = col),
          _buildInput('Description', labelStyle, _descriptionCol, (col) => _descriptionCol = col),
          _buildInput('Owner (optional)', labelStyle, _ownerCol, (col) => _ownerCol = col),
          _buildInput('Status (optional)', labelStyle, _statusCol, (col) => _statusCol = col),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _onImport,
          child: const Text('Import'),
        ),
      ],
    );
  }

  Widget _buildInput(String text, TextStyle? labelStyle, int? col, void Function(int?) onChanged) => Wrap(
        direction: Axis.vertical,
        children: [
          if (col != null) Text(text, style: labelStyle),
          DropdownButton<int>(
            value: col,
            items: widget.cols
                .mapIndexed((i, e) => DropdownMenuItem(
                      value: i,
                      child: Text(e.toString()),
                    ))
                .toList(),
            onChanged: (value) => setState(() => onChanged(value)),
            hint: Text(text),
          ),
        ],
      );
}
