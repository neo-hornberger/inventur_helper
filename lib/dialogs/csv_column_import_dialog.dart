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

  void _onImport() {
    if (_barcodeCol == null || _descriptionCol == null) {
      return;
    }

    widget.onImport([
      _barcodeCol!,
      _descriptionCol!,
      _ownerCol ?? -1,
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
          Wrap(
            direction: Axis.vertical,
            children: [
              if (_barcodeCol != null) Text('Barcode', style: labelStyle),
              DropdownButton<int>(
                value: _barcodeCol,
                items: widget.cols
                    .mapIndexed((i, e) => DropdownMenuItem(
                          value: i,
                          child: Text(e.toString()),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _barcodeCol = value),
                hint: const Text('Barcode'),
              ),
            ],
          ),
          Wrap(
            direction: Axis.vertical,
            children: [
              if (_descriptionCol != null) Text('Description', style: labelStyle),
              DropdownButton<int>(
                value: _descriptionCol,
                items: widget.cols
                    .mapIndexed((i, e) => DropdownMenuItem(
                          value: i,
                          child: Text(e.toString()),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _descriptionCol = value),
                hint: const Text('Description'),
              ),
            ],
          ),
          Wrap(
            direction: Axis.vertical,
            children: [
              if (_ownerCol != null) Text('Owner (optional)', style: labelStyle),
              DropdownButton<int>(
                value: _ownerCol,
                items: widget.cols
                    .mapIndexed((i, e) => DropdownMenuItem(
                          value: i,
                          child: Text(e.toString()),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _ownerCol = value),
                hint: const Text('Owner (optional)'),
              ),
            ],
          ),
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
}
