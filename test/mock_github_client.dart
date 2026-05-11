import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class MockGithubClient {
  static Future<http.Client> setupMockClient({Map<String, String>? verifyHeaders}) async {
    final client = MockClient((http.Request request) async {
      var url = request.url.toString();

      if (verifyHeaders != null) {
        assert(mapEquals(verifyHeaders, request.headers));
      }

      if (url == 'https://api.github.com/repos/neo-hornberger/inventur_helper/releases/latest') {
        final contents = (await getTestData('github_release.json')).readAsStringSync();
        return http.Response(contents, 200, headers: {
          HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
          'x-github-media-type': 'github.v3; format=json',
          'x-github-api-version-selected': '2022-11-28',
        });
      }

      return http.Response('', 404);
    });

    return client;
  }

  static Future<File> getTestData(String filename) async {
    var file = File('test/$filename');
    if (!file.existsSync()) throw Exception('Test data file not found: $filename');
    return file;
  }
}
