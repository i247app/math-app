import 'package:numi/app/composition/app_services.dart';
import 'package:numi/core/localization/lingo_provider.dart';
import 'package:numi/core/network/api_metadata.dart';
import 'package:numi/core/theme/app_theme_controller.dart';
import 'package:numi/features/auth/application/contracts/auth_service.dart';
import 'package:numi/features/auth/domain/models/auth_models.dart';
import 'package:numi/features/session/services/passcode_service.dart';
import 'package:numi/features/profile/data/active_profile_session.dart';
import 'package:numi/features/profile/application/contracts/profile_service.dart';
import 'package:numi/features/session/application/app_session_state.dart';

class StartupBootstrapResult {
  const StartupBootstrapResult({
    required this.lingoProvider,
    required this.themeController,
    required this.services,
    required this.authService,
    required this.initialSession,
  });

  final LingoProvider lingoProvider;
  final AppThemeController themeController;
  final AppServices services;
  final AuthService authService;
  final AuthenticatedSession? initialSession;
}

class StartupBootstrap {
  const StartupBootstrap({
    this.sessionTimeout = const Duration(seconds: 8),
    AppServices? services,
    AuthService? authService,
    ProfileService? profileService,
    ActiveProfileSession activeProfileSession = const ActiveProfileSession(),
    PasscodeService passcodeService = const SecurePasscodeService(),
  }) : _services = services,
       _authService = authService,
       _profileService = profileService,
       _activeProfileSession = activeProfileSession,
       _passcodeService = passcodeService;

  final Duration sessionTimeout;
  final AppServices? _services;
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

    final services =
        _services ??
        AppServices(
          authService: _authService,
          profileService: _profileService,
          activeProfileSession: _activeProfileSession,
          passcodeService: _passcodeService,
        );
    final authService = services.authService;
    final initialSession = await _restoreInitialSession(
      authService,
      services,
    ).timeout(sessionTimeout, onTimeout: () => null);

    return StartupBootstrapResult(
      lingoProvider: lingoProvider,
      themeController: themeController,
      services: services,
      authService: authService,
      initialSession: initialSession,
    );
  }

  Future<AuthenticatedSession?> _restoreInitialSession(
    AuthService authService,
    AppServices services,
  ) async {
    try {
      final user = await authService.restoreSession();
      if (user == null) {
        return null;
      }

      await _rememberAuthenticatedAccount(user);
      final profileResolution = await services.profileSessionResolver
          .resolveForUserId(user.id);
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
    final email = user.email?.trim();
    final loginName = phone != null && phone.isNotEmpty ? phone : email;
    if (user.id <= 0 || loginName == null || loginName.isEmpty) {
      return;
    }

    try {
      await _passcodeService.rememberLoginAccount(
        userId: user.id,
        loginName: loginName,
      );
    } catch (_) {
      // Remembered PIN login is optional and must not block app startup.
    }
  }
}
