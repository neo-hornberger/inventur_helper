import 'dart:convert';

import 'package:bits/bits.dart';

import './base64_url_codec.dart';

const itemQrCodec = ItemQrCodec();

class ItemQrCodec extends Codec<Iterable<String>, String> {
  const ItemQrCodec();

  @override
  Converter<Iterable<String>, String> get encoder => const _ItemQrEncoder();

  @override
  Converter<String, Iterable<String>> get decoder => const _ItemQrDecoder();
}

final _prefixBitCount = 9999.bitLength;
final _suffixBitCount = 999999.bitLength;
const _nextPrefixCode = 1000000;

class _ItemQrEncoder extends Converter<Iterable<String>, String> {
  const _ItemQrEncoder();

  @override
  String convert(Iterable<String> input) {
    final buffer = BitBuffer();
    final writer = buffer.writer();

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
      writer.writeBits(prefix, _prefixBitCount);

      // write suffixes
      for (final suffix in suffixes) {
        writer.writeBits(suffix, _suffixBitCount);
      }

      writer.writeBits(_nextPrefixCode, _suffixBitCount);
    });

    return base64url.encode(buffer.toUInt8List());
  }
}

class _ItemQrDecoder extends Converter<String, Iterable<String>> {
  const _ItemQrDecoder();

  @override
  Iterable<String> convert(String input) {
    final buffer = BitBuffer.fromUInt8List(base64url.decode(input));
    final reader = _BitReader(buffer);
    final items = <String>{};

    final bitsToRead = buffer.getSize() - _prefixBitCount - _suffixBitCount;

    var prefix = 0;
    var suffix = 0;
    while (reader.readCount < bitsToRead) {
      prefix = reader.readBits(_prefixBitCount);

      while ((suffix = reader.readBits(_suffixBitCount)) != _nextPrefixCode) {
        final barcode = '${prefix.toString().padLeft(4, '0')}-${suffix.toString().padLeft(6, '0')}';

        items.add(barcode);
      }
    }

    return items;
  }
}

class _BitReader extends BitBufferReader {
  int _readCount = 0;

  _BitReader(super.buffer);

  int get readCount => _readCount;

  @override
  void skip(int bits) {
    _readCount += bits;
    super.skip(bits);
  }

  @override
  void seekTo(int bit) {
    _readCount = bit;
    super.seekTo(bit);
  }

  @override
  bool readBit() {
    _readCount++;
    return super.readBit();
  }

  @override
  int readBits(int bitCount) {
    _readCount += bitCount;
    return super.readBits(bitCount);
  }
}
