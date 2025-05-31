import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../dialogs/add_barcode_dialog.dart';
import '../dialogs/clear_itemlist_dialog.dart';
import '../dialogs/export_itemlist_dialog.dart';
import '../dialogs/remove_dialog.dart';
import '../item_util.dart';
import '../models/item.dart';
import './scan_page.dart';
import './inventory_settings_page.dart';

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Set<String> _items = {};

  void _addItems(Iterable<String> items) {
    setState(() {
      _items.addAll(items);
    });
  }

  void _removeItem(String item) {
    setState(() {
      _items.remove(item);
    });
  }

  void _clearItems() {
    setState(() {
      _items.clear();
    });
  }

  void _addBarcode() {
    showDialog(
      context: context,
      builder: (context) => AddBarcodeDialog(
        onCancel: () => Navigator.pop(context),
        onAdd: (String barcode) {
          _addItems([barcode]);
        },
        onDone: () => Navigator.pop(context),
      ),
    );
  }

  void _scanBarcode() async {
    final Set<String>? items =
        await Navigator.push(context, MaterialPageRoute(builder: (context) => const ScanPage()));

    if (items == null) return;

    _addItems(items);
  }

  void _removeSelectedItem(String item) {
    showDialog(
      context: context,
      builder: (context) => RemoveDialog.item(
        item: item,
        onCancel: () => Navigator.pop(context),
        onRemove: () {
          _removeItem(item);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _clearScanList() {
    showDialog(
      context: context,
      builder: (context) => ClearItemlistDialog(
        onCancel: () => Navigator.pop(context),
        onClear: () {
          _clearItems();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _exportScanList() async {
    ScreenBrightness.instance.setApplicationScreenBrightness(1.0);
    await showDialog(
      context: context,
      builder: (context) => ExportItemlistDialog(
        items: _items,
        onCancel: () => Navigator.pop(context),
      ),
    );
    ScreenBrightness.instance.resetApplicationScreenBrightness();
  }

  void _showInventorySettings() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const InventorySettingsPage())).then((_) {
      // Refresh the state of the app when returning from the inventory settings page
      setState(() {});
    });
  }

  void _showItem(Item item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.barcode),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.owner != null)
              Text(
                item.owner!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            Text(
              item.name ?? 'N/A',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            onPressed: () => _showInventorySettings(),
            icon: const Icon(Icons.inventory_2),
          ),
          IconButton(
            onPressed: () => _exportScanList(),
            icon: const Icon(Icons.qr_code_2),
          ),
          IconButton(
            onPressed: () => _clearScanList(),
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Center(
        child: ListView.separated(
          padding: const EdgeInsets.all(8.0),
          itemCount: _items.length,
          itemBuilder: (BuildContext context, int index) {
            final Item item = lookupItem(_items.elementAt(index));
            return itemWidget(
              item,
              onTap: () => _showItem(item),
              onLongPress: () => _removeSelectedItem(item.barcode),
            );
          },
          separatorBuilder: (BuildContext context, int index) => const Divider(),
          // children: _scanned.map((e) => ListTile(title: Text(e))).toList(),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            tooltip: 'Add',
            heroTag: '<fab add>',
            onPressed: _addBarcode,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            tooltip: 'Scan',
            heroTag: '<fab scan>',
            onPressed: _scanBarcode,
            child: const Icon(Icons.photo_camera),
          ),
        ],
      ),
    );
  }
}
