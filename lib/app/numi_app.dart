import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/extension/localization_extension.dart';
import '../core/localization/app_keys.dart';
import '../core/localization/lingo_provider.dart';
import '../core/localization/lingo_scope.dart';
import '../core/theme/app_colors.dart';
import 'package:numi_flutter/features/auth/auth_flow.dart';
import 'package:numi_flutter/features/auth/auth_state.dart';
import 'package:numi_flutter/features/auth/otp_auth_api.dart';

class NumiApp extends StatefulWidget {
  const NumiApp({
    super.key,
    this.authService,
    this.lingoProvider,
    this.initialAuthState,
    this.restoreSessionOnStart = false,
  });

  final OtpAuthService? authService;
  final LingoProvider? lingoProvider;
  final AuthState? initialAuthState;
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
  AuthState? _startupAuthState;
  late bool _restoreSessionOnNextHome;
  int _restartSeed = 0;

  @override
  void initState() {
    super.initState();
    _startupAuthState = widget.initialAuthState;
    _restoreSessionOnNextHome = widget.restoreSessionOnStart;
    _createLingoProvider(widget.lingoProvider);
  }

  @override
  void dispose() {
    _lingoProvider.dispose();
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

  void _restartApp() {
    final oldProvider = _lingoProvider;
    setState(() {
      _restartSeed++;
      _startupAuthState = null;
      _restoreSessionOnNextHome = true;
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
        child: MaterialApp(
          key: ValueKey(_restartSeed),
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => context.getText(AppKeys.appName),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.teal),
            scaffoldBackgroundColor: AppColors.mintMist,
            textTheme: GoogleFonts.andikaTextTheme(),
            useMaterial3: true,
          ),
          navigatorObservers: [_KeyboardDismissNavigatorObserver()],
          home: NumiHome(
            authService: widget.authService,
            initialAuthState: _startupAuthState,
            restoreSessionOnStart: _restoreSessionOnNextHome,
          ),
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
