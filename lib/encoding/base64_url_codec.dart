import 'dart:convert';
import 'dart:typed_data';

const base64url = Base64UrlCodec();

class Base64UrlCodec extends Codec<Uint8List, String> {
  const Base64UrlCodec();

  @override
  Converter<Uint8List, String> get encoder => const _Base64UrlEncoder();

  @override
  Converter<String, Uint8List> get decoder => const _Base64UrlDecoder();
}

class _Base64UrlEncoder extends Converter<Uint8List, String> {
  const _Base64UrlEncoder();

  @override
  String convert(Uint8List input) => base64Url.encode(input).replaceAll('=', '');
}

class _Base64UrlDecoder extends Converter<String, Uint8List> {
  const _Base64UrlDecoder();

  @override
  Uint8List convert(String input) {
    var output = input;

    switch (input.length % 4) {
      case 1:
        throw const FormatException('Invalid base64url string');
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
    }

    return base64Url.decode(output);
  }
}
