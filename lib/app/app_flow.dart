import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/app/application/app_coordinator_cubit.dart';
import 'package:numi/app/application/app_coordinator_state.dart';
import 'package:numi/app/navigation/app_screen.dart';
import 'package:numi/core/data/session_scoped_repository_registry.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/utils/auth/login_name_validator.dart';
import 'package:numi/features/session/application/controllers/app_session_cubit.dart';
import 'package:numi/features/classroom/application/controllers/classroom_cubit.dart';
import 'package:numi/features/auth/application/contracts/auth_service.dart';
import 'package:numi/features/classroom/application/contracts/classroom_service.dart';
import 'package:numi/core/utils/phone/phone_region.dart';
import 'package:numi/features/auth/application/controllers/auth_cubit.dart';
import 'package:numi/features/auth/application/controllers/auth_state.dart';
import 'package:numi/app/app_screen_router.dart';
import 'package:numi/features/session/application/controllers/app_session_state.dart';
import 'package:numi/features/session/application/controllers/passcode_cubit.dart';
import 'package:numi/features/session/application/controllers/passcode_state.dart';

class AppFlow extends StatefulWidget {
  const AppFlow({
    super.key,
    this.authService,
    this.initialSession,
    this.restoreSessionOnStart = true,
  });

  final AuthService? authService;
  final AuthenticatedSession? initialSession;
  final bool restoreSessionOnStart;

  @override
  State<AppFlow> createState() => _AppFlowState();
}

class _AppFlowState extends State<AppFlow> {
  final loginNameController = TextEditingController();
  bool _loginNameHasInput = false;
  LoginNameKind? _loginNameKind;
  bool _loginNameSubmitAttempted = false;
  String? _lastSignupPhoneLookup;

  LoginNameValidationResult _normalizedLoginNameInput(
    PhoneRegion region,
    AuthEntryMode mode,
  ) {
    return normalizeLoginNameInput(
      region,
      loginNameController.text,
      phoneOnly: mode == AuthEntryMode.signup,
    );
  }

  @override
  void initState() {
    super.initState();
    loginNameController.addListener(_trackLoginNameInput);
  }

  @override
  void dispose() {
    loginNameController.removeListener(_trackLoginNameInput);
    loginNameController.dispose();
    super.dispose();
  }

  void _trackLoginNameInput() {
    final hasInput = loginNameController.text.trim().isNotEmpty;
    if (_loginNameHasInput == hasInput) {
      return;
    }

    setState(() {
      _loginNameHasInput = hasInput;
      if (!hasInput) {
        _loginNameKind = null;
      }
    });
  }

  void clearLoginNameInput() {
    _lastSignupPhoneLookup = null;
    if (loginNameController.text.isEmpty &&
        !_loginNameHasInput &&
        !_loginNameSubmitAttempted) {
      return;
    }

    loginNameController.clear();
    setState(() {
      _loginNameHasInput = false;
      _loginNameKind = null;
      _loginNameSubmitAttempted = false;
    });
  }

  void handleLoginNameInputChanged(
    AuthFlowCubit cubit,
    PhoneRegion region,
    AuthEntryMode mode,
    String value,
  ) {
    final hasInput = value.trim().isNotEmpty;
    final kind = detectLoginNameKind(
      value,
      phoneOnly: mode == AuthEntryMode.signup,
    );
    if (_loginNameHasInput != hasInput ||
        _loginNameKind != kind ||
        _loginNameSubmitAttempted) {
      setState(() {
        _loginNameHasInput = hasInput;
        _loginNameKind = kind;
        _loginNameSubmitAttempted = false;
      });
    }

    if (mode != AuthEntryMode.signup) {
      _lastSignupPhoneLookup = null;
      cubit.clearLoginLookup();
      return;
    }

    final normalized = normalizeLoginNameInput(region, value, phoneOnly: true);
    if (!normalized.isValid) {
      _lastSignupPhoneLookup = null;
      cubit.clearLoginLookup();
      return;
    }

    FocusScope.of(context).unfocus();
    if (_lastSignupPhoneLookup == normalized.loginName) {
      return;
    }

    _lastSignupPhoneLookup = normalized.loginName;
    cubit.lookupSignupPhone(normalized.loginName!);
  }

