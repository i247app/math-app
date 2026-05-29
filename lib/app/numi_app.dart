import 'package:flutter/material.dart';

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

  @override
  State<NumiApp> createState() => _NumiAppState();
}

class _NumiAppState extends State<NumiApp> {
  late final LingoProvider _lingoProvider = LingoProvider();
  late final Future<void> _languageInit = _lingoProvider.initialize();

  @override
  void dispose() {
    _lingoProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LingoScope(
      lingo: _lingoProvider,
      child: FutureBuilder<void>(
        future: _languageInit,
        builder: (context, snapshot) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: context.getText(AppKeys.appName),
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: AppColors.teal),
              scaffoldBackgroundColor: AppColors.mintMist,
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
    );
  }
}
