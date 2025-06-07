import 'package:flutter_test/flutter_test.dart';
import 'package:inventur_helper/encoding/base64_url_codec.dart';

void main() {
  test('encodes and decodes correctly', () {
    const original = [192, 168, 1, 1, 10, 20, 30, 40];
    
    final encoded = base64url.encode(original);
    final decoded = base64url.decode(encoded);

    expect(decoded, original);
  });
}
