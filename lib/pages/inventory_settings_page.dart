import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../dialogs/csv_column_import_dialog.dart';
import '../dialogs/inventory_name_dialog.dart';
import '../dialogs/remove_dialog.dart';
import '../models/item.dart';
import '../preferences.dart';

final CsvCodec csvCodec = CsvCodec(
  fieldDelimiter: ';',
  textDelimiter: '"',
  eol: '\n',
);

final RegExp _barcodeRegExp = RegExp(r'^\d{4}-\d{6}$');

class InventorySettingsPage extends StatefulWidget {
  const InventorySettingsPage({super.key});

  @override
  State<InventorySettingsPage> createState() => _InventorySettingsPageState();
}

class _InventorySettingsPageState extends State<InventorySettingsPage> {
  final _prefs = Preferences();

  late String? _selectedInventory;
  late Set<String> _inventories;

  void _selectInventory(String inventory) {
    _prefs.selectInventory(inventory);
    _refreshPrefs();
  }

  void _removeInventory(String inventory) {
    _prefs.removeInventory(inventory);
    _refreshPrefs();
  }

  void _removeSelectedInventory(String inventory) {
    showDialog(
      context: context,
      builder: (context) => RemoveDialog.inventory(
        inventory: inventory,
        onCancel: () => Navigator.pop(context),
        onRemove: () {
          _removeInventory(inventory);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _onAddInventory() async {
    final String? name = await showDialog(
      context: context,
      builder: (context) => InventoryNameDialog(
        onCancel: () => Navigator.pop(context),
        onSubmit: (name) => Navigator.pop(context, name),
      ),
    );
    if (name == null) {
      return;
    }

    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'inv'],
      withReadStream: true,
    );
    if (result == null) {
      return;
    }

    final PlatformFile file = result.files.first;

    if (file.extension == 'csv') {
      final bytes =
          file.bytes ?? await file.readStream!.fold<List<int>>([], (a, b) => a..addAll(b));
      String text;
      try {
        text = utf8.decode(bytes);
      } catch (e) {
        text = String.fromCharCodes(bytes);
        // Fallback to ISO-8859-1 if UTF-8 decoding fails
        // This is a common issue with CSV files that are not UTF-8 encoded.
      }
      final csv = text.replaceAll('\r', '');
      final rows = csvCodec.decoder.convert(csv);

      final List<int> cols = await showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => CsvColumnImportDialog(
          cols: rows.first,
          onCancel: () => Navigator.pop(context, <int>[]),
          onImport: (cols) => Navigator.pop(context, cols),
        ),
      );

      if (cols.isEmpty) {
        return;
      }

      _prefs.addInventory(
        name,
        items: rows
            .where((row) => row.length < cols.max ? false : _barcodeRegExp.hasMatch(row[cols[0]]))
            .map((row) => Item(
                  (row[cols[0]] as String).trim(),
                  (row[cols[1]] as String).trim(),
                  cols[2] >= 0 ? (row[cols[2]] as String).trim() : null,
                  cols[3] >= 0
                      ? (row[cols[3]] as String)
                          .split(',')
                          .map((status) => ItemStatus.fromCode(status.trim()))
                          .whereNotNull()
                          .toSet()
                      : {},
                ))
            .toSet(),
      );
    } else if (file.extension == 'inv') {
      final bytes =
          file.bytes ?? Uint8List.fromList(await file.readStream!.fold<List<int>>([], (a, b) => a..addAll(b)));

      _prefs.addInventory(name, bytes: bytes);
    } else {
      throw Exception('Unsupported file extension: ${file.extension}');
    }

    _refreshPrefs();
  }

  void _refreshPrefs() {
    setState(() {
      _selectedInventory = _prefs.inventory?.name;
      _inventories = _prefs.inventoryNames;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Settings'),
      ),
      body: ListView.separated(
        itemCount: _inventories.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index != _inventories.length) {
            final inventory = _inventories.elementAt(index);

            return ListTile(
              title: Text(inventory),
              selected: _selectedInventory == inventory,
              selectedColor: Theme.of(context).colorScheme.onPrimaryContainer,
              selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
              onTap: () => _selectInventory(inventory),
              onLongPress: () => _removeSelectedInventory(inventory),
            );
          }

          return TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Inventory'),
            onPressed: _onAddInventory,
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }
}
