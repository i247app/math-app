import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/app/application/app_coordinator_cubit.dart';
import 'package:numi/app/navigation/app_screen.dart';
import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/utils/auth/login_name_validator.dart';
import 'package:numi/features/auth/application/controllers/auth_cubit.dart';
import 'package:numi/features/auth/application/controllers/auth_state.dart';
import 'package:numi/core/utils/phone/phone_region.dart';
import 'package:numi/features/auth/application/errors/auth_error_messages.dart';
import 'package:numi/features/auth/presentation/screens/device_verification_screen.dart';
import 'package:numi/features/auth/presentation/screens/login_screen.dart';
import 'package:numi/features/auth/presentation/screens/otp_screen.dart';
import 'package:numi/features/auth/presentation/screens/passcode_screen.dart';
import 'package:numi/features/auth/presentation/screens/signup_screen.dart';
import 'package:numi/features/session/presentation/screens/session_dashboard_screen.dart';
import 'package:numi/features/session/application/controllers/app_session_cubit.dart';
import 'package:numi/features/session/application/controllers/passcode_cubit.dart';
import 'package:numi/features/session/application/controllers/passcode_state.dart';
import 'package:numi/features/welcome/presentation/screens/welcome_details_screen.dart';
import 'package:numi/features/welcome/presentation/screens/welcome_screen.dart';
import 'package:numi/shared/widgets/loading_screen.dart';

class AppScreenRouter extends StatelessWidget {
  const AppScreenRouter({
    super.key,
    required this.loginNameController,
    required this.loginNameHasInput,
    required this.loginNameSubmitAttempted,
    required this.clearLoginNameInput,
    required this.normalizedLoginNameInput,
    required this.handleLoginNameInputChanged,
    required this.submitLoginName,
  });

  final TextEditingController loginNameController;
  final bool loginNameHasInput;
  final bool loginNameSubmitAttempted;
  final VoidCallback clearLoginNameInput;
  final LoginNameValidationResult Function(
    PhoneRegion region,
    AuthEntryMode mode,
  )
  normalizedLoginNameInput;
  final void Function(
    AuthFlowCubit cubit,
    PhoneRegion region,
    AuthEntryMode mode,
    String value,
  )
  handleLoginNameInputChanged;
  final void Function(
    AuthFlowCubit cubit,
    PhoneRegion region,
    AuthEntryMode mode,
  )
  submitLoginName;

