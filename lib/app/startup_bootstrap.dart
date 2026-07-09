import 'dart:async';

import 'package:numi_flutter/core/localization/lingo_provider.dart';
import 'package:numi_flutter/core/network/api_metadata.dart';
import 'package:numi_flutter/core/theme/app_theme_controller.dart';
import 'package:numi_flutter/features/auth/auth_state.dart';
import 'package:numi_flutter/features/auth/otp_auth_api.dart';
import 'package:numi_flutter/features/auth/passcode_service.dart';
import 'package:numi_flutter/features/auth/services/auth_profile_resolver.dart';
import 'package:numi_flutter/features/profile/profile_api.dart';
import 'package:numi_flutter/features/profile/services/active_profile_session.dart';

class StartupBootstrapResult {
  const StartupBootstrapResult({
    required this.lingoProvider,
    required this.themeController,
    required this.authService,
    required this.initialAuthState,
  });

  final LingoProvider lingoProvider;
  final AppThemeController themeController;
  final OtpAuthService authService;
  final AuthState initialAuthState;
}

class StartupBootstrap {
  const StartupBootstrap({
    this.sessionTimeout = const Duration(seconds: 8),
    OtpAuthService? authService,
    ProfileService? profileService,
    ActiveProfileSession activeProfileSession = const ActiveProfileSession(),
    PasscodeService passcodeService = const SecurePasscodeService(),
  }) : _authService = authService,
       _profileService = profileService,
       _activeProfileSession = activeProfileSession,
       _passcodeService = passcodeService;

  final Duration sessionTimeout;
  final OtpAuthService? _authService;
  final ProfileService? _profileService;
  final ActiveProfileSession _activeProfileSession;
  final PasscodeService _passcodeService;

  Future<StartupBootstrapResult> run() async {
    await AppApiMetadataProvider.instance.loadClientInfo();

    final lingoProvider = LingoProvider();
    try {
      await lingoProvider.initialize();
    } catch (_) {
      // LingoProvider starts in Vietnamese with in-memory strings, so the app
      // can still render if secure storage or device locale access fails.
    }

    final themeController = AppThemeController();
    try {
      await themeController.initialize();
    } catch (_) {
      // Light theme is the startup fallback while dark theme is experimental.
    }

    final authService = _authService ?? OtpAuthApi();
    final initialAuthState = await _restoreInitialAuthState(
      authService,
    ).timeout(sessionTimeout, onTimeout: () => const AuthState());

    return StartupBootstrapResult(
      lingoProvider: lingoProvider,
      themeController: themeController,
      authService: authService,
      initialAuthState: initialAuthState,
    );
  }

  Future<AuthState> _restoreInitialAuthState(OtpAuthService authService) async {
    try {
      final user = await authService.restoreSession();
      if (user == null) {
        return const AuthState();
      }

      await _rememberAuthenticatedAccount(user);
      final profileResolver = AuthProfileResolver(
        profileService: _profileService ?? ProfileApi(),
        activeProfileSession: _activeProfileSession,
      );
      final profileResolution = await profileResolver.resolveForUser(user);
      return AuthState(
        screen: AppScreen.home,
        loginUser: user,
        profiles: profileResolution.profiles,
        activeProfile: profileResolution.activeProfile,
        profileLoadError: profileResolution.errorMessage,
      );
    } catch (_) {
      return const AuthState();
    }
  }

  Future<void> _rememberAuthenticatedAccount(LoginUser user) async {
    final phone = user.phone?.trim();
    if (user.id <= 0 || phone == null || phone.isEmpty) {
      return;
    }

    try {
      await _passcodeService.rememberLoginAccount(
        userId: user.id,
        phone: phone,
      );
    } catch (_) {
      // Remembered PIN login is optional and must not block app startup.
    }
  }
}
