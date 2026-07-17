import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:numi/core/extension/localization_extension.dart';
import 'package:numi/core/localization/app_keys.dart';
import 'package:numi/core/utils/phone/phone_number_validator.dart';
import 'package:numi/features/auth/application/auth_cubit.dart';
import 'package:numi/features/auth/application/auth_state.dart';
import 'package:numi/core/utils/phone/phone_region.dart';
import 'package:numi/features/auth/errors/auth_error_messages.dart';
import 'package:numi/features/auth/presentation/login_screen.dart';
import 'package:numi/features/auth/presentation/otp_screen.dart';
import 'package:numi/features/auth/presentation/passcode_screen.dart';
import 'package:numi/features/auth/presentation/signup_screen.dart';
import 'package:numi/features/session/presentation/session_dashboard_screen.dart';
import 'package:numi/features/welcome/presentation/welcome_details_screen.dart';
import 'package:numi/features/welcome/presentation/welcome_screen.dart';
import 'package:numi/shared/widgets/loading_screen.dart';

class AppScreenRouter extends StatelessWidget {
  const AppScreenRouter({
    super.key,
    required this.phoneController,
    required this.phoneHasInput,
    required this.clearLoginPhoneInput,
    required this.normalizedPhoneInput,
    required this.handlePhoneInputChanged,
    required this.sendOtp,
  });

  final TextEditingController phoneController;
  final bool phoneHasInput;
  final VoidCallback clearLoginPhoneInput;
  final PhoneValidationResult Function(PhoneRegion region) normalizedPhoneInput;
  final void Function(AuthFlowCubit cubit, PhoneRegion region, String value)
  handlePhoneInputChanged;
  final void Function(AuthFlowCubit cubit, PhoneRegion region) sendOtp;

