import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/localization/lingo_scope.dart';
import 'package:numi/core/theme/app_theme.dart';
import 'package:numi/core/theme/app_theme_controller.dart';
import 'package:numi/core/theme/app_theme_scope.dart';
import 'package:numi/app/app_flow.dart';
import 'package:numi/app/composition/app_service_scope.dart';
import 'package:numi/app/composition/app_services.dart';
import 'package:numi/features/auth/application/contracts/auth_service.dart';
import 'package:numi/features/session/application/app_session_state.dart';

class NumiApp extends StatefulWidget {
  const NumiApp({
    super.key,
    this.authService,
    this.services,
    this.lingoProvider,
    this.themeController,
    this.initialSession,
    this.restoreSessionOnStart = false,
  });

  final AuthService? authService;
  final AppServices? services;
  final LingoProvider? lingoProvider;
  final AppThemeController? themeController;
  final AuthenticatedSession? initialSession;
  final bool restoreSessionOnStart;

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
  late AppThemeController _themeController;
  late final AppServices _services;
  AuthenticatedSession? _startupSession;
  late bool _restoreSessionOnNextHome;
  int _restartSeed = 0;

  @override
  void initState() {
    super.initState();
    _startupSession = widget.initialSession;
    _services = widget.services ?? AppServices(authService: widget.authService);
    _restoreSessionOnNextHome = widget.restoreSessionOnStart;
    _createLingoProvider(widget.lingoProvider);
    _createThemeController(widget.themeController);
  }

  @override
  void dispose() {
    _lingoProvider.dispose();
    _themeController.dispose();
    super.dispose();
  }

  void _createLingoProvider([LingoProvider? provider]) {
    _lingoProvider = provider ?? LingoProvider();
    if (provider == null) {
      unawaited(_initializeLingoProvider(_lingoProvider));
    }
  }

  Future<void> _initializeLingoProvider(LingoProvider provider) async {
    try {
      await provider.initialize();
    } catch (_) {
      // Default Vietnamese strings are already loaded in memory.
    }
  }

  void _createThemeController([AppThemeController? controller]) {
    _themeController = controller ?? AppThemeController();
    if (controller == null) {
      unawaited(_initializeThemeController(_themeController));
    }
  }

  Future<void> _initializeThemeController(AppThemeController controller) async {
    try {
      await controller.initialize();
    } catch (_) {
      // Light theme is already the in-memory default.
    }
  }

  void _restartApp() {
    final oldProvider = _lingoProvider;
    final oldThemeController = _themeController;
    setState(() {
      _restartSeed++;
      _startupSession = null;
      _restoreSessionOnNextHome = true;
      _createLingoProvider();
      _createThemeController();
    });
    oldProvider.dispose();
    oldThemeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _NumiRestartScope(
      restart: _restartApp,
      child: AnimatedBuilder(
        animation: _themeController,
        builder: (context, _) {
          return AppServiceScope(
            services: _services,
            child: LingoScope(
              lingo: _lingoProvider,
              child: AppThemeScope(
                controller: _themeController,
                child: MaterialApp(
                  key: ValueKey(_restartSeed),
                  debugShowCheckedModeBanner: false,
                  title: _lingoProvider.lookup(AppKeys.appName),
                  theme: AppTheme.light(),
                  darkTheme: AppTheme.dark(),
                  themeMode: _themeController.themeMode,
                  navigatorObservers: [_KeyboardDismissNavigatorObserver()],
                  home: AppFlow(
                    authService: _services.authService,
                    initialSession: _startupSession,
                    restoreSessionOnStart: _restoreSessionOnNextHome,
                  ),
                ),
              ),
            ),
          );
        },
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
