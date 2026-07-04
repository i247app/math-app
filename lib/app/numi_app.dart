import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/extension/localization_extension.dart';
import '../core/localization/app_keys.dart';
import '../core/localization/lingo_provider.dart';
import '../core/localization/lingo_scope.dart';
import '../core/theme/app_colors.dart';
import 'package:numi_flutter/features/auth/otp_auth_api.dart';
import 'package:numi_flutter/features/auth/auth_flow.dart';

class NumiApp extends StatefulWidget {
  const NumiApp({super.key, this.authService});

  final OtpAuthService? authService;

  static void restart(BuildContext context) {
    final element = context
        .getElementForInheritedWidgetOfExactType<_NumiRestartScope>();
    final scope = element?.widget as _NumiRestartScope?;
    assert(scope != null, 'No Numi restart scope found in context.');
    scope?.restart();
  }

  @override
  State<NumiApp> createState() => _NumiAppState();
}

class _NumiAppState extends State<NumiApp> {
  late LingoProvider _lingoProvider;
  late Future<void> _languageInit;
  int _restartSeed = 0;

  @override
  void initState() {
    super.initState();
    _createLingoProvider();
  }

  @override
  void dispose() {
    _lingoProvider.dispose();
    super.dispose();
  }

  void _createLingoProvider() {
    _lingoProvider = LingoProvider();
    _languageInit = _lingoProvider.initialize();
  }

  void _restartApp() {
    final oldProvider = _lingoProvider;
    setState(() {
      _restartSeed++;
      _createLingoProvider();
    });
    oldProvider.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _NumiRestartScope(
      restart: _restartApp,
      child: LingoScope(
        lingo: _lingoProvider,
        child: FutureBuilder<void>(
          future: _languageInit,
          builder: (context, snapshot) {
            return MaterialApp(
              key: ValueKey(_restartSeed),
              debugShowCheckedModeBanner: false,
              title: context.getText(AppKeys.appName),
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: AppColors.teal),
                scaffoldBackgroundColor: AppColors.mintMist,
                textTheme: GoogleFonts.andikaTextTheme(),
                useMaterial3: true,
              ),
              navigatorObservers: [_KeyboardDismissNavigatorObserver()],
              home: snapshot.connectionState == ConnectionState.done
                  ? NumiHome(authService: widget.authService)
                  : const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _KeyboardDismissNavigatorObserver extends NavigatorObserver {
  void _dismissKeyboard({bool afterFrame = false}) {
    void dismiss() {
      FocusManager.instance.primaryFocus?.unfocus();
      SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    }

    dismiss();
    if (afterFrame) {
      WidgetsBinding.instance.addPostFrameCallback((_) => dismiss());
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _dismissKeyboard();
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _dismissKeyboard(afterFrame: true);
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _dismissKeyboard(afterFrame: true);
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _dismissKeyboard(afterFrame: true);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

class _NumiRestartScope extends InheritedWidget {
  const _NumiRestartScope({required this.restart, required super.child});

  final VoidCallback restart;

  @override
  bool updateShouldNotify(_NumiRestartScope oldWidget) {
    return restart != oldWidget.restart;
  }
}
