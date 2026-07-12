import 'dart:async';

import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/network/api_metadata.dart';
import 'package:numi/core/theme/app_theme_controller.dart';
import 'package:numi/features/auth/data/auth_api.dart';
import 'package:numi/features/auth/data/auth_models.dart';
import 'package:numi/features/session/services/passcode_service.dart';
import 'package:numi/features/profile/profile_api.dart';
import 'package:numi/features/profile/services/active_profile_session.dart';
import 'package:numi/features/session/presentation/bloc/app_session_state.dart';
import 'package:numi/features/session/services/profile_session_resolver.dart';

class StartupBootstrapResult {
  const StartupBootstrapResult({
    required this.lingoProvider,
    required this.themeController,
    required this.authService,
    required this.initialSession,
  });

  final LingoProvider lingoProvider;
  final AppThemeController themeController;
  final AuthService authService;
  final AuthenticatedSession? initialSession;
}

class StartupBootstrap {
  const StartupBootstrap({
    this.sessionTimeout = const Duration(seconds: 8),
    AuthService? authService,
    ProfileService? profileService,
    ActiveProfileSession activeProfileSession = const ActiveProfileSession(),
    PasscodeService passcodeService = const SecurePasscodeService(),
  }) : _authService = authService,
       _profileService = profileService,
       _activeProfileSession = activeProfileSession,
       _passcodeService = passcodeService;

  final Duration sessionTimeout;
  final AuthService? _authService;
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

    final authService = _authService ?? AuthApi();
    final initialSession = await _restoreInitialSession(
      authService,
    ).timeout(sessionTimeout, onTimeout: () => null);

    return StartupBootstrapResult(
      lingoProvider: lingoProvider,
      themeController: themeController,
      authService: authService,
      initialSession: initialSession,
    );
  }

  Future<AuthenticatedSession?> _restoreInitialSession(
    AuthService authService,
  ) async {
    try {
      final user = await authService.restoreSession();
      if (user == null) {
        return null;
      }

      await _rememberAuthenticatedAccount(user);
      final profileResolver = ProfileSessionResolver(
        profileService: _profileService ?? ProfileApi(),
        activeProfileSession: _activeProfileSession,
      );
      final profileResolution = await profileResolver.resolveForUserId(user.id);
      return AuthenticatedSession(
        user: user,
        profiles: profileResolution.profiles,
        activeProfile: profileResolution.activeProfile,
        profileLoadError: profileResolution.errorMessage,
      );
    } catch (_) {
      return null;
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
