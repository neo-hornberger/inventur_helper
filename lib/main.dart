import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import './pages/home_page.dart';
import './preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Preferences().init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ValueNotifier<String?> _sharedItemsNotifier = ValueNotifier(null);

  MyApp({super.key}) {
    AppLinks().uriLinkStream.listen(_handleAppLink);
  }

  void _handleAppLink(Uri uri) {
    assert(uri.isScheme('app'), 'Invalid URI scheme: ${uri.scheme}');
    assert(uri.host == 'dev.hornberger.inventur_helper', 'Invalid URI host: ${uri.host}');

    if (listEquals(uri.pathSegments, ['shared_items'])) {
      if (uri.hasFragment) {
        _sharedItemsNotifier.value = uri.fragment;
      }

      // Reset shared items notifier
      _sharedItemsNotifier.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventur Helper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: MyHomePage(
        title: 'Inventur Helper',
        sharedItemsNotifier: _sharedItemsNotifier,
      ),
    );
  }
}

const int _primaryValue = 0xFF003399;
const MaterialColor primaryColor = MaterialColor(
  _primaryValue,
  {
    50: Color(0xFFE6EBF5),
    100: Color(0xFFB3C2E0),
    200: Color(0xFF8099CC),
    300: Color(0xFF6685C2),
    400: Color(0xFF335CAD),
    500: Color(_primaryValue),
    600: Color(0xFF002E8A),
    700: Color(0xFF00246B),
    800: Color(0xFF001A4D),
    900: Color(0xFF000F2E),
  },
);
