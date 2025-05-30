import 'dart:convert';

import 'package:bits/bits.dart';

import '../models/item.dart';

const itemAppdataCodec = ItemAppdataCodec();

class ItemAppdataCodec extends Codec<Iterable<Item>, List<int>> {
  const ItemAppdataCodec();

  @override
  Converter<Iterable<Item>, List<int>> get encoder => const _ItemAppdataEncoder();

  @override
  Converter<List<int>, Iterable<Item>> get decoder => const _ItemAppdataDecoder();
}

class _ItemAppdataEncoder extends Converter<Iterable<Item>, List<int>> {
  const _ItemAppdataEncoder();

  @override
  List<int> convert(Iterable<Item> input) {
    final buffer = BitBuffer();
    final writer = buffer.writer();

    writer.writeInt(input.length, signed: false);
    for (final item in input) {
      writer.writeString(item.barcode);
      writer.writeString(item.name!);
      writer.writeBit(item.owner != null);
      if (item.owner != null) writer.writeString(item.owner!);
    }

    return buffer.toUInt8List();
  }
}

class _ItemAppdataDecoder extends Converter<List<int>, Iterable<Item>> {
  const _ItemAppdataDecoder();

  @override
  Iterable<Item> convert(List<int> input) {
    final buffer = BitBuffer.fromUInt8List(input);
    final reader = buffer.reader();
    final items = <Item>{};

    final itemCount = reader.readInt(signed: false);
    for (var i = 0; i < itemCount; i++) {
      final barcode = reader.readString();
      final name = reader.readString();
      final owner = reader.readBit() ? reader.readString() : null;

      items.add(Item(barcode, name, owner));
    }

    return items;
  }
}
