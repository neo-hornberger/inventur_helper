import 'dart:convert';
import 'dart:math';

import 'package:buffer/buffer.dart';

import './base64_url_codec.dart';

const itemQrCodec = ItemQrCodec();

class ItemQrCodec extends Codec<Iterable<String>, String> {
  const ItemQrCodec();

  @override
  Converter<Iterable<String>, String> get encoder => const _ItemQrEncoder();

  @override
  Converter<String, Iterable<String>> get decoder => const _ItemQrDecoder();
}

final _prefixByteCount = pow(2, (9999.bitLength / 8).floor()).toInt();
final _suffixByteCount = pow(2, (999999.bitLength / 8).floor()).toInt();
const _nextPrefixCode = 1000000;

class _ItemQrEncoder extends Converter<Iterable<String>, String> {
  const _ItemQrEncoder();

  @override
  String convert(Iterable<String> input) {
    final writer = ByteDataWriter();

    input.fold(<int, Set<int>>{}, (result, code) {
      final splitCode = code.split('-');
      final prefix = int.parse(splitCode[0]);
      final suffix = int.parse(splitCode[1]);

      if (result.containsKey(prefix)) {
        result[prefix]?.add(suffix);
      } else {
        result[prefix] = {suffix};
      }

      return result;
    }).forEach((prefix, suffixes) {
      // write prefix
      writer.writeUint(_prefixByteCount, prefix);

      // write suffixes
      for (final suffix in suffixes) {
        writer.writeUint(_suffixByteCount, suffix);
      }

      writer.writeUint(_suffixByteCount, _nextPrefixCode);
    });

    return base64url.encode(writer.toBytes());
  }
}

class _ItemQrDecoder extends Converter<String, Iterable<String>> {
  const _ItemQrDecoder();

  @override
  Iterable<String> convert(String input) {
    final reader = ByteDataReader()..add(base64url.decode(input));
    final items = <String>{};

    final bytesToRead = reader.remainingLength - _prefixByteCount - _suffixByteCount;

    var prefix = 0;
    var suffix = 0;
    while (reader.offsetInBytes < bytesToRead) {
      prefix = reader.readUint(_prefixByteCount);

      while ((suffix = reader.readUint(_suffixByteCount)) != _nextPrefixCode) {
        final barcode = '${prefix.toString().padLeft(4, '0')}-${suffix.toString().padLeft(6, '0')}';

        items.add(barcode);
      }
    }

    return items;
  }
}