  static bool _isInlineSignupUsernameError(AuthFlowState state) {
    if (state.screen != AuthScreen.signup) {
      return false;
    }

    return isSignupUsernameExistsError(state.authError);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PasscodeCubit, PasscodeState>(
      builder: (context, passcodeState) {
        return BlocConsumer<AuthFlowCubit, AuthFlowState>(
          buildWhen: (previous, current) {
            return true;
          },
          listenWhen: (previous, current) {
            final hasNewError =
                previous.authError != current.authError &&
                current.authError != null;
            final leftLoginScreen =
                previous.screen == AuthScreen.login &&
                current.screen != AuthScreen.login;

            return hasNewError || leftLoginScreen;
          },
          listener: (context, state) {
            if (state.screen != AuthScreen.login) {
              clearLoginNameInput();
            }

            final authError = state.authError;
            if (authError != null &&
                state.screen != AuthScreen.otp &&
                !_isInlineSignupUsernameError(state)) {
              context.showErrorDialog(localizedAuthError(context, authError));
            }
          },
          builder: (context, state) {
            final cubit = context.read<AuthFlowCubit>();
            final coordinator = context.watch<AppCoordinatorCubit>();
            final coordinatorState = coordinator.state;
            final passcodeCubit = context.read<PasscodeCubit>();
            final screen = coordinatorState.screen;
            final isSignupEntry = state.authEntryMode == AuthEntryMode.signup;
            final normalizedLoginName = normalizedLoginNameInput(
              state.phoneRegion,
              state.authEntryMode,
            );
            final lookupMatchesLoginName =
                state.checkedLoginName == normalizedLoginName.loginName;
            final blocksSignupPhoneAction =
                isSignupEntry &&
                lookupMatchesLoginName &&
                state.loginNameExists == true;
            final canSubmitLoginName = isSignupEntry
                ? normalizedLoginName.isValid && !blocksSignupPhoneAction
                : loginNameHasInput;
            final validationErrorKey = normalizedLoginName.errorKey;
            final delaysValidationError =
                validationErrorKey == AppKeys.invalidEmail ||
                validationErrorKey == AppKeys.phoneTooShort;
            final loginNameInputErrorKey = isSignupEntry
                ? validationErrorKey == AppKeys.phoneTooShort
                      ? null
                      : validationErrorKey
                : delaysValidationError && !loginNameSubmitAttempted
                ? null
                : validationErrorKey;
            final loginNameErrorText = !loginNameHasInput
                ? null
                : loginNameInputErrorKey != null
                ? context.getText(loginNameInputErrorKey)
                : _loginLookupErrorText(
                    context: context,
                    isSignupEntry: isSignupEntry,
                    lookupMatchesLoginName: lookupMatchesLoginName,
                    loginNameExists: state.loginNameExists,
                    loginLookupError: state.loginLookupError,
                  );
            final actionLabel = context.getText(
              isSignupEntry ? AppKeys.signup : AppKeys.login,
            );
            final useSafeArea =
                !coordinatorState.isRestoringSession &&
                screen != AppScreen.welcome &&
                screen != AppScreen.welcomeDetails &&
                screen != AppScreen.home;
            final screenChild = coordinatorState.isRestoringSession
                ? LoadingScreen(
                    key: const ValueKey('session-loading'),
                    message: context.getText(AppKeys.restoringSession),
                  )
                : switch (screen) {
                    AppScreen.welcome => WelcomeScreen(
                      key: const ValueKey('welcome'),
                      onStart: () {
                        cubit.openWelcomeDetails();
                        coordinator.showWelcomeDetails();
                      },
                      onLogin: () async {
                        if (await passcodeCubit.openRememberedUnlock()) {
                          coordinator.showPasscode();
                          return;
                        }
                        cubit.openLoginFromWelcome();
                        coordinator.showLogin();
                      },
                    ),
                    AppScreen.welcomeDetails => WelcomeDetailsScreen(
                      key: const ValueKey('welcome-details'),
                      onStart: () {
                        cubit.openSignupEntry();
                        coordinator.showLogin();
                      },
                      onBack: () {
                        cubit.openWelcome();
                        coordinator.showWelcome();
                      },
                    ),
                    AppScreen.login => LoginScreen(
                      key: const ValueKey('login'),
                      controller: loginNameController,
                      region: state.phoneRegion,
                      showPhoneRegion:
                          isSignupEntry ||
                          (normalizedLoginName.kind == LoginNameKind.phone &&
                              RegExp(r'\d').hasMatch(loginNameController.text)),
                      onRegionChanged: (region) {
                        clearLoginNameInput();
                        cubit.clearLoginLookup();
                        cubit.selectPhoneRegion(region);
                      },
                      onBack: () {
                        if (cubit.backFromLoginSwitchesEntryMode) {
                          clearLoginNameInput();
                        }
                        cubit.backFromLogin();
                      },
                      onSendOtp: () => submitLoginName(
                        cubit,
                        state.phoneRegion,
                        state.authEntryMode,
                      ),
                      actionLabel: actionLabel,
                      isSignupEntry: isSignupEntry,
                      isSendingOtp: state.isSendingOtp,
                      isCheckingLoginName: state.isCheckingLoginName,
                      canSendOtp: canSubmitLoginName,
                      canLoginWithPin: passcodeState.canLoginWithPin,
                      onLoginWithPin: () {
                        passcodeCubit.openPinLogin();
                        coordinator.showPasscode();
                      },
                      onSwitchEntryMode: () {
                        clearLoginNameInput();
                        cubit.switchAuthEntryMode(
                          isSignupEntry
                              ? AuthEntryMode.login
                              : AuthEntryMode.signup,
                        );
                      },
                      onLoginNameChanged: (value) =>
                          handleLoginNameInputChanged(
                            cubit,
                            state.phoneRegion,
                            state.authEntryMode,
                            value,
                          ),
                      loginNameErrorText: loginNameErrorText,
                    ),
                    AppScreen.deviceVerification => DeviceVerificationScreen(
                      key: const ValueKey('device-verification'),
                      devices: state.trustedDevices,
                      selectedDeviceId: state.selectedTrustedDeviceId,
                      isLoading: state.isLoadingTrustedDevices,
                      isSending: state.isSendingOtp,
                      errorText: state.trustedDeviceError,
                      onBack: cubit.backFromDeviceVerification,
                      onRetry: cubit.reloadTrustedDevices,
                      onSelectDevice: cubit.selectTrustedDevice,
                      onSend: cubit.sendOtpToTrustedDevice,
                    ),
                    AppScreen.otp => OtpScreen(
                      key: const ValueKey('otp'),
                      onBack: cubit.backFromOtp,
                      onConfirm: cubit.verifyOtp,
                      onResend: cubit.resendLoginOtp,
                      isVerifyingOtp:
                          state.isVerifyingOtp || state.isSendingOtp,
                      resendSeconds: state.otpExpiresIn ?? 0,
                      resendResetId: state.otpPreviewId,
                      autoFocusCode: state.otpFlow == OtpFlow.signup,
                      devOtpCode: state.showDevOtpPreview
                          ? state.devOtpCode
                          : null,
                      otpError: state.otpError,
                      otpErrorId: state.otpErrorId,
                    ),
                    AppScreen.signup => SignupScreen(
                      key: const ValueKey('signup'),
                      onBack: cubit.cancelSignupToLogin,
                      isSigningUp: state.isSigningUp,
                      initialForm: cubit.pendingSignupForm,
                      authError: state.authError,
                      onContinue: (form) {
                        HapticFeedback.mediumImpact();
                        cubit.submitSignup(form);
                      },
                    ),
                    AppScreen.passcode => PasscodeScreen(
                      key: ValueKey('passcode-${passcodeState.mode.name}'),
                      mode: passcodeState.mode == PasscodeMode.setup
                          ? PasscodeScreenMode.setup
                          : PasscodeScreenMode.unlock,
                      onBack: passcodeCubit.cancel,
                      onSubmit: (passcode) async {
                        await passcodeCubit.submit(passcode);
                        return null;
                      },
                      onSkip: passcodeState.canSkip
                          ? passcodeCubit.skipSetup
                          : null,
                      isBusy: passcodeState.isBusy,
                      errorText: passcodeState.error,
                      errorId: passcodeState.errorId,
                    ),
                    AppScreen.restoring => LoadingScreen(
                      key: const ValueKey('session-loading'),
                      message: context.getText(AppKeys.restoringSession),
                    ),
                    AppScreen.home => SessionDashboardScreen(
                      key: const ValueKey('home'),
                      onBack: () {
                        cubit.openLogin(mode: AuthEntryMode.login);
                        coordinator.showLogin();
                      },
                      onLogout: context.read<AppSessionCubit>().logout,
                    ),
                  };
            final transitionChild = KeyedSubtree(
              key: ValueKey(
                coordinatorState.isRestoringSession
                    ? 'session-loading'
                    : 'app-screen-${screen.name}',
              ),
              child: SafeArea(
                top: useSafeArea,
                bottom: useSafeArea && screen != AppScreen.home,
                left: useSafeArea,
                right: useSafeArea,
                child: screenChild,
              ),
            );

            return Stack(
              fit: StackFit.expand,
              children: [
                if (!coordinatorState.isRestoringSession &&
                    screen == AppScreen.welcome)
                  _LoginScreenWarmup(
                    region: state.phoneRegion,
                    actionLabel: actionLabel,
                    isSignupEntry: isSignupEntry,
                  ),
                _AppScreenSlideSwitcher(
                  screen: coordinatorState.isRestoringSession ? null : screen,
                  child: transitionChild,
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Builds Login while the initial Welcome page is visible. This executes the
/// Android debug/JIT path for its TextField and font styles before the user
/// starts the horizontal transition, without rendering or exposing it.
class _LoginScreenWarmup extends StatefulWidget {
  const _LoginScreenWarmup({
    required this.region,
    required this.actionLabel,
    required this.isSignupEntry,
  });

  final PhoneRegion region;
  final String actionLabel;
  final bool isSignupEntry;

  @override
  State<_LoginScreenWarmup> createState() => _LoginScreenWarmupState();
}

class _LoginScreenWarmupState extends State<_LoginScreenWarmup> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
      child: TickerMode(
        enabled: false,
        child: IgnorePointer(
          child: ExcludeSemantics(
            child: LoginScreen(
              controller: _controller,
              region: widget.region,
              showPhoneRegion: true,
              onRegionChanged: (_) {},
              onBack: () {},
              onSendOtp: () {},
              actionLabel: widget.actionLabel,
              isSignupEntry: widget.isSignupEntry,
              isSendingOtp: false,
              isCheckingLoginName: false,
              canSendOtp: false,
              canLoginWithPin: false,
              onLoginWithPin: () {},
              onSwitchEntryMode: () {},
              onLoginNameChanged: (_) {},
            ),
          ),
        ),
      ),
    );
  }
}

String? _loginLookupErrorText({
  required BuildContext context,
  required bool isSignupEntry,
  required bool lookupMatchesLoginName,
  required bool? loginNameExists,
  required String? loginLookupError,
}) {
  if (!lookupMatchesLoginName) {
    return null;
  }

  if (isSignupEntry && loginNameExists == true) {
    return context.getText(AppKeys.signupPhoneAlreadyRegistered);
  }

  if (isSignupEntry && loginNameExists == false) {
    return null;
  }

  if (!isSignupEntry && loginNameExists == false) {
    return loginLookupError ?? context.getText(AppKeys.loginNameNotRegistered);
  }

  return loginLookupError;
}

class _AppScreenSlideSwitcher extends StatefulWidget {
  const _AppScreenSlideSwitcher({required this.screen, required this.child});

  final AppScreen? screen;
  final Widget child;

  @override
  State<_AppScreenSlideSwitcher> createState() =>
      _AppScreenSlideSwitcherState();
}

class _AppScreenSlideSwitcherState extends State<_AppScreenSlideSwitcher>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Widget _currentChild;
  Widget? _previousChild;
  int _direction = 1;
  _AuthScreenTransition _transition = _AuthScreenTransition.fade;

  @override
  void initState() {
    super.initState();
    _currentChild = widget.child;
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 430),
          value: 1,
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed && _previousChild != null) {
            setState(() => _previousChild = null);
          }
        });
  }

  @override
  void didUpdateWidget(covariant _AppScreenSlideSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.child.key == _currentChild.key) {
      _currentChild = widget.child;
      return;
    }

    setState(() {
      _previousChild = _currentChild;
      _currentChild = widget.child;
      _direction = _transitionDirection(
        from: oldWidget.screen,
        to: widget.screen,
      );
      _transition = _transitionFor(from: oldWidget.screen, to: widget.screen);
    });

    // Home dashboards own their entrance animations. Running the app-level
    // fade as well makes their first entrance look like a second reload.
    if (widget.screen == AppScreen.home ||
        MediaQuery.disableAnimationsOf(context)) {
      _previousChild = null;
      _controller.value = 1;
      return;
    }

    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final animation = CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic,
          );

          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final value = animation.value;
              final usesPageSlide =
                  _transition == _AuthScreenTransition.pageSlide;
              final usesFadeScale =
                  _transition == _AuthScreenTransition.fadeScale;
              final currentScale = usesFadeScale ? 0.98 + (0.02 * value) : 1.0;
              final previousScale = usesFadeScale ? 1.0 - (0.01 * value) : 1.0;

              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  if (_previousChild != null)
                    Transform.translate(
                      offset: usesPageSlide
                          ? Offset(-_direction * width * value, 0)
                          : Offset.zero,
                      child: Transform.scale(
                        scale: previousScale,
                        child: FadeTransition(
                          opacity: usesPageSlide
                              ? const AlwaysStoppedAnimation(1)
                              : ReverseAnimation(animation),
                          child: _previousChild,
                        ),
                      ),
                    ),
                  Transform.translate(
                    offset: usesPageSlide
                        ? Offset(_direction * width * (1 - value), 0)
                        : Offset.zero,
                    child: Transform.scale(
                      scale: currentScale,
                      child: FadeTransition(
                        opacity: usesPageSlide
                            ? const AlwaysStoppedAnimation(1)
                            : animation,
                        child: _currentChild,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  static int _transitionDirection({AppScreen? from, AppScreen? to}) {
    if (from == null || to == null) {
      return 1;
    }
    return _screenRank(to) >= _screenRank(from) ? 1 : -1;
  }

  static _AuthScreenTransition _transitionFor({
    AppScreen? from,
    AppScreen? to,
  }) {
    if (from == null || to == null) {
      return _AuthScreenTransition.fade;
    }

    final fromWelcomeFlow =
        from == AppScreen.welcome || from == AppScreen.welcomeDetails;
    final toWelcomeFlow =
        to == AppScreen.welcome || to == AppScreen.welcomeDetails;

    if ((fromWelcomeFlow && toWelcomeFlow) ||
        (fromWelcomeFlow && to == AppScreen.login) ||
        (from == AppScreen.login && toWelcomeFlow)) {
      return _AuthScreenTransition.pageSlide;
    }

    if ((from == AppScreen.login && to == AppScreen.passcode) ||
        (from == AppScreen.passcode && to == AppScreen.login)) {
      return _AuthScreenTransition.fadeScale;
    }

    return _AuthScreenTransition.fade;
  }

  static int _screenRank(AppScreen screen) {
    return switch (screen) {
      AppScreen.welcome => 0,
      AppScreen.welcomeDetails => 1,
      AppScreen.login => 2,
      AppScreen.deviceVerification => 3,
      AppScreen.otp => 4,
      AppScreen.signup => 5,
      AppScreen.passcode => 6,
      AppScreen.restoring => 7,
      AppScreen.home => 8,
    };
  }
}

enum _AuthScreenTransition { fade, pageSlide, fadeScale }
