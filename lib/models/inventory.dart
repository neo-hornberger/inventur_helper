import './item.dart';

class Inventory {
  final String name;
  final Set<Item> items;

  const Inventory(this.name, this.items);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Inventory && name == other.name && items == other.items;

  @override
  int get hashCode => Object.hash(name, items);
}
