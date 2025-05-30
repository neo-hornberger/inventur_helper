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
  int? barcodeCol;
  int? descriptionCol;

  void _onImport() {
    if (barcodeCol == null || descriptionCol == null) {
      return;
    }

    widget.onImport([
      barcodeCol!,
      descriptionCol!,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('CSV Import'),
      content: Wrap(
        children: [
          const Text('Select the columns to import:'),
          const SizedBox(height: 48),
          Wrap(
            children: [
              const Text('Barcode'),
              DropdownButton<int>(
                value: barcodeCol,
                items: widget.cols
                    .mapIndexed((i, e) => DropdownMenuItem(
                          value: i,
                          child: Text(e.toString()),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => barcodeCol = value),
              ),
            ],
          ),
          Wrap(
            children: [
              const Text('Description'),
              DropdownButton<int>(
                value: descriptionCol,
                items: widget.cols
                    .mapIndexed((i, e) => DropdownMenuItem(
                          value: i,
                          child: Text(e.toString()),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => descriptionCol = value),
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
