class Item {
  final String barcode;
  final String? name;

  const Item(
    this.barcode,
    this.name,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Item && barcode == other.barcode;

  @override
  int get hashCode => barcode.hashCode;
}
