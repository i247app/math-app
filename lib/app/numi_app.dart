import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../features/onboarding/data/otp_auth_api.dart';
import '../features/onboarding/presentation/numi_home.dart';

class NumiApp extends StatelessWidget {
  const NumiApp({super.key, this.authService});

  final OtpAuthService? authService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NUMI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.teal),
        scaffoldBackgroundColor: AppColors.mintMist,
        useMaterial3: true,
      ),
      home: NumiHome(authService: authService),
    );
  }
}
