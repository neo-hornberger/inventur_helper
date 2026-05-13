import 'package:flutter_test/flutter_test.dart';
import 'package:inventur_helper/encoding/item_qr_codec.dart';

void main() {
  test('encodes and decodes an empty list correctly', () {
    const original = <String>[];
    
    final encoded = itemQrCodec.encode(original);
    final decoded = itemQrCodec.decode(encoded);

    expect(decoded, original);
  });

  test('encodes and decodes a single code correctly', () {
    const original = ['0705-963842'];
    
    final encoded = itemQrCodec.encode(original);
    final decoded = itemQrCodec.decode(encoded);

    expect(decoded, original);
  });

  test('encodes and decodes multiple codes correctly', () {
    const original = [
      '0001-123456',
      '0705-963842',
    ];
    
    final encoded = itemQrCodec.encode(original);
    final decoded = itemQrCodec.decode(encoded);

    expect(decoded, original);
  });
}
