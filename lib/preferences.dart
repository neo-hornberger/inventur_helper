import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './encoding/item_appdata_codec.dart';
import './models/inventory.dart';
import './models/item.dart';

class Preferences {
  static final Preferences _instance = Preferences._internal();

  late SharedPreferences _prefs;
  late Directory _appDir;

  factory Preferences() => _instance;

  Preferences._internal() {
    SharedPreferences.getInstance().then((prefs) => _prefs = prefs);
    getApplicationDocumentsDirectory().then((dir) => _appDir = dir);
  }

  Inventory? get inventory => getInventory(_prefs.getString('inventory') ?? '');

  void selectInventory(String name) {
    _prefs.setString('inventory', name);
  }

  File? _inventoryFile(String name) {
    if (name.isEmpty) {
      return null;
    }
    if (!_prefs.containsKey('inventories')) {
      return null;
    }

    final entry = _prefs.getStringList('inventories')!.firstWhere(
          (inv) => inv.startsWith('$name:'),
          orElse: () => '',
        );

    if (entry.isEmpty) {
      return null;
    }

    final path = entry.substring(name.length + 1);
    final file = File(p.join(_appDir.path, path));

    if (!file.existsSync()) {
      throw Exception('Inventory file does not exist: $path');
    }

    return file;
  }

  Inventory? getInventory(String name) {
    final file = _inventoryFile(name);

    if (file == null) {
      return null;
    }

    return Inventory(name, itemAppdataCodec.decode(file.readAsBytesSync()).toSet());
  }

  void addInventory(String name, {Set<Item>? items, List<int>? bytes}) {
    if (items == null && bytes == null) {
      throw Exception('Either items or bytes must be provided');
    }
    if (items != null && bytes != null) {
      throw Exception('Only one of items or bytes can be provided');
    }

    final file = File(p.join(_appDir.path, '$name.inv'));
    file.writeAsBytesSync(bytes ?? itemAppdataCodec.encode(items!));

    final inventories = _prefs.getStringList('inventories') ?? [];
    inventories.add('$name:$name.inv');
    _prefs.setStringList('inventories', inventories);
  }

  void removeInventory(String name) {
    final file = _inventoryFile(name);

    if (file == null) {
      return;
    }

    // remove inventory file
    file.deleteSync();

    // remove inventory from list
    final inventories = _prefs.getStringList('inventories')!;
    inventories.removeWhere((inv) => inv.startsWith('$name:'));
    _prefs.setStringList('inventories', inventories);

    // clear selected inventory if it is the removed one
    if (_prefs.getString('inventory') == name) {
      _prefs.remove('inventory');
    }
  }

  Set<String> get inventoryNames {
    if (!_prefs.containsKey('inventories')) {
      return {};
    }

    return _prefs.getStringList('inventories')!.map((inv) => inv.split(':')[0]).toSet();
  }
}
