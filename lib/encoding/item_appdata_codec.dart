import 'dart:convert';
import 'dart:typed_data';

import 'package:bits/bits.dart';

import '../models/item.dart';

const itemAppdataCodec = ItemAppdataCodec();

class ItemAppdataCodec extends Codec<Iterable<Item>, Uint8List> {
  const ItemAppdataCodec();

  @override
  Converter<Iterable<Item>, Uint8List> get encoder => const _ItemAppdataEncoder();

  @override
  Converter<Uint8List, Iterable<Item>> get decoder => const _ItemAppdataDecoder();
}

class _ItemAppdataEncoder extends Converter<Iterable<Item>, Uint8List> {
  const _ItemAppdataEncoder();

  @override
  Uint8List convert(Iterable<Item> input) {
    final buffer = BitBuffer();
    final writer = buffer.writer();

    writer.writeInt(input.length, signed: false);
    for (final item in input) {
      writer.writeString(item.barcode);
      writer.writeString(item.name!);
      writer.writeBit(item.owner != null);
      if (item.owner != null) writer.writeString(item.owner!);
      writer.writeBits(item.status.fold(0, (bits, status) => bits | (1 << status.index)), ItemStatus.values.length);
    }

    return buffer.toUInt8List();
  }
}

class _ItemAppdataDecoder extends Converter<Uint8List, Iterable<Item>> {
  const _ItemAppdataDecoder();

  @override
  Iterable<Item> convert(Uint8List input) {
    final buffer = BitBuffer.fromUInt8List(input);
    final reader = buffer.reader();
    final items = <Item>{};

    final itemCount = reader.readInt(signed: false);
    for (var i = 0; i < itemCount; i++) {
      final barcode = reader.readString();
      final name = reader.readString();
      final owner = reader.readBit() ? reader.readString() : null;

      final statusBits = reader.readBits(ItemStatus.values.length);
      final status = ItemStatus.values.where((status) => statusBits & (1 << status.index) != 0).toSet();

      items.add(Item(barcode, name, owner, status));
    }

    return items;
  }
}
