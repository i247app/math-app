import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/app/numi_app.dart';
import 'package:numi/app/startup_bootstrap.dart';
import 'package:numi/core/debug/app_debug_bloc_observer.dart';
import 'package:numi/core/network/api_metadata.dart';
import 'package:numi/core/notifications/notification_service.dart';

export 'package:numi/app/numi_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    Bloc.observer = const AppDebugBlocObserver();
  }
  _forwardPushTokenToApiMetadata();
  unawaited(NotificationService().initialize());
  final startup = await const StartupBootstrap().run();
  runApp(
    NumiApp(
      lingoProvider: startup.lingoProvider,
      themeController: startup.themeController,
      authService: startup.authService,
      initialSession: startup.initialSession,
      restoreSessionOnStart: false,
    ),
  );
}

/// Feeds FCM tokens into the API metadata pipeline so backend requests carry
/// `push_token` / `X-Device-Push-Token`. Subscribes before [NotificationService]
/// initializes so the initial token is not missed, and seeds any token already
/// cached from an earlier emission ([NotificationService.tokens] is a broadcast
/// stream and does not replay).
void _forwardPushTokenToApiMetadata() {
  final metadataProvider = AppApiMetadataProvider.instance;
  NotificationService.tokens.listen(
    (token) => unawaited(_applyPushToken(metadataProvider, token)),
    onError: (Object error) =>
        debugPrint('[Notification] forward push token failed: $error'),
  );
  final latestToken = NotificationService.latestToken;
  if (latestToken != null) {
    unawaited(_applyPushToken(metadataProvider, latestToken));
  }
}

Future<void> _applyPushToken(
  AppApiMetadataProvider metadataProvider,
  String token,
) async {
  try {
    await metadataProvider.updateDevicePushToken(token);
  } catch (error) {
    debugPrint('[Notification] forward push token failed: $error');
  }
}
