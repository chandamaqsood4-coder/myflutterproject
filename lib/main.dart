import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'app/auth_gate.dart';
import 'shared/design_system/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // window_manager is desktop-only (Windows, Linux, macOS). Guard so the same
  // code base can still run on web or mobile targets without crashing.
  if (_isDesktop) {
    await windowManager.ensureInitialized();
    const options = WindowOptions(
      size: Size(1100, 760),
      minimumSize: Size(480, 640),
      center: true,
      title: 'DukanOS',
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const ProviderScope(child: DukanOsApp()));
}

bool get _isDesktop {
  return !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS);
}

class DukanOsApp extends StatelessWidget {
  const DukanOsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DukanOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const AuthGate(),
    );
  }
}
