import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/data/session_scoped_repository_registry.dart';
import 'package:numi/core/theme/app_theme_colors.dart';
import 'package:numi/core/utils/auth/login_name_validator.dart';
import 'package:numi/features/session/application/app_session_cubit.dart';
import 'package:numi/features/classroom/application/classroom_cubit.dart';
import 'package:numi/features/classroom/data/classroom_api.dart';
import 'package:numi/features/homework/data/homework_api.dart';
import 'package:numi/features/profile/data/grade_api.dart';
import 'package:numi/features/auth/data/auth_api.dart';
import 'package:numi/core/utils/phone/phone_region.dart';
import 'package:numi/features/auth/application/auth_cubit.dart';
import 'package:numi/features/auth/application/auth_state.dart';
import 'package:numi/app/app_screen_router.dart';
import 'package:numi/features/session/application/app_session_state.dart';

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
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<GradeService>(create: (_) => GradeApi()),
        RepositoryProvider<ClassroomService>(create: (_) => ClassroomApi()),
        RepositoryProvider<ClassroomExerciseService>(
          create: (_) => ClassroomExerciseApi(),
        ),
        RepositoryProvider<SessionScopedRepositoryRegistry>(
          create: (_) => SessionScopedRepositoryRegistry(),
          dispose: (registry) => registry.dispose(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) {
              final cubit = AppSessionCubit(
                initialSession: widget.initialSession,
              );
              context.read<SessionScopedRepositoryRegistry>().updateSession(
                isAuthenticated: cubit.state.isAuthenticated,
                sessionEpoch: cubit.state.sessionEpoch,
              );
              return cubit;
            },
          ),
          BlocProvider(
            create: (context) => ClassroomCubit(
              classroomService: context.read<ClassroomService>(),
            ),
          ),
          BlocProvider(
            create: (context) {
              final sessionCubit = context.read<AppSessionCubit>();
              final cubit = AuthFlowCubit(
                authService: widget.authService,
                initialState: AuthFlowState(
                  screen: widget.initialSession == null
                      ? AppScreen.welcome
                      : AppScreen.home,
                ),
                onAuthenticated: sessionCubit.authenticate,
                onSessionCleared: sessionCubit.clear,
                onSessionRestoreStarted: sessionCubit.beginRestore,
              );
              if (widget.restoreSessionOnStart &&
                  widget.initialSession == null) {
                cubit.restoreSession();
              }
              return cubit;
            },
          ),
        ],
        child: BlocListener<AppSessionCubit, AppSessionState>(
          listenWhen: (previous, current) =>
              previous.sessionEpoch != current.sessionEpoch,
          listener: (context, state) {
            context.read<SessionScopedRepositoryRegistry>().updateSession(
              isAuthenticated: state.isAuthenticated,
              sessionEpoch: state.sessionEpoch,
            );
            context.read<ClassroomCubit>().clear();
          },
          child: BlocBuilder<AuthFlowCubit, AuthFlowState>(
            buildWhen: (previous, current) => previous.screen != current.screen,
            builder: (context, scaffoldState) {
              final colors = context.themeColors;
              final handlesSystemBack =
                  !scaffoldState.isRestoringSession &&
                  switch (scaffoldState.screen) {
                    AppScreen.welcomeDetails ||
                    AppScreen.login ||
                    AppScreen.otp ||
                    AppScreen.signup => true,
                    AppScreen.welcome ||
                    AppScreen.passcode ||
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
                    context.read<AuthFlowCubit>().handleSystemBack();
                  }
                },
                child: AnnotatedRegion<SystemUiOverlayStyle>(
                  value: overlayStyle,
                  child: Scaffold(
                    backgroundColor: colors.pageBackground,
                    resizeToAvoidBottomInset:
                        scaffoldState.screen != AppScreen.home &&
                        scaffoldState.screen != AppScreen.login &&
                        scaffoldState.screen != AppScreen.otp &&
                        scaffoldState.screen != AppScreen.passcode,
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
