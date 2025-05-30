import 'dart:convert';

const base64url = Base64UrlCodec();

class Base64UrlCodec extends Codec<List<int>, String> {
  const Base64UrlCodec();

  @override
  Converter<List<int>, String> get encoder => const _Base64UrlEncoder();

  @override
  Converter<String, List<int>> get decoder => const _Base64UrlDecoder();
}

class _Base64UrlEncoder extends Converter<List<int>, String> {
  const _Base64UrlEncoder();

  @override
  String convert(List<int> input) => base64Url.encode(input).replaceAll('=', '');
}

class _Base64UrlDecoder extends Converter<String, List<int>> {
  const _Base64UrlDecoder();

  @override
  List<int> convert(String input) {
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
