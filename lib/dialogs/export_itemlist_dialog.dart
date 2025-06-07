import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/inventory.dart';
import '../pages/inventory_settings_page.dart';

class ExportItemlistDialog extends StatefulWidget {
  final Inventory? inventory;
  final Iterable<String> items;
  final void Function() onCancel;

  const ExportItemlistDialog({
    super.key,
    required this.inventory,
    required this.items,
    required this.onCancel,
  });

  @override
  State<ExportItemlistDialog> createState() => _ExportItemlistDialogState();
}

class _ExportItemlistDialogState extends State<ExportItemlistDialog> {
  final _controller = TextEditingController();

  Uint8List _getBytes() {
    late Iterable<List<dynamic>> rows;
    if (widget.inventory != null) {
      rows = widget.inventory!.items
          .map((item) => [
                item.barcode,
                item.name ?? '',
                item.owner,
                item.status.map((status) => status.code).join(', '),
                widget.items.contains(item.barcode),
              ])
          .toList()
        ..addAll(widget.items
            .whereNot((barcode) => widget.inventory!.items.any((item) => item.barcode == barcode))
            .map((item) => [item, null, null, null, true]));
    } else {
      rows = widget.items.map((item) => [item, null, null, null, true]);
    }

    return utf8.encode(csvCodec.encoder.convert(
      [
        ['Barcode', 'Description', 'Owner', 'Status', 'Scanned'],
        ...rows,
      ],
      delimitAllFields: true,
      convertNullTo: '',
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export item list'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'File name',
              hintText: widget.inventory?.name ?? 'itemlist',
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9_.-]')),
            ],
          ),
          const SizedBox(height: 32),
          Text('Active inventory: ${widget.inventory?.name ?? 'None'}'),
          Text('Items to export: ${widget.items.length}'),
          if (widget.inventory != null)
            Text('Items in inventory: ${widget.inventory!.items.length}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            FilePicker.platform
                .saveFile(
              dialogTitle: 'Export item list',
              fileName: '${_controller.text}.csv',
              type: FileType.custom,
              allowedExtensions: ['csv'],
              bytes: _getBytes(),
            )
                .then((path) {
              if (path != null) {
                Navigator.pop(context);
              }
            });
          },
          child: const Text('Export'),
        ),
      ],
    );
  }
}
