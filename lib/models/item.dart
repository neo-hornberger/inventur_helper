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
  available('V'),
  missing('F'),
  overstock('ÜB'),
  oldStock('AB'),
  nonRetrievable('NV'),
  noInformation('NI'),
  invalid('U'),
  alternative('A'),
  partial('P');

  final String code;

  const ItemStatus(this.code);

  static ItemStatus? fromCode(String code) => ItemStatus.values.firstWhereOrNull((status) => status.code == code);
}
