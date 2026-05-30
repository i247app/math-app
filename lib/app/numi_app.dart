import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/extension/localization_extension.dart';
import '../core/localization/app_keys.dart';
import '../core/localization/lingo_provider.dart';
import '../core/localization/lingo_scope.dart';
import '../core/theme/app_colors.dart';
import '../features/onboarding/data/otp_auth_api.dart';
import '../features/onboarding/presentation/numi_home.dart';

class NumiApp extends StatefulWidget {
  const NumiApp({super.key, this.authService});

  final OtpAuthService? authService;

  static void restart(BuildContext context) {
    final element =
        context.getElementForInheritedWidgetOfExactType<_NumiRestartScope>();
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

class _NumiRestartScope extends InheritedWidget {
  const _NumiRestartScope({
    required this.restart,
    required super.child,
  });

  final VoidCallback restart;

  @override
  bool updateShouldNotify(_NumiRestartScope oldWidget) {
    return restart != oldWidget.restart;
  }
}
