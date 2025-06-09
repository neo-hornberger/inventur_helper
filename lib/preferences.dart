import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './encoding/base64_url_codec.dart';
import './encoding/item_appdata_codec.dart';
import './encoding/item_qr_codec.dart';
import './models/inventory.dart';
import './models/item.dart';

class Preferences {
  static final Preferences _instance = Preferences._();

  late SharedPreferencesWithCache _prefs;
  late Directory _appDir;

  Preferences._();

  factory Preferences() => _instance;

  Future<void> init() async {
    _prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );

    if (!kIsWeb) {
      _appDir = await getApplicationDocumentsDirectory();
    }
  }

  Inventory? get inventory => getInventory(_prefs.getString('inventory') ?? '');

  void selectInventory(String name) => _prefs.setString('inventory', name);

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

  Uint8List? _inventory(String name) {
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

    final value = entry.substring(name.length + 1);

    if (kIsWeb) {
      return base64url.decode(value);
    } else {
      final file = File(p.join(_appDir.path, value));

      if (!file.existsSync()) {
        throw Exception('Inventory file does not exist: $value');
      }

      return file.readAsBytesSync();
    }
  }

  Inventory? getInventory(String name) {
    final bytes = _inventory(name);

    if (bytes == null) {
      return null;
    }

    return Inventory(name, itemAppdataCodec.decode(bytes).toSet());
  }

  void addInventory(String name, {Uint8List? bytes, Set<Item>? items}) {
    if (bytes == null && items == null) {
      throw Exception('Either items or bytes must be provided');
    }
    if (bytes != null && items != null) {
      throw Exception('Only one of items or bytes can be provided');
    }

    bytes ??= itemAppdataCodec.encode(items!);

    late String value;
    if (!kIsWeb) {
      final file = File(p.join(_appDir.path, '$name.inv'));
      file.writeAsBytesSync(bytes);
      value = '$name.inv';
    } else {
      value = base64url.encode(bytes);
    }

    final inventories = _prefs.getStringList('inventories') ?? [];
    inventories.add('$name:$value');
    _prefs.setStringList('inventories', inventories);
  }

  void removeInventory(String name) {
    if (!kIsWeb) {
      final file = _inventoryFile(name);

      if (file == null) {
        return;
      }

      // remove inventory file
      file.deleteSync();
    }

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

  Set<String> get items => itemQrCodec.decode(_prefs.getString('items') ?? '').toSet();
  
  set items(Set<String> items) => _prefs.setString('items', itemQrCodec.encode(items));

  void addItems(Iterable<String> items) => this.items = this.items..addAll(items);

  void removeItem(String item) => items = items..remove(item);

  void clearItems() => items = items..clear();
}
