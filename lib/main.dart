import 'package:flutter/material.dart';

import 'app/numi_app.dart';
import 'app/startup_bootstrap.dart';

export 'app/numi_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