  void submitLoginName(
    AuthFlowCubit cubit,
    PhoneRegion region,
    AuthEntryMode mode,
  ) {
    if (!_loginNameSubmitAttempted) {
      setState(() {
        _loginNameSubmitAttempted = true;
      });
    }
    final normalized = _normalizedLoginNameInput(region, mode);
    if (!normalized.isValid) {
      HapticFeedback.selectionClick();
      return;
    }

    FocusScope.of(context).unfocus();
    cubit.submitLoginName(normalized.loginName!);
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<SessionScopedRepositoryRegistry>(
      create: (_) => SessionScopedRepositoryRegistry(),
      dispose: (registry) => registry.dispose(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AppCoordinatorCubit(
              hasInitialSession: widget.initialSession != null,
              restoreSessionOnStart:
                  widget.restoreSessionOnStart && widget.initialSession == null,
            ),
          ),
          BlocProvider(
            create: (context) {
              final cubit = AppSessionCubit(
                initialSession: widget.initialSession,
                authService: widget.authService ?? context.read<AuthService>(),
                profileResolver: context.read(),
                notificationPingService: context.read(),
              );
              context.read<SessionScopedRepositoryRegistry>().updateSession(
                isAuthenticated: cubit.state.isAuthenticated,
                sessionEpoch: cubit.state.sessionEpoch,
              );
              if (widget.restoreSessionOnStart &&
                  widget.initialSession == null) {
                unawaited(cubit.restoreSession());
              }
              return cubit;
            },
          ),
          BlocProvider(
            create: (context) => PasscodeCubit(passcodeService: context.read()),
          ),
          BlocProvider(
            create: (context) => ClassroomCubit(
              classroomService: context.read<ClassroomService>(),
            ),
          ),
          BlocProvider(
            create: (context) {
              return AuthFlowCubit(
                authService: widget.authService ?? context.read<AuthService>(),
                initialState: const AuthFlowState(screen: AuthScreen.welcome),
              );
            },
          ),
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<AuthFlowCubit, AuthFlowState>(
              listenWhen: (previous, current) =>
                  previous.screen != current.screen ||
                  previous.authenticationResultId !=
                      current.authenticationResultId,
              listener: (context, state) async {
                final coordinator = context.read<AppCoordinatorCubit>();
                switch (state.screen) {
                  case AuthScreen.welcome:
                    coordinator.showWelcome();
                  case AuthScreen.welcomeDetails:
                    coordinator.showWelcomeDetails();
                  case AuthScreen.login ||
                      AuthScreen.deviceVerification ||
                      AuthScreen.otp ||
                      AuthScreen.signup:
                    coordinator.showAuthScreen(state.screen);
                }
                final result = state.authenticationResult;
                if (result == null) {
                  return;
                }
                final needsSetup = await context
                    .read<PasscodeCubit>()
                    .prepareAfterAuthentication(
                      user: result.user,
                      loginName: result.loginName,
                      isNewlyRegistered: result.isNewlyRegistered,
                    );
                if (context.mounted && needsSetup) {
                  context.read<AppCoordinatorCubit>().showPasscode();
                }
                if (context.mounted) {
                  context.read<AuthFlowCubit>().consumeAuthenticationResult();
                }
              },
            ),
            BlocListener<PasscodeCubit, PasscodeState>(
              listenWhen: (previous, current) =>
                  previous.outcomeId != current.outcomeId,
              listener: (context, state) async {
                final outcome = state.outcome;
                if (outcome == null) {
                  return;
                }
                switch (outcome.type) {
                  case PasscodeOutcomeType.sessionReady:
                    final user = outcome.user;
                    if (user != null) {
                      await context.read<AppSessionCubit>().establishSession(
                        user: user,
                        isNewlyRegistered: outcome.isNewlyRegistered,
                      );
                    }
                  case PasscodeOutcomeType.resumeAuthentication:
                    final user = outcome.user;
                    final loginName = outcome.loginName;
                    if (user != null && loginName != null) {
                      final authCubit = context.read<AuthFlowCubit>();
                      authCubit.openLogin(mode: AuthEntryMode.login);
                      context.read<AppCoordinatorCubit>().showLogin();
                      await authCubit.resumeRememberedLogin(
                        loginName: loginName,
                        fallbackUser: user,
                      );
                    }
                  case PasscodeOutcomeType.cancelled:
                    final authCubit = context.read<AuthFlowCubit>();
                    authCubit.openLogin(mode: AuthEntryMode.login);
                    context.read<AppCoordinatorCubit>().showLogin();
                }
                if (context.mounted) {
                  context.read<PasscodeCubit>().consumeOutcome();
                }
              },
            ),
            BlocListener<AppSessionCubit, AppSessionState>(
              listenWhen: (previous, current) =>
                  previous.sessionEpoch != current.sessionEpoch ||
                  previous.status != current.status,
              listener: (context, state) {
                context.read<SessionScopedRepositoryRegistry>().updateSession(
                  isAuthenticated: state.isAuthenticated,
                  sessionEpoch: state.sessionEpoch,
                );
                context.read<ClassroomCubit>().clear();
                final coordinator = context.read<AppCoordinatorCubit>();
                switch (state.status) {
                  case SessionStatus.authenticated:
                    coordinator.showHome();
                  case SessionStatus.restoring:
                    coordinator.showRestoringSession();
                  case SessionStatus.unauthenticated:
                    clearLoginNameInput();
                    final authCubit = context.read<AuthFlowCubit>();
                    authCubit.openLogin(mode: AuthEntryMode.login);
                    coordinator.showLogin();
                }
              },
            ),
          ],
          child: BlocBuilder<AppCoordinatorCubit, AppCoordinatorState>(
            builder: (context, coordinatorState) {
              final colors = context.themeColors;
              final handlesSystemBack =
                  !coordinatorState.isRestoringSession &&
                  switch (coordinatorState.screen) {
                    AppScreen.welcomeDetails ||
                    AppScreen.login ||
                    AppScreen.deviceVerification ||
                    AppScreen.otp ||
                    AppScreen.signup => true,
                    AppScreen.welcome ||
                    AppScreen.passcode ||
                    AppScreen.restoring ||
                    AppScreen.home => false,
                  };
              final overlayStyle =
                  Theme.of(context).brightness == Brightness.dark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark;
              return PopScope(
                canPop: !handlesSystemBack,
                onPopInvokedWithResult: (didPop, result) {
                  if (!didPop) {
                    final coordinator = context.read<AppCoordinatorCubit>();
                    if (coordinator.state.screen == AppScreen.welcomeDetails) {
                      context.read<AuthFlowCubit>().openWelcome();
                      coordinator.showWelcome();
                      return;
                    }
                    final cubit = context.read<AuthFlowCubit>();
                    if (cubit.backFromLoginSwitchesEntryMode) {
                      clearLoginNameInput();
                    }
                    cubit.handleSystemBack();
                  }
                },
                child: AnnotatedRegion<SystemUiOverlayStyle>(
                  value: overlayStyle,
                  child: Scaffold(
                    backgroundColor: colors.pageBackground,
                    resizeToAvoidBottomInset:
                        coordinatorState.screen != AppScreen.home &&
                        coordinatorState.screen != AppScreen.login &&
                        coordinatorState.screen != AppScreen.otp &&
                        coordinatorState.screen != AppScreen.passcode,
                    body: AppScreenRouter(
                      loginNameController: loginNameController,
                      loginNameHasInput: _loginNameHasInput,
                      loginNameSubmitAttempted: _loginNameSubmitAttempted,
                      clearLoginNameInput: clearLoginNameInput,
                      normalizedLoginNameInput: _normalizedLoginNameInput,
                      handleLoginNameInputChanged: handleLoginNameInputChanged,
                      submitLoginName: submitLoginName,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
