import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../debug/app_logger.dart';

@pragma('vm:entry-point')
Future<void> numiFirebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (error, stackTrace) {
    _logNotificationError('background firebase init', error, stackTrace);
    return;
  }

  NotificationService.logRemoteMessage(message, source: 'background');
}

@pragma('vm:entry-point')
void numiLocalNotificationTapBackground(NotificationResponse response) {
  AppLogger.info('NOTIFY', 'local background tap id=${response.id}');
  AppLogger.payload('NOTIFY', 'local background tap payload', response.payload);
}

class NotificationService {
  NotificationService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _messaging = messaging,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _foregroundChannel =
      AndroidNotificationChannel(
        'numi_foreground_notifications',
        'NUMI notifications',
        description: 'Notifications shown while NUMI is open.',
        importance: Importance.high,
      );
  static const int _apnsTokenLoadAttempts = 40;
  static const Duration _apnsTokenRetryDelay = Duration(milliseconds: 250);

  static bool _initialized = false;
  static String? _latestToken;
  static final StreamController<RemoteMessage> _messageController =
      StreamController<RemoteMessage>.broadcast();
  static final StreamController<String> _tokenController =
      StreamController<String>.broadcast();
  static final StreamController<NotificationResponse> _localResponseController =
      StreamController<NotificationResponse>.broadcast();

  final FirebaseMessaging? _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  static Stream<RemoteMessage> get messages => _messageController.stream;

  static Stream<String> get tokens => _tokenController.stream;

  /// Most recent FCM token, or null if none fetched yet. Lets a late subscriber
  /// seed itself, since [tokens] is a broadcast stream that does not replay.
  static String? get latestToken => _latestToken;

  static Future<String?> currentToken() async {
    final cachedToken = _latestToken?.trim();
    if (cachedToken != null && cachedToken.isNotEmpty) {
      return cachedToken;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      final messaging = FirebaseMessaging.instance;
      final token = await resolveMessagingToken(
        requiresApnsToken: _requiresApnsToken,
        getApnsToken: messaging.getAPNSToken,
        getFcmToken: messaging.getToken,
      );
      if (token == null || token.isEmpty) {
        AppLogger.warning('NOTIFY', 'FCM token is not available yet');
        return null;
      }

      _emitToken(token);
      AppLogger.info('NOTIFY', 'FCM token loaded');
      return token;
    } catch (error, stackTrace) {
      _logNotificationError('token load', error, stackTrace);
      return null;
    }
  }

  /// Waits for APNs registration before asking Firebase for an FCM token.
  ///
  /// Recent Firebase Messaging SDKs require the APNs token to be available
  /// before Apple-platform FCM API calls. The wait is bounded so notification
  /// startup cannot hang indefinitely when APNs registration is unavailable.
  @visibleForTesting
  static Future<String?> resolveMessagingToken({
    required bool requiresApnsToken,
    required Future<String?> Function() getApnsToken,
    required Future<String?> Function() getFcmToken,
    int apnsTokenLoadAttempts = _apnsTokenLoadAttempts,
    Duration apnsTokenRetryDelay = _apnsTokenRetryDelay,
    Future<void> Function(Duration)? delay,
  }) async {
    if (requiresApnsToken) {
      var apnsTokenAvailable = false;
      for (var attempt = 0; attempt < apnsTokenLoadAttempts; attempt++) {
        final apnsToken = (await getApnsToken())?.trim();
        if (apnsToken != null && apnsToken.isNotEmpty) {
          apnsTokenAvailable = true;
          break;
        }

        final hasAnotherAttempt = attempt + 1 < apnsTokenLoadAttempts;
        if (hasAnotherAttempt) {
          if (delay != null) {
            await delay(apnsTokenRetryDelay);
          } else {
            await Future<void>.delayed(apnsTokenRetryDelay);
          }
        }
      }

      if (!apnsTokenAvailable) {
        AppLogger.warning(
          'NOTIFY',
          'APNs token is not available yet; deferring FCM token load',
        );
        return null;
      }
    }

    return getFcmToken();
  }

  static bool get _requiresApnsToken =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  static void _emitToken(String token) {
    _latestToken = token;
    _tokenController.add(token);
  }

  static Stream<NotificationResponse> get localNotificationResponses =>
      _localResponseController.stream;

  FirebaseMessaging get _firebaseMessaging =>
      _messaging ?? FirebaseMessaging.instance;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    final firebaseReady = await _initializeFirebase();
    if (!firebaseReady) {
      return;
    }

