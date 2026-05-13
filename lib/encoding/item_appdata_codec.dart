import 'dart:convert';
import 'dart:typed_data';

import 'package:buffer/buffer.dart';

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
    final writer = ByteDataWriter();

    writer.writeUint32(input.length);
    for (final item in input) {
      writer.writeUint32(item.barcode.length);
      writer.write(item.barcode.codeUnits);

      writer.writeUint32(item.name!.length);
      writer.write(item.name!.codeUnits);

      writer.writeUint32(item.owner?.length ?? 0);
      writer.write(item.owner?.codeUnits ?? []);

      writer.writeUint8(item.status.length);
      for (final status in item.status) {
        writer.writeUint8(status.code.length);
        writer.write(status.code.codeUnits);
      }
    }

    return writer.toBytes();
  }
}

class _ItemAppdataDecoder extends Converter<Uint8List, Iterable<Item>> {
  const _ItemAppdataDecoder();

  @override
  Iterable<Item> convert(Uint8List input) {
    final reader = ByteDataReader()..add(input);
    final items = <Item>{};

    final itemCount = reader.readUint32();
    for (var i = 0; i < itemCount; i++) {
      final barcode = String.fromCharCodes(reader.read(reader.readUint32()));
      final name = String.fromCharCodes(reader.read(reader.readUint32()));

      final ownerLength = reader.readUint32();
      final owner = ownerLength > 0 ? String.fromCharCodes(reader.read(ownerLength)) : null;

      final statusCount = reader.readUint8();
      final status = <ItemStatus>{};
      for (var j = 0; j < statusCount; j++) {
        final statusCode = String.fromCharCodes(reader.read(reader.readUint8()));
        final statusItem = ItemStatus.fromCode(statusCode);
        if (statusItem != null) {
          status.add(statusItem);
        }
      }

      items.add(Item(barcode, name, owner, status));
    }

    return items;
  }
}
