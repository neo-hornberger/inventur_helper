class Item {
  final String barcode;
  final String? name;
  final String? owner;

  const Item(
    this.barcode,
    this.name,
    this.owner,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Item && barcode == other.barcode;

  @override
  int get hashCode => barcode.hashCode;
}