    _initialized = true;
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(
        numiFirebaseMessagingBackgroundHandler,
      );
    }

    await _requestPermission();
    await _initializeLocalNotifications();
    await _requestLocalNotificationPermission();
    await _configureFirebaseForegroundPresentation();
    _listenForTokenRefresh();
    await _loadInitialToken();
    _listenForForegroundMessages();
    _listenForOpenedMessages();
    await _handleInitialMessage();
  }

  Future<bool> _initializeFirebase() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      return true;
    } catch (error, stackTrace) {
      _logNotificationError('firebase init', error, stackTrace);
      return false;
    }
  }

  Future<void> _initializeLocalNotifications() async {
    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
        defaultPresentBanner: true,
        defaultPresentList: true,
      );
      const settings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _localNotifications.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: _handleLocalNotificationResponse,
        onDidReceiveBackgroundNotificationResponse:
            numiLocalNotificationTapBackground,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_foregroundChannel);
    } catch (error, stackTrace) {
      _logNotificationError('local notification init', error, stackTrace);
    }
  }

  Future<void> _requestLocalNotificationPermission() async {
    try {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (error, stackTrace) {
      _logNotificationError(
        'local notification permission request',
        error,
        stackTrace,
      );
    }
  }

  Future<void> _requestPermission() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      AppLogger.info(
        'NOTIFY',
        'permission=${settings.authorizationStatus.name}',
      );
    } catch (error, stackTrace) {
      _logNotificationError('permission request', error, stackTrace);
    }
  }

  /// Lets Apple platforms present FCM notification payloads while the app is
  /// in the foreground. Data-only messages still use the local fallback below.
  Future<void> _configureFirebaseForegroundPresentation() async {
    try {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (error, stackTrace) {
      _logNotificationError('foreground presentation', error, stackTrace);
    }
  }

  Future<void> _loadInitialToken() async {
    await currentToken();
  }

  void _listenForTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen(
      (token) {
        _emitToken(token);
        AppLogger.info('NOTIFY', 'FCM token refreshed');
      },
      onError: (Object error, StackTrace stackTrace) {
        _logNotificationError('token refresh', error, stackTrace);
      },
    );
  }

  void _listenForForegroundMessages() {
    FirebaseMessaging.onMessage.listen(
      (message) {
        _messageController.add(message);
        logRemoteMessage(message, source: 'foreground');
        // Apple displays notification payloads through the native presentation
        // options above. Keep the local fallback for Android and for iOS
        // data-only messages that contain title/body fields.
        if (defaultTargetPlatform == TargetPlatform.android ||
            (defaultTargetPlatform == TargetPlatform.iOS &&
                message.notification == null)) {
          unawaited(_showForegroundNotification(message));
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        _logNotificationError('foreground message', error, stackTrace);
      },
    );
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? message.data['title'];
    final body = message.notification?.body ?? message.data['body'];
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      _foregroundChannel.id,
      _foregroundChannel.name,
      channelDescription: _foregroundChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'numi_notification',
    );
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
      presentList: true,
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    try {
      await _localNotifications.show(
        id: _notificationIdFor(message),
        title: title,
        body: body,
        notificationDetails: details,
        payload: jsonEncode(message.data),
      );
    } catch (error, stackTrace) {
      _logNotificationError('foreground local notification', error, stackTrace);
    }
  }

  int _notificationIdFor(RemoteMessage message) {
    final source = message.messageId ?? DateTime.now().toIso8601String();
    return source.hashCode & 0x7fffffff;
  }

  static void _handleLocalNotificationResponse(NotificationResponse response) {
    _localResponseController.add(response);
    AppLogger.info('NOTIFY', 'local tap id=${response.id}');
    AppLogger.payload('NOTIFY', 'local tap payload', response.payload);
  }

  void _listenForOpenedMessages() {
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        _messageController.add(message);
        logRemoteMessage(message, source: 'opened');
      },
      onError: (Object error, StackTrace stackTrace) {
        _logNotificationError('opened message', error, stackTrace);
      },
    );
  }

  Future<void> _handleInitialMessage() async {
    try {
      final message = await _firebaseMessaging.getInitialMessage();
      if (message == null) {
        return;
      }

      _messageController.add(message);
      logRemoteMessage(message, source: 'initial');
    } catch (error, stackTrace) {
      _logNotificationError('initial message', error, stackTrace);
    }
  }

  static void logRemoteMessage(
    RemoteMessage message, {
    required String source,
  }) {
    AppLogger.info('NOTIFY', '$source message id=${message.messageId}');
    AppLogger.payload('NOTIFY', '$source message payload', <String, Object?>{
      'title': message.notification?.title,
      'body': message.notification?.body,
      'data': message.data,
    });
  }
}

void _logNotificationError(String action, Object error, StackTrace stackTrace) {
  AppLogger.error(
    'NOTIFY',
    '$action failed',
    error: error,
    stackTrace: stackTrace,
  );
}
