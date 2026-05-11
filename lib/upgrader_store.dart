import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:upgrader/upgrader.dart';
import 'package:version/version.dart';

class UpgraderGithubReleasesStore extends UpgraderStore {
  final String owner;
  final String repo;

  UpgraderGithubReleasesStore({
    required this.owner,
    required this.repo,
  });

  @override
  Future<UpgraderVersionInfo> getVersionInfo({
    required UpgraderState state,
    required Version installedVersion,
    required String? country,
    required String? language,
  }) async {
    if (state.packageInfo == null) return UpgraderVersionInfo();

    String? appStoreListingURL;
    Version? appStoreVersion;
    bool? isCriticalUpdate;
    Version? minAppVersion;
    String? releaseNotes;

    try {
      final uri = Uri.parse('https://api.github.com/repos/$owner/$repo/releases/latest');

      if (state.debugLogging) {
        debugPrint('upgrader: Fetching GitHub releases from $uri');
      }

      final response = await state.client.get(uri, headers: {
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
        if (state.clientHeaders != null) ...state.clientHeaders!,
      });
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic>? data = json.decode(response.body);
        if (data != null) {
          String? versionTag = data['tag_name'] as String?;
          if (versionTag != null && versionTag.startsWith('v')) {
            versionTag = versionTag.substring(1); // Remove 'v' prefix if present
          }

          appStoreListingURL = data['html_url'] as String?;
          appStoreVersion = versionTag != null ? Version.parse(versionTag) : null;
          // isCriticalUpdate = null;
          // minAppVersion = null;
          releaseNotes = data['body'] as String?;
        }
      }
    } on Exception catch (e) {
      if (state.debugLogging) {
        debugPrint('upgrader: Error fetching GitHub releases: $e');
      }
    }

    return UpgraderVersionInfo(
      appStoreListingURL: appStoreListingURL,
      appStoreVersion: appStoreVersion,
      installedVersion: installedVersion,
      isCriticalUpdate: isCriticalUpdate,
      minAppVersion: minAppVersion,
      releaseNotes: releaseNotes,
    );
  }
}

class UpgraderMultiStore extends UpgraderStore {
  final List<UpgraderStore> stores;

  UpgraderMultiStore(this.stores);

  @override
  Future<UpgraderVersionInfo> getVersionInfo({
    required UpgraderState state,
    required Version installedVersion,
    required String? country,
    required String? language,
  }) async {
    for (final store in stores) {
      try {
        final versionInfo = await store.getVersionInfo(
          state: state,
          installedVersion: installedVersion,
          country: country,
          language: language,
        );

        if (versionInfo.appStoreVersion != null) return versionInfo;
      } catch (e) {
        if (state.debugLogging) {
          debugPrint('upgrader: Error fetching version info from store: $e');
        }
      }
    }

    return UpgraderVersionInfo(
      installedVersion: installedVersion,
    );
  }
}