  static bool _isInlineSignupUsernameError(AuthFlowState state) {
    if (state.screen != AppScreen.signup) {
      return false;
    }

    return isSignupUsernameExistsError(state.authError);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthFlowCubit, AuthFlowState>(
      buildWhen: (previous, current) {
        if (previous.screen == AppScreen.home &&
            current.screen == AppScreen.home) {
          return false;
        }
        return true;
      },
      listenWhen: (previous, current) {
        final hasNewError =
            previous.authError != current.authError &&
            current.authError != null;
        final leftLoginScreen =
            previous.screen == AppScreen.login &&
            current.screen != AppScreen.login;

        return hasNewError || leftLoginScreen;
      },
      listener: (context, state) {
        if (state.screen != AppScreen.login) {
          clearLoginPhoneInput();
        }

        final authError = state.authError;
        if (authError != null &&
            state.screen != AppScreen.otp &&
            !_isInlineSignupUsernameError(state)) {
          context.showErrorDialog(localizedAuthError(context, authError));
        }
      },
      builder: (context, state) {
        final cubit = context.read<AuthFlowCubit>();
        final normalizedPhone = normalizedPhoneInput(state.phoneRegion);
        final isSignupEntry = state.authEntryMode == AuthEntryMode.signup;
        final lookupMatchesPhone = state.checkedPhone == normalizedPhone.phone;
        final blocksPhoneAction =
            lookupMatchesPhone &&
            ((isSignupEntry && state.phoneExists == true) ||
                (!isSignupEntry && state.phoneLookupErrorStatus == 4006));
        final phoneComplete = normalizedPhone.isValid && !blocksPhoneAction;
        final phoneInputErrorKey =
            normalizedPhone.errorKey == AppKeys.phoneTooShort
            ? null
            : normalizedPhone.errorKey;
        final phoneErrorText = !phoneHasInput
            ? null
            : phoneInputErrorKey != null
            ? context.getText(phoneInputErrorKey)
            : _phoneLookupErrorText(
                context: context,
                isSignupEntry: isSignupEntry,
                lookupMatchesPhone: lookupMatchesPhone,
                phoneExists: state.phoneExists,
                phoneLookupError: state.phoneLookupError,
              );
        final actionLabel = context.getText(
          isSignupEntry ? AppKeys.signup : AppKeys.login,
        );
        final useSafeArea =
            !state.isRestoringSession &&
            state.screen != AppScreen.welcome &&
            state.screen != AppScreen.welcomeDetails &&
            state.screen != AppScreen.home;
        final screenChild = state.isRestoringSession
            ? LoadingScreen(
                key: const ValueKey('session-loading'),
                message: context.getText(AppKeys.restoringSession),
              )
            : switch (state.screen) {
                AppScreen.welcome => WelcomeScreen(
                  key: const ValueKey('welcome'),
                  onStart: cubit.openWelcomeDetails,
                  onLogin: cubit.openLoginFromWelcome,
                ),
                AppScreen.welcomeDetails => WelcomeDetailsScreen(
                  key: const ValueKey('welcome-details'),
                  onStart: cubit.openSignupEntry,
                  onBack: cubit.openWelcome,
                ),
                AppScreen.login => LoginScreen(
                  key: const ValueKey('login'),
                  controller: phoneController,
                  region: state.phoneRegion,
                  onRegionChanged: (region) {
                    clearLoginPhoneInput();
                    cubit.clearPhoneLookup();
                    cubit.selectPhoneRegion(region);
                  },
                  onBack: cubit.openWelcomeDetails,
                  onSendOtp: () => sendOtp(cubit, state.phoneRegion),
                  actionLabel: actionLabel,
                  isSignupEntry: isSignupEntry,
                  isSendingOtp: state.isSendingOtp,
                  isCheckingAuthPhone: state.isCheckingAuthPhone,
                  canSendOtp: phoneComplete,
                  canLoginWithPin: state.canLoginWithPin,
                  onLoginWithPin: cubit.openPinLogin,
                  onSwitchEntryMode: () => cubit.switchAuthEntryMode(
                    isSignupEntry ? AuthEntryMode.login : AuthEntryMode.signup,
                  ),
                  onPhoneChanged: (value) =>
                      handlePhoneInputChanged(cubit, state.phoneRegion, value),
                  phoneErrorText: phoneErrorText,
                ),
                AppScreen.otp => OtpScreen(
                  key: const ValueKey('otp'),
                  onBack: cubit.openLogin,
                  onConfirm: cubit.verifyOtp,
                  onResend: cubit.resendLoginOtp,
                  isVerifyingOtp: state.isVerifyingOtp || state.isSendingOtp,
                  resendSeconds: state.otpExpiresIn ?? 0,
                  resendResetId: state.otpPreviewId,
                  autoFocusCode: state.otpFlow == OtpFlow.signup,
                  devOtpCode: state.devOtpCode,
                  otpError: state.otpError,
                  otpErrorId: state.otpErrorId,
                ),
                AppScreen.signup => SignupScreen(
                  key: const ValueKey('signup'),
                  onBack: cubit.cancelSignupToLogin,
                  isSigningUp: state.isSigningUp,
                  authError: state.authError,
                  onContinue: (form) {
                    HapticFeedback.mediumImpact();
                    cubit.submitSignup(form);
                  },
                ),
                AppScreen.passcode => PasscodeScreen(
                  key: ValueKey('passcode-${state.passcodeFlow.name}'),
                  mode: state.passcodeFlow == PasscodeFlow.setup
                      ? PasscodeScreenMode.setup
                      : PasscodeScreenMode.unlock,
                  onBack: cubit.cancelPasscodeUnlock,
                  onSubmit: (passcode) async {
                    await cubit.submitPasscode(passcode);
                    return null;
                  },
                  onSkip: state.passcodeCanSkip
                      ? cubit.skipPasscodeSetup
                      : null,
                  isBusy: state.isPasscodeBusy,
                  errorText: state.passcodeError,
                  errorId: state.passcodeErrorId,
                ),
                AppScreen.home => SessionDashboardScreen(
                  key: const ValueKey('home'),
                  onBack: cubit.openLogin,
                  onLogout: cubit.logout,
                ),
              };
        final transitionChild = KeyedSubtree(
          key: ValueKey(
            state.isRestoringSession
                ? 'session-loading'
                : 'auth-screen-${state.screen.name}',
          ),
          child: SafeArea(
            top: useSafeArea,
            bottom: useSafeArea && state.screen != AppScreen.home,
            left: useSafeArea,
            right: useSafeArea,
            child: screenChild,
          ),
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            if (!state.isRestoringSession && state.screen == AppScreen.welcome)
              _LoginScreenWarmup(
                region: state.phoneRegion,
                actionLabel: actionLabel,
                isSignupEntry: isSignupEntry,
              ),
            _AppScreenSlideSwitcher(
              screen: state.isRestoringSession ? null : state.screen,
              child: transitionChild,
            ),
          ],
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
              onRegionChanged: (_) {},
              onBack: () {},
              onSendOtp: () {},
              actionLabel: widget.actionLabel,
              isSignupEntry: widget.isSignupEntry,
              isSendingOtp: false,
              isCheckingAuthPhone: false,
              canSendOtp: false,
              canLoginWithPin: false,
              onLoginWithPin: () {},
              onSwitchEntryMode: () {},
              onPhoneChanged: (_) {},
            ),
          ),
        ),
      ),
    );
  }
}

String? _phoneLookupErrorText({
  required BuildContext context,
  required bool isSignupEntry,
  required bool lookupMatchesPhone,
  required bool? phoneExists,
  required String? phoneLookupError,
}) {
  if (!lookupMatchesPhone) {
    return null;
  }

  if (isSignupEntry && phoneExists == true) {
    return context.getText(AppKeys.signupPhoneAlreadyRegistered);
  }

  if (isSignupEntry && phoneExists == false) {
    return null;
  }

  if (!isSignupEntry && phoneExists == false) {
    return phoneLookupError ?? context.getText(AppKeys.loginPhoneNotRegistered);
  }

  return phoneLookupError;
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

    if (MediaQuery.disableAnimationsOf(context)) {
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
      AppScreen.otp => 3,
      AppScreen.signup => 4,
      AppScreen.passcode => 5,
      AppScreen.home => 6,
    };
  }
}

enum _AuthScreenTransition { fade, pageSlide, fadeScale }
