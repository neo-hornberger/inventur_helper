import 'package:collection/collection.dart';

class Item {
  final String barcode;
  final String? name;
  final String? owner;
  final Set<ItemStatus> status;

  const Item(
    this.barcode,
    this.name,
    this.owner,
    this.status,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Item && barcode == other.barcode;

  @override
  int get hashCode => barcode.hashCode;
}

enum ItemStatus {
  available('V', 'vorhanden'),
  missing('F', 'fehlt / Fehlbestand'),
  nonRetrievable('NV', 'nicht verfügbar'),
  partial('T', 'teilweise'),
  overstock('ÜB', 'Überbestand'),
  alternative('A', 'Alternative'),
  oldStock('AB', 'Altbestand'),
  invalid('U', 'ungültig'),
  noInformation('KI', 'keine Information');

  final String code;
  final String description;

  const ItemStatus(this.code, this.description);

  static ItemStatus? fromCode(String code) => ItemStatus.values.firstWhereOrNull((status) => status.code == code);
}
