import 'dart:async';

import 'package:flutter/material.dart';

import 'app/numi_app.dart';
import 'app/startup_bootstrap.dart';
import 'core/notifications/notification_service.dart';

export 'app/numi_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(NotificationService().initialize());
  final startup = await const StartupBootstrap().run();
  runApp(
    NumiApp(
      lingoProvider: startup.lingoProvider,
      authService: startup.authService,
      initialAuthState: startup.initialAuthState,
      restoreSessionOnStart: false,
    ),
  );
}
