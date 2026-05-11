import 'package:flutter_test/flutter_test.dart';
import 'package:inventur_helper/upgrader_store.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:upgrader/upgrader.dart';
import 'package:version/version.dart';

import './mock_github_client.dart';

void main() {
  test('UpgraderGithubReleasesStore returns UpgraderVersionInfo', () async {
    final installedVersion = Version(0, 5, 3);
    final state = UpgraderState(
      debugLogging: true,
      client: await MockGithubClient.setupMockClient(),
      packageInfo: PackageInfo(
        appName: 'inventur_helper',
        packageName: 'dev.hornberger.inventur_helper',
        version: installedVersion.toString(),
        buildNumber: '1',
      ),
      upgraderOS: MockUpgraderOS(),
    );

    final upgraderStore = UpgraderGithubReleasesStore(
      owner: 'neo-hornberger',
      repo: 'inventur_helper',
    );

    final versionInfo = await upgraderStore.getVersionInfo(
      state: state,
      installedVersion: installedVersion,
      country: 'US',
      language: 'en',
    );

    expect(versionInfo.appStoreListingURL, isNotNull);
    expect(versionInfo.appStoreListingURL!.startsWith('https://github.com/${upgraderStore.owner}/${upgraderStore.repo}/releases/tag/'), true);
    expect(versionInfo.appStoreVersion, Version(1, 0, 0));
    expect(versionInfo.isCriticalUpdate, null);
    expect(versionInfo.minAppVersion, null);
    expect(versionInfo.releaseNotes, '');
  });
}
